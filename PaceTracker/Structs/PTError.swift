//
//  PTError.swift
//  PaceTracker
//
//  Created by WhitetailAni on 1/9/25.
//

import Foundation

enum PTError: Error {
    case timedOut
    case noData
    case invalidJson
}

extension PTError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .timedOut:
            return "Request timed out"
        case .noData:
            return "No data received"
        case .invalidJson:
            return "Invalid JSON, could not process"
        }
    }
}
