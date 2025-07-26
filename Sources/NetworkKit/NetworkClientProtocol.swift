//
//  NetworkClientProtocol.swift
//  NetworkKit
//
//  Created by Aydın Sarıcan on 27.07.2025
//

import Foundation

public protocol NetworkClientProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
    func download(from url: URL, to destination: URL) async throws
    func upload(fileURL: URL, to endpoint: Endpoint) async throws -> Data
}
