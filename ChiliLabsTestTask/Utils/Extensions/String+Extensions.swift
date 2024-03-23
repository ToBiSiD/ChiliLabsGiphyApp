import Foundation

extension String {
    func toInt() -> Int {
        if let intValue = Int(self) {
            return intValue
        } else {
            return -1
        }
    }
}
