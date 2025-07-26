//
//  NetworkClient.swift
//  NetworkKit
//
//  Created by Aydın Sarıcan on 8.03.2025.
//

import Foundation

public final class NetworkClient: NetworkClientProtocol, @unchecked Sendable {
    @MainActor public static let shared = NetworkClient()

    private var configuration: NetworkConfiguration?
    private var urlSession: URLSession
    private let decoder: JSONDecoder
    private var logger: ((String) -> Void)?
    private var maxRetryCount: Int = 0

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

    public func setLogger(_ logger: @escaping (String) -> Void) {
        self.logger = logger
    }

    public func setMaxRetryCount(_ count: Int) {
        self.maxRetryCount = count
    }

    // Test/mock desteği için URLSession enjekte edilebilir
    public func setURLSession(_ session: URLSession) {
        self.urlSession = session
    }

    public func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        guard let config = configuration else {
            fatalError("NetworkConfiguration is not set. Call setConfiguration(_:) before making requests.")
        }
        guard let url = buildURL(for: endpoint, baseURL: config.baseURL) else {
            logger?("Invalid URL for endpoint: \(endpoint.path)")
            throw APIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = config.globalHeaders?.merging(endpoint.headers ?? [:]) { (_, new) in new }
        request.httpBody = endpoint.body
        if let customTimeout = endpoint.timeout {
            request.timeoutInterval = customTimeout
        }
        logger?("Request: \(request.httpMethod ?? "") \(url.absoluteString)")
        var lastError: Error?
        for attempt in 0...maxRetryCount {
            do {
                let (data, response) = try await urlSession.data(for: request)
                try validateResponse(response)
                logger?("Response: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                return try decoder.decode(T.self, from: data)
            } catch let error as DecodingError {
                logger?("Decoding failed: \(error)")
                throw APIError.decodingFailed(error)
            } catch let urlError as URLError {
                logger?("Network error: \(urlError), attempt: \(attempt)")
                lastError = urlError
                if attempt == maxRetryCount {
                    throw APIError.invalidResponse
                }
                continue
            } catch {
                logger?("Unknown error: \(error)")
                lastError = error
                if attempt == maxRetryCount {
                    throw error
                }
                continue
            }
        }
        throw lastError ?? APIError.invalidResponse
    }

    // Dosya indirme
    public func download(from url: URL, to destination: URL) async throws {
        let (tempURL, response) = try await urlSession.download(from: url)
        try validateResponse(response)
        try FileManager.default.moveItem(at: tempURL, to: destination)
        logger?("Downloaded file to: \(destination.path)")
    }

    // Dosya yükleme
    public func upload(fileURL: URL, to endpoint: Endpoint) async throws -> Data {
        guard let config = configuration else {
            fatalError("NetworkConfiguration is not set. Call setConfiguration(_:) before making requests.")
        }
        guard let url = buildURL(for: endpoint, baseURL: config.baseURL) else {
            logger?("Invalid URL for endpoint: \(endpoint.path)")
            throw APIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = config.globalHeaders?.merging(endpoint.headers ?? [:]) { (_, new) in new }
        if let customTimeout = endpoint.timeout {
            request.timeoutInterval = customTimeout
        }
        logger?("Upload request: \(request.httpMethod ?? "") \(url.absoluteString)")
        let (data, response) = try await urlSession.upload(for: request, fromFile: fileURL)
        try validateResponse(response)
        logger?("Upload response: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
        return data
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
