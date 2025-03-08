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
    public let timeoutInterval: TimeInterval

    public init(
        baseURL: String,
        globalHeaders: [String: String]? = nil,
        timeoutInterval: TimeInterval = 30
    ) {
        self.baseURL = baseURL
        self.globalHeaders = globalHeaders
        self.timeoutInterval = timeoutInterval
    }
}
