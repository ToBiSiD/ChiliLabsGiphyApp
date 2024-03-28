import Foundation
import UIKit

final class DetailsCoordinator: Coordinator {
    private let navigationController: UINavigationController
    private let giphyData: GiphyObject
    
    init(_ navigationController: UINavigationController, giphy: GiphyObject) {
        self.navigationController = navigationController
        self.giphyData = giphy
    }
    
    func start() {
        let controller: DetailsViewController = .init(coordinator: self)
        navigationController.pushViewController(controller, animated: true)
    }
    
    func share(_ data: [Any]) {
        let activityViewController = UIActivityViewController(activityItems: data, applicationActivities: nil)
        
        navigationController.present(activityViewController, animated: true)
    }
    
    func pop() {
        navigationController.popViewController(animated: true)
    }
    
    func getData() -> GiphyObject { giphyData }
}
