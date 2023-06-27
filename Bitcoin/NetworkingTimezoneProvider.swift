//
//  NetworkingTimezoneProvider.swift
//  Bitcoin
//
//  Created by Vanesa Korbenfeld on 26/06/2023.
//

import Foundation

class NetworkingTimezoneProvider: TimezoneProvider {
    private let networking: Networking
    
    init(networking: Networking){
        self.networking = networking
    }
    
    func getTimezone(completionHandler: @escaping (Result<Country, ErrorType>) -> Void) {
        guard let url = URL(string: "https://restcountries.com/v2/name/argentina") else {
            completionHandler(.failure(.serverNotFound))
            return
        }
        
        let request = Request(url: url, method: .get)
        networking.send(request: request, parseAs: [CountryFromApi].self) { result in
            switch result {
            case .success(let response):
                guard let country = response.first, let timezone = country.timezones.first else {
                    completionHandler(.failure(.noInternetConnection))
                    return
                }
                completionHandler(.success(Country(timezone: timezone)))
            case .failure(_):
                completionHandler(.failure(.noInternetConnection))
            }
        }
    }
    
}
