//
//  LogPlace.swift
//  ChiliLabsTestTask
//
//  Created by Tobias on 21.03.2024.
//

import Foundation

enum LogPlace {
    case none
    case service(_ serviceType: String)
    case viewModel(_ viewModel: String)
}

extension LogPlace {
    var title: String {
        switch self {
        case .none: ""
        case .service(let serviceType): "[Serice \(serviceType)] "
        case .viewModel(let viewModel): "[VM \(viewModel)] "
        }
    }
}
