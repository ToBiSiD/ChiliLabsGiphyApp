//
//  LogType.swift
//  ChiliLabsTestTask
//
//  Created by Tobias on 21.03.2024.
//

import Foundation

enum LogType: String {
    case none
    case error
    case warning
    case success
    case action
    case canceled
}

extension LogType {
    var typeIdentifier: String {
        switch self {
        case .none: "⚪️"
        case .error: "🔴 Error:"
        case .warning: "🟠 Warning:"
        case .success: "🟢 Success:"
        case .action: "🔵 Action:"
        case .canceled: "🟣 Cancelled:"
        }
    }
}
