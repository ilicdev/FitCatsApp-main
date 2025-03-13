//
//  HealthKitManagerTests.swift
//  FitCatsApp
//
//  Created by ilicdev on 20.1.25..
//


import XCTest
import HealthKit
@testable import FitCatsApp

class HealthKitManagerTests: XCTestCase {
    let healthKitManager = HealthKitManager.shared

    func testHealthKitAvailability() {
        let isAvailable = healthKitManager.isHealthKitAvailable()
        print("HealthKit dostupnost: \(isAvailable)")
        XCTAssertTrue(isAvailable, "HealthKit bi trebalo da bude dostupan na ovom uređaju.")
    }

    func testRequestAuthorization() {
        let expectation = self.expectation(description: "Authorization should succeed")
        healthKitManager.requestAuthorization { success, error in
            print("Authorization success: \(success), error: \(String(describing: error))")
            XCTAssertNil(error, "Greška tokom autorizacije: \(String(describing: error))")
            XCTAssertTrue(success, "Autorizacija nije uspela.")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }

    func testFetchStepCount() {
        let expectation = self.expectation(description: "Fetch step count should succeed")

        healthKitManager.fetchStepCount { stepCount, error in
            if let error = error {
                print("Greška pri preuzimanju broja koraka: \(error)")
                XCTFail("Greška pri preuzimanju broja koraka: \(error)")
            } else {
                print("Broj koraka: \(String(describing: stepCount))")
                XCTAssertNotNil(stepCount, "Broj koraka ne bi trebalo da bude nil.")
                XCTAssert(stepCount! >= 0, "Broj koraka ne može biti negativan.")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)
    }
}

