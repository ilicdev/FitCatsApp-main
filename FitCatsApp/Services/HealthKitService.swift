import Foundation
import HealthKit
import Combine

class HealthKitService: HealthServiceProtocol {
    private let healthStore = HKHealthStore()
    private let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
    private let stepUpdateSubject = PassthroughSubject<[Int], Error>()
    
    func isHealthDataAvailable() -> Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    func requestAuthorization() async throws -> Bool {
        let readTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!
        ]
        
        return try await withCheckedThrowingContinuation { continuation in
            healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: success)
                }
            }
        }
    }
    
    func fetchStepsForLast7Days() async throws -> [Int] {
        let calendar = Calendar.current
        let now = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -6, to: now) else {
            throw NSError(domain: "HealthKitService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not calculate start date"])
        }
        
        var dateComponents = DateComponents()
        dateComponents.day = 1
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsCollectionQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum,
                anchorDate: calendar.startOfDay(for: now),
                intervalComponents: dateComponents
            )
            
            query.initialResultsHandler = { _, results, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let results = results else {
                    continuation.resume(throwing: NSError(domain: "HealthKitService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No results found"]))
                    return
                }
                
                var steps: [Int] = []
                results.enumerateStatistics(from: startDate, to: now) { statistics, _ in
                    if let sum = statistics.sumQuantity() {
                        let stepCount = Int(sum.doubleValue(for: HKUnit.count()))
                        steps.append(stepCount)
                    } else {
                        steps.append(0)
                    }
                }
                
                continuation.resume(returning: steps)
            }
            
            healthStore.execute(query)
        }
    }
    
    func observeStepCountUpdates() -> AnyPublisher<[Int], Error> {
        let query = HKObserverQuery(sampleType: stepType, predicate: nil) { [weak self] _, _, error in
            if let error = error {
                self?.stepUpdateSubject.send(completion: .failure(error))
                return
            }
            
            Task {
                do {
                    let steps = try await self?.fetchStepsForLast7Days() ?? []
                    self?.stepUpdateSubject.send(steps)
                } catch {
                    self?.stepUpdateSubject.send(completion: .failure(error))
                }
            }
        }
        
        healthStore.execute(query)
        
        // Enable background delivery
        healthStore.enableBackgroundDelivery(for: stepType, frequency: .immediate) { success, error in
            if !success {
                print("Error enabling background delivery: \(String(describing: error))")
            }
        }
        
        return stepUpdateSubject.eraseToAnyPublisher()
    }
} 