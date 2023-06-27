//
//  BitcoinData.swift
//  Bitcoin
//
//  Created by Vanesa Korbenfeld on 21/06/2023.
//

import Foundation

struct BitcoinInformationFromApi: Codable {
    struct Bitcoin: Codable {
        let usd: Int
    }
    let bitcoin: Bitcoin
}

struct BitcoinDataFromApi: Codable {
    struct Data: Codable {
        let priceUsd: String
    }
    let data: Data
}
