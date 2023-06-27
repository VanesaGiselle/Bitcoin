//
//  AppDelegate.swift
//  Bitcoin
//
//  Created by Vanesa Korbenfeld on 21/06/2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let networkingURLSession = URLSessionNetworking()
        let bitcoinProvider = NetworkingBitcoinProvider(networking: networkingURLSession)
        let timezoneProvider = NetworkingTimezoneProvider(networking: networkingURLSession)
        let presenter = BitcoinPresenter(bitcoinProvider: bitcoinProvider, timezoneProvider: timezoneProvider)
        let rootViewController = BitcoinViewController(presenter: presenter)
        let principalNavigationController = UINavigationController(rootViewController: rootViewController)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = principalNavigationController
        window?.makeKeyAndVisible()
        return true
    }
}

