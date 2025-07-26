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
    var contentType: String? { get }
    var accept: String? { get }
}

public extension Endpoint {
    var headers: [String: String]? { nil }
    var queryItems: [URLQueryItem]? { nil }
    var body: Data? { nil }
    var timeout: TimeInterval? { nil }
    var contentType: String? { nil }
    var accept: String? { nil }
}

public enum HTTPMethod: String {
    case GET, POST, PUT, DELETE, PATCH, HEAD, OPTIONS, TRACE, CONNECT
}
