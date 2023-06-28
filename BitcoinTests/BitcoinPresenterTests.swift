//
//  BitcoinPresenterTests.swift
//  BitcoinTests
//
//  Created by Vanesa Korbenfeld on 27/06/2023.
//

import Foundation

import XCTest
@testable import Bitcoin

class BitcoinPresenterTests: XCTestCase {

    //1 - Cuando timezone falla -> se tiene que mostrar error.
    func testTimezoneFailsShowError() throws {
        let delegate = BitcoinUISpy()
        let bitcoinPresenter = BitcoinPresenter(bitcoinProvider: MockBitcoinProvider(), timezoneProvider: MockTimezoneProvider(result: .failure(.noInternetConnection)))
        
        bitcoinPresenter.delegate = delegate
        bitcoinPresenter.getDataFromApi()
        
        XCTAssertEqual(delegate.error, .noInternetConnection)
    }
    
    //2 - Cuando Coincap falla -> error
    //3 - Cuando Gecko falla -> error
    
    func testGetDataFromApiSuccess() throws {
        let delegate = BitcoinUISpy()
        let bitcoinPresenter = BitcoinPresenter(
            bitcoinProvider: MockBitcoinProvider(bitcoinCap: 3, bitcoinGecko: 9),
            timezoneProvider: MockTimezoneProvider(
                result: .success(
                    Country(timezone: "-03:00")
                )
            )
        )
        
        bitcoinPresenter.delegate = delegate
        bitcoinPresenter.getDataFromApi()
        
        XCTAssertEqual(delegate.bitcoinPrice, "6.0")
        XCTAssertEqual(delegate.timezone, "-03:00")
    }
}

struct MockTimezoneProvider: TimezoneProvider {
    let result: Result<Country, ErrorType>
    init(result: Result<Country, ErrorType>) {
        self.result = result
    }
    func getTimezone(completionHandler: @escaping (Result<Country, ErrorType>) -> Void) {
        completionHandler(result)
    }
}

struct MockBitcoinProvider: BitcoinProvider {
    let bitcoinGecko: Int
    let bitcoinCap: Int
    
    init(bitcoinCap: Int = 5, bitcoinGecko: Int = 5) {
        self.bitcoinCap = bitcoinCap
        self.bitcoinGecko = bitcoinGecko
    }
    func getBitcoinPrice(bitcoinUrl: BitcoinUrl, completionHandler: @escaping (Result<Bitcoin, ErrorType>) -> Void) {
        completionHandler(.success(Bitcoin(usd: bitcoinUrl == .coingecko ? bitcoinGecko : bitcoinCap)))
    }
}

class BitcoinUISpy: BitcoinUI {
    var error: ErrorType?
    var bitcoinPrice: String?
    var timezone: String?
    
    func handleError(_ error: ErrorType) {
        self.error = error
    }
    
    func render(_ bitcoinPrice: String, _ timezone: String) {
        self.timezone = timezone
        self.bitcoinPrice = bitcoinPrice
    }
}
