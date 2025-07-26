//
//  APIError.swift
//  NetworkKit
//
//  Created by Aydın Sarıcan on 8.03.2025.
//

import Foundation

public enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case decodingFailed(Error)
    case timeout
    case network(Error)
    case cancelled

    public var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .invalidResponse: return "Invalid response from server"
        case .serverError(let code): return "Server error with status code: \(code)"
        case .decodingFailed(let error): return "Decoding failed: \(error.localizedDescription)"
        case .timeout: return "Request timed out"
        case .network(let error): return "Network error: \(error.localizedDescription)"
        case .cancelled: return "Request was cancelled"
        }
    }
}
