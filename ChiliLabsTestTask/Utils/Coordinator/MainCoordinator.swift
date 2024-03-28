import Foundation
import UIKit

final class MainCoordinator: Coordinator {
    private let navigationController: UINavigationController
    private let viewModel: GiphyViewModel
    
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.viewModel = .init()
    }
    
    func start() {
        let mainVC: MainViewController = .init(coordinator: self)
        
        navigationController.pushViewController(mainVC, animated: true)
    }
    
    func openDetails(for giphy: GiphyObject) {
        let detailsCoordinator: DetailsCoordinator = .init(navigationController, giphy: giphy)
        detailsCoordinator.start()
    }
    
    func getViewModel() -> GiphyViewModel { viewModel }
}
