//
//  BitcoinTests.swift
//  BitcoinTests
//
//  Created by Vanesa Korbenfeld on 21/06/2023.
//

import XCTest
@testable import Bitcoin

class BitcoinTests: XCTestCase {
    func test_showsAverageOfPrices() {
        let bitcoinProvider = BitcoinProviderTestDouble()
        let timezoneProvider = TimezoneProviderTestDouble()
        
        let vm = BitcoinViewModel(bitcoinProvider: bitcoinProvider, timezoneProvider: timezoneProvider)
        vm.onViewAppear()
        
        XCTAssertTrue(vm.isShowingSpinner)
        XCTAssertFalse(vm.isShowingErrorAlert)
        
        bitcoinProvider.complete(.coincap, with: .success(.init(usd: 100)))
        
        XCTAssertTrue(vm.isShowingSpinner)
        
        bitcoinProvider.complete(.coingecko, with: .success(.init(usd: 200)))
        
        XCTAssertTrue(vm.isShowingSpinner)
        
        timezoneProvider.complete(with: .success(.init(timezone: "timezone")))
        
        XCTAssertFalse(vm.isShowingSpinner)
        XCTAssertFalse(vm.isShowingErrorAlert)
        XCTAssertEqual(vm.bitcoinAverageText, "$B 150.0")
        XCTAssertEqual(vm.timezoneText, "timezone")
    }
    
    func test_showsErrorAlertIfFirstBitcoinProviderFails() {
        let bitcoinProvider = BitcoinProviderTestDouble()
        let timezoneProvider = TimezoneProviderTestDouble()
        
        let vm = BitcoinViewModel(bitcoinProvider: bitcoinProvider, timezoneProvider: timezoneProvider)
        vm.onViewAppear()
        
        XCTAssertTrue(vm.isShowingSpinner)
        XCTAssertFalse(vm.isShowingErrorAlert)
        
        bitcoinProvider.complete(.coincap, with: .failure(.noInternetConnection))
        
        XCTAssertFalse(vm.isShowingSpinner)
        XCTAssertTrue(vm.isShowingErrorAlert)
        XCTAssertEqual(vm.errorAlertTitleText, "No internet connection!!")
        XCTAssertEqual(vm.errorAlertButtonText, "Please, check and try again!!")
        
        vm.onErrorAlertButtonTap()
        XCTAssertFalse(vm.isShowingErrorAlert)
    }
    
    func test_showsErrorAlertIfSecondBitcoinProviderFails() {
        let bitcoinProvider = BitcoinProviderTestDouble()
        let timezoneProvider = TimezoneProviderTestDouble()
        
        let vm = BitcoinViewModel(bitcoinProvider: bitcoinProvider, timezoneProvider: timezoneProvider)
        vm.onViewAppear()
        
        XCTAssertTrue(vm.isShowingSpinner)
        XCTAssertFalse(vm.isShowingErrorAlert)
        
        bitcoinProvider.complete(.coingecko, with: .success(.init(usd: 100)))
        
        XCTAssertTrue(vm.isShowingSpinner)
        XCTAssertFalse(vm.isShowingErrorAlert)
        
        bitcoinProvider.complete(.coincap, with: .failure(.noInternetConnection))
        
        XCTAssertFalse(vm.isShowingSpinner)
        XCTAssertTrue(vm.isShowingErrorAlert)
        XCTAssertEqual(vm.errorAlertTitleText, "No internet connection!!")
        XCTAssertEqual(vm.errorAlertButtonText, "Please, check and try again!!")
        
        vm.onErrorAlertButtonTap()
        XCTAssertFalse(vm.isShowingErrorAlert)
    }
    
    func test_showsErrorAlertIfTimezoneProviderAfterBitcoinProvidersOk() {
        let bitcoinProvider = BitcoinProviderTestDouble()
        let timezoneProvider = TimezoneProviderTestDouble()
        
        let vm = BitcoinViewModel(bitcoinProvider: bitcoinProvider, timezoneProvider: timezoneProvider)
        vm.onViewAppear()
        
        XCTAssertTrue(vm.isShowingSpinner)
        XCTAssertFalse(vm.isShowingErrorAlert)
        
        bitcoinProvider.complete(.coingecko, with: .success(.init(usd: 100)))
        
        XCTAssertTrue(vm.isShowingSpinner)
        XCTAssertFalse(vm.isShowingErrorAlert)
        
        bitcoinProvider.complete(.coincap, with: .success(.init(usd: 200)))
        
        XCTAssertTrue(vm.isShowingSpinner)
        XCTAssertFalse(vm.isShowingErrorAlert)
        
        timezoneProvider.complete(with: .failure(.noInternetConnection))
        
        XCTAssertFalse(vm.isShowingSpinner)
        XCTAssertTrue(vm.isShowingErrorAlert)
        XCTAssertEqual(vm.errorAlertTitleText, "No internet connection!!")
        XCTAssertEqual(vm.errorAlertButtonText, "Please, check and try again!!")
        
        vm.onErrorAlertButtonTap()
        XCTAssertFalse(vm.isShowingErrorAlert)
    }
}

class BitcoinProviderTestDouble: BitcoinProvider {
    func complete(_ param: BitcoinUrl, with result: Result<Bitcoin, ErrorType>) {
        guard let completion = completionByParam[param] else {
            XCTFail("No provider to complete for param: \(param)")
            return
        }
        completion(result)
        completionByParam[param] = nil
    }
    
    private var completionByParam: [BitcoinUrl: (Result<Bitcoin, ErrorType>) -> Void] = [:]
    
    func getBitcoinPrice(bitcoinUrl: BitcoinUrl, completionHandler: @escaping (Result<Bitcoin, ErrorType>) -> Void) {
        self.completionByParam[bitcoinUrl] = completionHandler
    }
}

class TimezoneProviderTestDouble: TimezoneProvider { // TODO: este y BitcoinProviderTestDouble se RE parecen (de hecho fue copy paste)... se puede extraer algo comun??
    func complete(with result: Result<Country, ErrorType>) {
        guard let completion = completion else {
            XCTFail("No provider to complete")
            return
        }
        completion(result)
        self.completion = nil
    }
    
    private var completion: ((Result<Country, ErrorType>) -> Void)?
    
    func getTimezone(completionHandler: @escaping (Result<Country, ErrorType>) -> Void) {
        self.completion = completionHandler
    }
}
