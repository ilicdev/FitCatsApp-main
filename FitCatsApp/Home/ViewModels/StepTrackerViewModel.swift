//
//  StepTrackerViewModel.swift
//
//
//  Created by ilicdev on 17.1.25..
//

import Foundation
import Combine

class StepTrackerViewModel: ObservableObject {
    @Published var stepsLast7Days: Int = 0
    @Published var currentRank: Rank?
    @Published var nextRank: Rank?
    @Published var progress: Double = 0.0
    @Published var stepCount: Int = 0
    @Published var dailySteps: [Int] = Array(repeating: 0, count: 7)
    @Published var dailyStepCount: Int = 0
    @Published var rankHistory: [String: Int] = [:]
    
    private let services = ServiceContainer.shared
    private var cancellables = Set<AnyCancellable>()
    private var endOfWeekTimer: Timer?
    
    let ranks: [Rank] = [
        Rank(name: "Cat", imageName: "rank1", rank: 0, threshold: 21_000, color: "Yellow", minSteps: 0, maxSteps: 21_000),
        Rank(name: "Cheetah", imageName: "rank2", rank: 1, threshold: 42_000, color: "Orange", minSteps: 21_000, maxSteps: 42_000),
        Rank(name: "Jaguar", imageName: "rank3", rank: 2, threshold: 63_000, color: "Red", minSteps: 42_000, maxSteps: 63_000),
        Rank(name: "Leopard", imageName: "rank4", rank: 3, threshold: 84_000, color: "Blue", minSteps: 63_000, maxSteps: 84_000),
        Rank(name: "Tiger", imageName: "rank5", rank: 4, threshold: 105_000, color: "Purple", minSteps: 84_000, maxSteps: 105_000),
        Rank(name: "Lion", imageName: "rank6", rank: 5, threshold: 105_000, color: "Purple", minSteps: 105_000, maxSteps: 250_000)
    ]
    
    init() {
        setupStepTracking()
        startEndOfWeekCheck()
    }
    
    private func setupStepTracking() {
        Task {
            do {
                let steps = try await services.healthService.fetchStepsForLast7Days()
                await MainActor.run {
                    self.dailySteps = steps
                    self.dailyStepCount = steps.last ?? 0
                    self.updateSteps()
                }
            } catch {
                print("Error fetching initial steps: \(error)")
            }
        }
        
        services.healthService.observeStepCountUpdates()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Error observing steps: \(error)")
                }
            } receiveValue: { [weak self] steps in
                self?.dailySteps = steps
                self?.dailyStepCount = steps.last ?? 0
                self?.updateSteps()
            }
            .store(in: &cancellables)
    }
    
    func startEndOfWeekCheck() {
        endOfWeekTimer = Timer.scheduledTimer(withTimeInterval: 86400, repeats: true) { [weak self] _ in
            self?.updateRankHistoryAtEndOfWeek()
        }
    }
    
    func updateSteps() {
        stepsLast7Days = dailySteps.reduce(0, +)
        calculateRanks()
        
        guard let userId = services.authService.currentUserId else { return }
        
        Task {
            do {
                if let currentRank = self.currentRank {
                    let updatedData: [String: Any] = [
                        "thisWeekSteps": self.stepsLast7Days,
                        "currentRank.name": currentRank.name,
                        "currentRank.imageName": currentRank.imageName,
                    ]
                    try await services.userService.updateUser(id: userId, data: updatedData)
                }
            } catch {
                print("Error updating user steps: \(error)")
            }
        }
    }
    
    func getCurrentAndNextRank(steps: Int) -> (current: Rank, next: Rank?) {
        for (index, rank) in ranks.enumerated() {
            if steps <= rank.maxSteps ?? 0 {
                let next = index + 1 < ranks.count ? ranks[index + 1] : nil
                return (rank, next)
            }
        }
        return (ranks.last!, nil)
    }
    
    func calculateRanks() {
        let (current, next) = getCurrentAndNextRank(steps: stepsLast7Days)
        currentRank = current
        nextRank = next
        if let currentRank = currentRank {
            if let maxSteps = currentRank.maxSteps, let minSteps = currentRank.minSteps {
                progress = Double(stepsLast7Days - minSteps) / Double(maxSteps - minSteps)
            }
        } else {
            progress = 0.0
        }
    }
    
    func updateRankHistoryAtEndOfWeek() {
        let calendar = Calendar.current
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: Date()) else { return }
        
        if calendar.isDateInToday(weekInterval.end) {
            guard let userId = services.authService.currentUserId else { return }
            
            if let currentRank = currentRank {
                updateRankHistory(for: currentRank.name)
                
                Task {
                    do {
                        try await services.userService.updateUser(id: userId, data: ["rankHistory": rankHistory])
                    } catch {
                        print("Error updating rank history: \(error)")
                    }
                }
            }
        }
    }
    
    func updateRankHistory(for rankName: String) {
        rankHistory[rankName] = (rankHistory[rankName] ?? 0) + 1
    }
    
    func formattedWeekDates() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let calendar = Calendar.current
        
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: Date()) else { return "" }
        let startOfWeek = weekInterval.start
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? weekInterval.end
        
        return "\(formatter.string(from: startOfWeek)) - \(formatter.string(from: endOfWeek))"
    }
    
    func progressTowardsNextRank() -> Double {
        return progress
    }
}
