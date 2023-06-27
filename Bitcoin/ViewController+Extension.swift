//
//  ViewController+Extension.swift
//  Bitcoin
//
//  Created by Vanesa Korbenfeld on 23/06/2023.
//

import UIKit

extension UIViewController {
    func handleFailure(_ error: ErrorType) {
        let errorViewController = ErrorManager(viewModel: error.getErrorManagerViewModel()).getErrorViewController(error: error)
        self.present(errorViewController, animated: false)
    }
}
