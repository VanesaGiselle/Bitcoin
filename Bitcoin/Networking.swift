//
//  Networking.swift
//  Bitcoin
//
//  Created by Vanesa Korbenfeld on 21/06/2023.
//

import Foundation

protocol Networking {
    func send<ResponseT: Decodable>(
        request: Request,
        parseAs responseType: ResponseT.Type,
        _ completionHandler: @escaping (Result<ResponseT, NetworkingError>) -> Void
    )
}

struct Request {
    let url: URL
    let method: HttpMethod
}

enum HttpMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}

struct Response {
    let statusCode: Int
    let data: Data
}
