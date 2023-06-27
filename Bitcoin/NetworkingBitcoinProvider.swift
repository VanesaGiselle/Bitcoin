//
//  NetworkingBitcoinProvider.swift
//  Bitcoin
//
//  Created by Vanesa Korbenfeld on 22/06/2023.
//

import Foundation

enum BitcoinUrl: String {
    case coingecko = "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd"
    case coincap = "https://api.coincap.io/v2/assets/bitcoin"
}

class NetworkingBitcoinProvider: BitcoinProvider {
    private let networking: Networking
    
    init(networking: Networking) {
        self.networking = networking
    }
    
    func getBitcoinPrice(bitcoinUrl: BitcoinUrl, completionHandler: @escaping (Result<Bitcoin, ErrorType>) -> Void) {
        guard let url = URL(string: bitcoinUrl.rawValue) else {
            completionHandler(.failure(.serverNotFound))
            return
        }
        
        switch bitcoinUrl {
        case .coingecko:
            networking.send(request: Request(url: url, method: .get), parseAs: BitcoinInformationFromApi.self) { result in
                switch result {
                case .success(let response):
                    let bitcoinPrice = Bitcoin(usd: response.bitcoin.usd)
                    completionHandler(.success(bitcoinPrice))
                case .failure(_):
                    completionHandler(.failure(.noInternetConnection))
                }
            }
        case .coincap:
            networking.send(request: Request(url: url, method: .get), parseAs: BitcoinDataFromApi.self) { result in
                switch result {
                case .success(let response):
                    guard let price = Double(response.data.priceUsd) else {
                        completionHandler(.failure(.noInternetConnection))
                        return
                    }
                    let bitcoinPrice = Bitcoin(usd: Int(price))
                    completionHandler(.success(bitcoinPrice))
                case .failure(_):
                    completionHandler(.failure(.noInternetConnection))
                }
            }
        }
    }
}
