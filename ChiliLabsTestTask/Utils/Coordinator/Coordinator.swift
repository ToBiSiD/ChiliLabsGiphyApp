import Foundation
import UIKit

protocol Coordinator: AnyObject {
    func start()
    func showError(with message: String, onDismiss: (() -> Void)?)
}
