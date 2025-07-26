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
    public let basePath: String?

    public init(
        baseURL: String,
        globalHeaders: [String: String]? = nil,
        timeoutInterval: TimeInterval = 30,
        basePath: String? = nil
    ) {
        guard let url = URL(string: baseURL), url.scheme != nil, url.host != nil else {
            fatalError("Invalid baseURL: \(baseURL)")
        }
        self.baseURL = baseURL
        self.globalHeaders = globalHeaders
        self.timeoutInterval = timeoutInterval
        self.basePath = basePath
    }
}
