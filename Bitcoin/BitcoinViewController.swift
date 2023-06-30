//
//  BitcoinViewController.swift
//  Bitcoin
//
//  Created by Vanesa Korbenfeld on 21/06/2023.
//

import UIKit
import Combine

class BitcoinViewController: UIViewController {
    private var bitcoinViewModel: BitcoinViewModel
    private var cancellables: Set<AnyCancellable> = []

    init(bitcoinViewModel: BitcoinViewModel) {
        self.bitcoinViewModel = bitcoinViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var bitcoinLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    private lazy var timezoneLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private lazy var spinner: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.color = .black
        view.startAnimating()
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        createBindingWithViewModel()
        
        bitcoinViewModel.onViewAppear()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(bitcoinLabel)
        view.addSubview(timezoneLabel)
        view.addSubview(spinner)
        
        bitcoinLabel.translatesAutoresizingMaskIntoConstraints = false
        timezoneLabel.translatesAutoresizingMaskIntoConstraints = false
        spinner.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bitcoinLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bitcoinLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            timezoneLabel.topAnchor.constraint(equalTo: bitcoinLabel.bottomAnchor, constant:  20),
            timezoneLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    func createBindingWithViewModel() {
        bitcoinViewModel.$bitcoinAverageText
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] bitcoinAverage in
                guard let self = self else { return }
                self.bitcoinLabel.text = bitcoinAverage
            }).store(in: &cancellables)
        
        bitcoinViewModel.$timezoneText
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] value in
            guard let self = self else { return }
                self.timezoneLabel.text = value
            }).store(in: &cancellables)
        
//        bitcoinViewModel.$error
//            .receive(on: DispatchQueue.main)
//            .sink(receiveValue: { [weak self] value in
//            guard let self = self, let error = self.bitcoinViewModel.error else { return }
//
//                self.handleFailure(error)
//            }).store(in: &cancellables)
        
        bitcoinViewModel.$isShowingSpinner
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isShowingSpinner in
            guard let self = self else { return }
                self.spinner.isHidden = !isShowingSpinner
            }).store(in: &cancellables)

        Publishers.CombineLatest3(
            bitcoinViewModel.$isShowingErrorAlert,
            bitcoinViewModel.$errorAlertTitleText,
            bitcoinViewModel.$errorAlertButtonText
        )
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] publishers in
                guard let self = self else { return }
                let (isShowinErrorAlert, errorAlertTitleText, errorAlertButtonText) = publishers
                if isShowinErrorAlert { // esto no me gusta mucho, habría que ver como evitarlo o si se va cuando tengamos un modelo de vista de alerta... 
                    let alert = UIAlertController(title: errorAlertTitleText, message: nil, preferredStyle: .alert)
                    alert.addAction(.init(title: errorAlertButtonText, style: .default) { _ in self.bitcoinViewModel.onErrorAlertButtonTap()
                    })
                    self.present(alert, animated:  true)
                } else {
                    self.dismiss(animated: true)
                }
            }).store(in: &cancellables)
    }
}
