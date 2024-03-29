import Foundation
import UIKit

protocol MainCoordinatorProtocol: Coordinator {
    func openDetails(for giphy: GiphyObject)
    func getViewModel() -> GiphyViewModel
    func getCacheService() -> VideoCacheService
}

final class MainCoordinator: MainCoordinatorProtocol {
    private let navigationController: UINavigationController
    private let viewModel: GiphyViewModel
    private let apiService: APILoaderService
    private let cachedService: VideoCacheService
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.apiService = GiphyLoaderService()
        self.viewModel = .init(apiService: apiService)
        self.cachedService = GiphyVideoCacheService()
    }
    
    func start() {
        let mainVC: MainViewController = .init(coordinator: self)
        
        navigationController.pushViewController(mainVC, animated: true)
    }
    
    func showError(with message: String, onDismiss: (() -> Void)?) {
        let popupErrorVC = PopupErrorViewController(with: message, onDismiss: onDismiss)
        navigationController.present(popupErrorVC, animated: true)
    }
    
    func openDetails(for giphy: GiphyObject) {
        let detailsCoordinator: DetailsCoordinator = .init(navigationController, giphy: giphy, cacheService: cachedService)
        detailsCoordinator.start()
    }
    
    func getViewModel() -> GiphyViewModel { viewModel }
    
    func getCacheService() -> VideoCacheService { cachedService }
}
