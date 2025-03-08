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

    public var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .invalidResponse: return "Invalid response from server"
        case .serverError(let code): return "Server error with status code: \(code)"
        case .decodingFailed(let error): return "Decoding failed: \(error.localizedDescription)"
        }
    }
}
