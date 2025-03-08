//
//  NetworkConfiguration.swift
//  NetworkKit
//
//  Created by Aydın Sarıcan on 8.03.2025.
//

import Foundation

public struct NetworkConfiguration {
    public let baseURL: String
    public let globalHeaders: [String: String]?

    public init(baseURL: String, globalHeaders: [String: String]? = nil) {
        self.baseURL = baseURL
        self.globalHeaders = globalHeaders
    }
}
