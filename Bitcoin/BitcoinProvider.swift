//
//  BitcoinProvider.swift
//  Bitcoin
//
//  Created by Vanesa Korbenfeld on 22/06/2023.
//

import Foundation

protocol BitcoinProvider {
    func getBitcoinPrice(bitcoinUrl: BitcoinUrl, completionHandler: @escaping(Result<Bitcoin, ErrorType>) -> Void)
}
