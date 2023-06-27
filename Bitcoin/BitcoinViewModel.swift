//
//  BitcoinPresenter.swift
//  Bitcoin
//
//  Created by Vanesa Korbenfeld on 27/06/2023.
//

import Foundation
import Combine

class BitcoinViewModel {
    @Published var bitcoinAverage: String = ""
    @Published var timezone: String = ""
    @Published var error: ErrorType? = nil
    
    private var bitcoinProvider: BitcoinProvider
    private var timezoneProvider: TimezoneProvider
    private var cancellables: Set<AnyCancellable> = []
    
    init(bitcoinProvider: BitcoinProvider, timezoneProvider: TimezoneProvider) {
        self.bitcoinProvider = bitcoinProvider
        self.timezoneProvider = timezoneProvider
    }
    
    func getDataFromApi() {
        let bitcoinCoincapPublisher = getBitcoinPriceFromCoincap()
        let bitcoinCoingeckoPublisher = getBitcoinPriceFromCoingecko()
        let timezoneCountryPublisher = getTimezoneFromApi()
        
        Publishers.Zip3(bitcoinCoincapPublisher, bitcoinCoingeckoPublisher, timezoneCountryPublisher).sink(receiveCompletion:{ [weak self] completion in
            guard case .failure(let error) = completion, let self = self else { return }
            self.error = error
        }, receiveValue: { [weak self] bitcoinCap, bitcoinGecko, timezone in
            guard let self = self else { return }
            self.bitcoinAverage = String((bitcoinCap + bitcoinGecko) / 2)
            self.timezone = timezone
        })
            .store(in: &cancellables)
    }
    
    private func getTimezoneFromApi() -> AnyPublisher<String, ErrorType> {
        return Future<String, ErrorType> { [weak self] promise in
            guard let self = self else { return }
            
            self.timezoneProvider.getTimezone { (result: Result<Country, ErrorType>) in
                switch result {
                case .success(let country):
                    promise(.success(country.timezone))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func getBitcoinPriceFromCoincap() -> AnyPublisher<Double, ErrorType> {
        return Future<Double, ErrorType> { [weak self] promise in
            guard let self = self else { return }
            
            self.bitcoinProvider.getBitcoinPrice(bitcoinUrl: .coincap, completionHandler: { result in
                switch result {
                case .success(let bitcoin):
                    promise(.success(Double(bitcoin.usd)))
                case .failure(let error):
                    promise(.failure(error))
                }
            })
        }.eraseToAnyPublisher()
    }
    
    private func getBitcoinPriceFromCoingecko() -> AnyPublisher<Double, ErrorType> {
        return Future<Double, ErrorType> { [weak self] promise in
            guard let self = self else { return }
            
            self.bitcoinProvider.getBitcoinPrice(bitcoinUrl: .coingecko, completionHandler: { result in
                switch result {
                case .success(let bitcoin):
                    promise(.success(Double(bitcoin.usd)))
                case .failure(let error):
                    promise(.failure(error))
                }
            })
        }.eraseToAnyPublisher()
    }
}
