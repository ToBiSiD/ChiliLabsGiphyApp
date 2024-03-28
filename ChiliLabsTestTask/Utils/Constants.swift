import UIKit

enum AppColor {
    static let giphyBack = UIColor.systemGray3
    static let spinner = UIColor.systemYellow
    static let shadow = UIColor.systemGray
    static let error = UIColor.systemRed
    static let navigation = UIColor.systemMint
}


struct UIConstants {
    static let searchDelay: TimeInterval = 2
    static let horizontalPadding: CGFloat = 20.0
    static let cellInRow: Int = 2
    static let collectionSpacing: CGFloat = 10
    static let giphyCellId: String = "giphyCell"
    
    static func calculateCellSize(for rows: Int, with padding: CGFloat) -> CGFloat {
        DebugLogger.printLog("Calculate Size", type: .action)
        let width = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        let size: CGFloat = width / CGFloat(rows) - padding
        
        return size
    }
}
