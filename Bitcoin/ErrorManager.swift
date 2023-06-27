//
//  ErrorManager.swift
//  Bitcoin
//
//  Created by Vanesa Korbenfeld on 22/06/2023.
//

import Foundation
import UIKit

class ErrorManager {
    struct ViewModel {
        let title: String
        let actionMessage: String
    }
    
    private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    func getErrorViewController(error: ErrorType) -> UIViewController {
        let errorViewController = UIAlertController(title: viewModel.title, message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: viewModel.actionMessage, style: .default)
        errorViewController.addAction(action)
        return errorViewController
    }
}
