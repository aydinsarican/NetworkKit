//
//  Endpoint.swift
//  NetworkKit
//
//  Created by Aydın Sarıcan on 8.03.2025.
//

import Foundation

public protocol Endpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var queryItems: [URLQueryItem]? { get }
    var body: Data? { get }
    var timeout: TimeInterval? { get }
}

public extension Endpoint {
    var headers: [String: String]? { nil }
    var queryItems: [URLQueryItem]? { nil }
    var body: Data? { nil }
    var timeout: TimeInterval? { nil }
}

public enum HTTPMethod: String {
    case GET, POST, PUT, DELETE
}
