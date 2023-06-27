//
//  TimezoneProvider.swift
//  Bitcoin
//
//  Created by Vanesa Korbenfeld on 26/06/2023.
//

import Foundation

protocol TimezoneProvider {
    func getTimezone(completionHandler: @escaping(Result<Country, ErrorType>) -> Void)
}
