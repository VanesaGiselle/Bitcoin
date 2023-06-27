//
//  NetworkingError.swift
//  Bitcoin
//
//  Created by Vanesa Korbenfeld on 22/06/2023.
//

import Foundation

enum NetworkingError: Error {
    case urlError
    case httpError
    case dataError
    case parseError
    case noInternetError
    
    func getErrorDebugMessage() -> String {
        var message: String
        
        switch self {
        case .urlError:
            message = "The URL is unavailable."
        case .httpError:
            message = "Error in server."
        case .dataError:
            message = "The data is unavailable."
        case .parseError:
            message = "The information is invalid."
        case .noInternetError:
            message = "No internet connection."
        }
        return message
    }
}
