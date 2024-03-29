import UIKit
import SwiftUI

#Preview {
    let coordinator = DetailsCoordinator(
        UINavigationController(),
        giphy: .mockGiphy,
        cacheService: GiphyVideoCacheService()
    )
    
    return DetailsViewController(coordinator: coordinator).preview
}

final class DetailsViewController: UIViewController, UIScrollViewDelegate {
    private let scroll: UIScrollView = {
        let scroll = UIScrollView()
        scroll.isScrollEnabled = true
        scroll.showsVerticalScrollIndicator = false
        scroll.showsHorizontalScrollIndicator = false
        
        return scroll
    }()
    
    private let contentHolder: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 20
        
        return stack
    }()
    
    private let titleText: UILabel = {
        let view = UILabel()
        view.font = .preferredFont(forTextStyle: .title3).bold
        view.textAlignment = .left
        view.numberOfLines = 0
        view.textColor = AppColor.detailsText
        
        return view
    }()
    
    private let navigationView: DetailsNavigationBar = .init()
    private let giphyInfo: GiphyInfoView
    private let userInfo: UserInfoView
    
    private let giphyHeight: CGFloat
    private let giphyData: GiphyObject
    
    private let coordinator: DetailsCoordinatorProtocol
    
    init(coordinator: DetailsCoordinatorProtocol) {
        self.coordinator = coordinator
        self.giphyData = coordinator.getData()
        
        self.giphyInfo = .init(giphy: giphyData, cacheService: coordinator.getCacheService())
        self.userInfo = .init(user: giphyData.user)
        
        self.giphyHeight = CGFloat(
            giphyData.images.fixedWidth.getSize().height
        )
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateGradientFrame()
    }
}

private extension DetailsViewController {
    func setupUI() {
        addGradientBackground(colors: AppColor.backgroundGradient)
        view.addSubviews(navigationView, scroll)
        
        scroll.delegate = self
        scroll.addSubviews(contentHolder)
        contentHolder.addArrangedSubviews(titleText, giphyInfo, userInfo)
        
        setupConstraints()
        setDetails()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            navigationView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: UIConstants.horizontalPadding),
            navigationView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -UIConstants.horizontalPadding),
            navigationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            navigationView.heightAnchor.constraint(equalToConstant: 50),
            
            scroll.leadingAnchor.constraint(equalTo: navigationView.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: navigationView.trailingAnchor),
            scroll.topAnchor.constraint(equalTo: navigationView.bottomAnchor, constant: 5),
            scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentHolder.topAnchor.constraint(equalTo: scroll.topAnchor),
            contentHolder.bottomAnchor.constraint(equalTo: scroll.bottomAnchor),
            contentHolder.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
            contentHolder.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
            
            contentHolder.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor),
            
            titleText.leadingAnchor.constraint(equalTo: contentHolder.leadingAnchor, constant: UIConstants.horizontalPadding),
            titleText.trailingAnchor.constraint(equalTo: contentHolder.trailingAnchor, constant: -UIConstants.horizontalPadding),
            titleText.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),
            
            giphyInfo.leadingAnchor.constraint(equalTo: titleText.leadingAnchor),
            giphyInfo.trailingAnchor.constraint(equalTo: titleText.trailingAnchor),
            giphyInfo.heightAnchor.constraint(equalToConstant: giphyHeight),
            
            userInfo.leadingAnchor.constraint(equalTo: titleText.leadingAnchor),
            userInfo.trailingAnchor.constraint(equalTo: titleText.trailingAnchor),
            userInfo.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    func setDetails() {
        titleText.text = giphyData.title
        userInfo.isHidden = giphyData.user == nil
        
        navigationView.onBack = { [weak self] in
            self?.coordinator.pop()
        }
        
        navigationView.onShare = { [weak self] in
            guard let self = self, let url = URL(string: giphyData.url) else {
                return
            }
            
            self.coordinator.share([url as AnyObject])
        }
        
        navigationView.setupButtonAction()
    }
}
