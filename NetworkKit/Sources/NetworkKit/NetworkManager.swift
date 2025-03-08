//
//  NetworkManager.swift
//  NetworkKit
//
//  Created by Aydın Sarıcan on 8.03.2025.
//

import Foundation

public final class NetworkManager {
    @MainActor public static let shared = NetworkManager()

    private var configuration: NetworkConfiguration?
    private var urlSession: URLSession
    private let decoder: JSONDecoder

    private init() {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        urlSession = URLSession(configuration: config)
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    /// **Network yapılandırmasını setlemek için çağırılacak fonksiyon**
    public func setConfiguration(_ config: NetworkConfiguration) {
        configuration = config

        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = config.timeoutInterval
        sessionConfig.timeoutIntervalForResource = config.timeoutInterval

        urlSession = URLSession(configuration: sessionConfig)
    }

    public func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        guard let config = configuration else {
            fatalError("NetworkConfiguration is not set. Call setConfiguration(_:) before making requests.")
        }

        guard let url = buildURL(for: endpoint, baseURL: config.baseURL) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = config.globalHeaders?.merging(endpoint.headers ?? [:]) { (_, new) in new }
        request.httpBody = endpoint.body

        if let customTimeout = endpoint.timeout {
            request.timeoutInterval = customTimeout
        }

        do {
            let (data, response) = try await urlSession.data(for: request)
            try validateResponse(response)
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingFailed(error)
        }
    }

    private func buildURL(for endpoint: Endpoint, baseURL: String) -> URL? {
        var components = URLComponents(string: baseURL)
        components?.path.append(endpoint.path)
        components?.queryItems = endpoint.queryItems
        return components?.url
    }

    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }
    }
}
