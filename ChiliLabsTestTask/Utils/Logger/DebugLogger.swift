//
//  DebugLogger.swift
//  ChiliLabsTestTask
//
//  Created by Tobias on 21.03.2024.
//

import Foundation

struct DebugLogger {
    static var isEnabled: Bool = true
    
    static func printLog(_ items: Any..., place: LogPlace = .none, type: LogType = .none) {
        if !isEnabled {
            return
        }
        
        let info: String = type.typeIdentifier + place.title
        print("\(info)", items)
    }
}

extension DebugLogger {
    static func testPrint() {
        printLog("Success", type: .success)
        printLog("Action", type: .action)
        printLog("Canceled", type: .canceled)
        printLog("Error", type: .error)
        printLog("Warning", type: .warning)
        printLog("None", type: .none)
    }
}
