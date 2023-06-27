//
//  UrlSessionNetworking.swift
//  Bitcoin
//
//  Created by Vanesa Korbenfeld on 22/06/2023.
//

import Foundation

class URLSessionNetworking: Networking {
    private let urlSession = URLSession.shared
    
    func send<ResponseT>(request: Request, parseAs responseType: ResponseT.Type, _ completionHandler: @escaping (Result<ResponseT, NetworkingError>) -> Void) where ResponseT : Decodable {
        var urlSessionRequest = URLRequest(url: request.url)
        urlSessionRequest.httpMethod = request.method.rawValue.uppercased()
        urlSession.dataTask(with: urlSessionRequest, completionHandler: { data, response, error in
            DispatchQueue.main.sync {
                if error != nil {
                    // TODO: log or detailed error
                    completionHandler(.failure(.dataError))
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    // TODO: log or detailed error
                    completionHandler(.failure(.dataError))
                    return
                }
                let response = Response(statusCode: httpResponse.statusCode, data: data ?? Data()) // TODO: ojo con default value
                do {
                    let typedResponse = try JSONDecoder().decode(responseType, from: response.data)
                    completionHandler(.success(typedResponse))
                } catch {
                    // TODO: log or detailed error
                    completionHandler(.failure(.dataError))
                }
            }
        }).resume()
    }
}
