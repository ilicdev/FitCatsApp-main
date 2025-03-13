//
//  SignInViewModelTests.swift
//  FitCatsApp
//
//  Created by ilicdev on 4.1.25..
//

import XCTest
@testable import FitCatsApp

class SignInViewModelTests: XCTestCase {
    var viewModel: SignInViewModel!
    override func setUp() {
        super.setUp()
        viewModel = SignInViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    // Testiranje validacije korisničkog imena
    func testUsernameValidation() {
        viewModel.username = "" // Prazno korisničko ime
        viewModel.password = "password123" // Validna lozinka
        viewModel.validateForm()
        
        XCTAssertFalse(viewModel.isUsernameValid)
        XCTAssertEqual(viewModel.errorMessage, "Username cannot be empty.")
        
        viewModel.username = "validUsername" // Validno korisničko ime
        viewModel.validateForm()
        
        XCTAssertTrue(viewModel.isUsernameValid)
        XCTAssertNil(viewModel.errorMessage)
    }

    // Testiranje validacije lozinke
    func testPasswordValidation() {
        viewModel.username = "validUsername" // Validno korisničko ime
        viewModel.password = "" // Prazna lozinka
        viewModel.validateForm()
        
        XCTAssertFalse(viewModel.isPasswordValid)
        XCTAssertEqual(viewModel.errorMessage, "Password cannot be empty.")
        
        viewModel.password = "short" // Loša lozinka (kraća od 8 karaktera)
        viewModel.validateForm()
        
        XCTAssertFalse(viewModel.isPasswordValid)
        XCTAssertEqual(viewModel.errorMessage, "Password must be at least 8 characters long.")
        
        viewModel.password = "password123" // Validna lozinka
        viewModel.validateForm()
        
        XCTAssertTrue(viewModel.isPasswordValid)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    // Testiranje celokupne validacije
    func testFormValidation() {
        viewModel.username = "validUsername"
        viewModel.password = "password123"
        viewModel.validateForm()
        
        XCTAssertTrue(viewModel.isUsernameValid)
        XCTAssertTrue(viewModel.isPasswordValid)
        XCTAssertNil(viewModel.errorMessage)
    }
}
