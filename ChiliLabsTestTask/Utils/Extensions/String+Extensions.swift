import Foundation

extension String {
    func toInt() -> Int {
        if let intValue = Int(self) {
            return intValue
        } else {
            return -1
        }
    }
    
    func toPublsihedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let date = dateFormatter.date(from: self) {
            let outputDateFormatter = DateFormatter()
            outputDateFormatter.dateFormat = "dd MMMM yy"
            let formattedDate = outputDateFormatter.string(from: date)
            return formattedDate
        } else {
            return ""
        }
    }
}
