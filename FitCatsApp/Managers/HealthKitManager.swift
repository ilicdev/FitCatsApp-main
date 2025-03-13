//
//  HealthKitManager.swift
//  FitCatsApp
//
//  Created by ilicdev on 18.1.25..
//

import Foundation
import HealthKit
import Combine

class HealthKitManager {
     static let shared = HealthKitManager()
     private let healthStore = HKHealthStore()
     private let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
     var stepUpdatePublisher = PassthroughSubject<[Int], Never>()

    func fetchStepsForLast7Days(completion: @escaping ([Int]?, Error?) -> Void) {
        let calendar = Calendar.current
        let now = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -6, to: now) else {
            print("Error: Could not calculate start date.")
            completion(nil, nil)
            return
        }

        var dateComponents = DateComponents()
        dateComponents.day = 1

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)

        let query = HKStatisticsCollectionQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: calendar.startOfDay(for: now),
            intervalComponents: dateComponents
        )

        query.initialResultsHandler = { _, results, error in
            guard let results = results, error == nil else {
                print("Error fetching statistics: \(String(describing: error))")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
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

            DispatchQueue.main.async {
                completion(steps, nil)
            }
        }
         healthStore.execute(query)
     }
    
    func startStepCountObservation() {
          let query = HKObserverQuery(sampleType: stepType, predicate: nil) { [weak self] _, _, error in
              if let error = error {
                  print("Error observing step count: \(error.localizedDescription)")
                  return
              }
              // Kada se detektuje promena, pozovi fetchStepsForLast7Days
              self?.fetchStepsForLast7Days { steps, error in
                  if let error = error {
                      print("Error fetching steps after observation: \(error)")
                  } else {
                      print("Steps updated after observation: \(steps ?? [])")
                      self?.stepUpdatePublisher.send(steps ?? [])
                  }
              }
          }
          healthStore.execute(query)
          healthStore.enableBackgroundDelivery(for: stepType, frequency: .immediate) { success, error in
              if !success {
                  print("Error enabling background delivery: \(String(describing: error))")
              }
          }
      }

    
    
    
    
    // Proveri da li je HealthKit dostupan
    func isHealthKitAvailable() -> Bool {
        return HKHealthStore.isHealthDataAvailable()
    }

    // Zatraži dozvole za pristup podacima
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        let readTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!
        ]

        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            completion(success, error)
        }
    }

    // Čitaj podatke
    func fetchStepCount(completion: @escaping (Double?, Error?) -> Void) {
        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }

        let query = HKStatisticsQuery(quantityType: stepCountType, quantitySamplePredicate: nil, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(nil, error)
                return
            }
            completion(sum.doubleValue(for: HKUnit.count()), nil)
        }

        healthStore.execute(query)
    }
}
