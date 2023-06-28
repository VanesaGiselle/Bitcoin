//
//  BitcoinPresenter.swift
//  Bitcoin
//
//  Created by Vanesa Korbenfeld on 27/06/2023.
//

import Foundation
import Combine

protocol BitcoinUI {
    func handleError(_ error: ErrorType)
    func render(_ bitcoinPrice: String, _ timezone: String)
}

class BitcoinPresenter {
    var delegate: BitcoinUI?
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
        var bitcoinCap: Double!
        var bitcoinGecko: Double!
        var timezone: String!
        
        bitcoinCoincapPublisher.sink { [weak self]
            completion in
                guard case .failure(let error) = completion, let self = self else { return }
                self.delegate?.handleError(error)
        } receiveValue: { value in
            bitcoinCap = value
            bitcoinCoingeckoPublisher.sink { [weak self]
                completion in
                    guard case .failure(let error) = completion, let self = self else { return }
                    self.delegate?.handleError(error)
            } receiveValue: { value in
                bitcoinGecko = value
                timezoneCountryPublisher.sink { [weak self]
                    completion in
                        guard case .failure(let error) = completion, let self = self else { return }
                        self.delegate?.handleError(error)
                } receiveValue: { string in
                    timezone = string
                    let bitcoinAverage = (bitcoinCap + bitcoinGecko) / 2
                    self.delegate?.render(String(bitcoinAverage), timezone)
                }

            }

        }

        
//        Publishers.Zip3(bitcoinCoincapPublisher, bitcoinCoingeckoPublisher, timezoneCountryPublisher).sink(receiveCompletion:{ [weak self] completion in
//            guard case .failure(let error) = completion, let self = self else { return }
//            self.delegate?.handleError(error)
//        }, receiveValue: { [weak self] bitcoinCap, bitcoinGecko, timezone in
//            guard let self = self else { return }
//            let bitcoinAverage = (bitcoinCap + bitcoinGecko) / 2
//            self.delegate?.render(String(bitcoinAverage), timezone)
//        })
//            .store(in: &cancellables)
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
