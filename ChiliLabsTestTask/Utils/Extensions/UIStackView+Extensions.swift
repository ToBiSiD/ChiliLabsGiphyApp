import Foundation
import UIKit

extension UIStackView {
    func addArrangedSubviews(_ views: UIView...) {
        views.forEach { childView in
            self.addArrangedSubview(childView)
        }
    }
}
