//
//  ErrorType.swift
//  Bitcoin
//
//  Created by Vanesa Korbenfeld on 22/06/2023.
//

import Foundation

enum ErrorType: Error {
    case serverNotFound
    case noInternetConnection
    
    func getErrorManagerViewModel() -> ErrorManager.ViewModel {
        var title: String
        var actionMessage: String
        
        switch self {
        case .serverNotFound:
            title = "Error in server."
            actionMessage = "Please, try later."
        case .noInternetConnection:
            title = "No internet connection."
            actionMessage = "Please, check and try again."
        }
        return ErrorManager.ViewModel(title: title, actionMessage: actionMessage)
    }
}
