import Foundation
import UIKit

protocol DetailsCoordinatorProtocol: Coordinator {
    func share(_ data: [Any])
    func pop()
    func getData() -> GiphyObject
    func getCacheService() -> VideoCacheService
}

final class DetailsCoordinator: DetailsCoordinatorProtocol {
    private let navigationController: UINavigationController
    private let giphyData: GiphyObject
    private let cacheService: VideoCacheService
    
    init(_ navigationController: UINavigationController, giphy: GiphyObject, cacheService: VideoCacheService) {
        self.navigationController = navigationController
        self.giphyData = giphy
        self.cacheService = cacheService
    }
    
    func start() {
        let controller: DetailsViewController = .init(coordinator: self)
        navigationController.pushViewController(controller, animated: true)
        navigationController.setNavigationBarHidden(true, animated: false)
    }
    
    func showError(with message: String, onDismiss: (() -> Void)?) {
        let popupErrorVC = PopupErrorViewController(with: message, onDismiss: onDismiss)
        navigationController.present(popupErrorVC, animated: true)
    }
    
    func share(_ data: [Any]) {
        let activityViewController = UIActivityViewController(activityItems: data, applicationActivities: nil)
        
        navigationController.present(activityViewController, animated: true)
    }
    
    func pop() {
        navigationController.popViewController(animated: true)
    }
    
    func getData() -> GiphyObject { giphyData }
    
    func getCacheService() -> VideoCacheService { cacheService }
}
