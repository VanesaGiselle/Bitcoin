//
//  Coordinator.swift
//  Bitcoin
//
//  Created by Vanesa Korbenfeld on 28/06/2023.
//

import Foundation
import UIKit

protocol Coordinator {
    var viewController: UIViewController? { get }
    var navigationController: UINavigationController? { get }
    func start()
}
