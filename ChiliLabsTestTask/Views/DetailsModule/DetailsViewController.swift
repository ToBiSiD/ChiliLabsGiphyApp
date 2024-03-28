import UIKit
import SwiftUI

#Preview {
    let coordinator = DetailsCoordinator(
        UINavigationController(),
        giphy: .mockGiphy
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
        
        return view
    }()
    
    private let navigationView: DetailsNavigationBar = .init()
    private let giphyInfo: GiphyInfoView
    private let userInfo: UserInfoView
    
    private let giphyHeight: CGFloat
    private let giphyData: GiphyObject
    
    private let coordinator: DetailsCoordinator
    
    init(coordinator: DetailsCoordinator) {
        self.coordinator = coordinator
        self.giphyData = coordinator.getData()
        
        self.giphyInfo = .init(giphy: giphyData)
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
}

private extension DetailsViewController {
    func setupUI() {
        scroll.delegate = self
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        view.addSubviews(scroll)
        scroll.addSubviews(contentHolder)
        contentHolder.addArrangedSubviews(navigationView, titleText, giphyInfo, userInfo)
        
        setupConstraints()
        setDetails()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            scroll.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentHolder.topAnchor.constraint(equalTo: scroll.topAnchor),
            contentHolder.bottomAnchor.constraint(equalTo: scroll.bottomAnchor),
            contentHolder.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
            contentHolder.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
            
            contentHolder.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor),
            
            navigationView.leadingAnchor.constraint(equalTo: contentHolder.leadingAnchor, constant: 10),
            navigationView.trailingAnchor.constraint(equalTo: contentHolder.trailingAnchor, constant: -10),
            navigationView.heightAnchor.constraint(equalToConstant: 50),
            
            titleText.leadingAnchor.constraint(equalTo: contentHolder.leadingAnchor, constant: 20),
            titleText.trailingAnchor.constraint(equalTo: contentHolder.trailingAnchor, constant: -20),
            titleText.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),
            
            giphyInfo.leadingAnchor.constraint(equalTo: contentHolder.leadingAnchor, constant: 20),
            giphyInfo.trailingAnchor.constraint(equalTo: contentHolder.trailingAnchor, constant: -20),
            giphyInfo.heightAnchor.constraint(equalToConstant: giphyHeight),
            
            userInfo.leadingAnchor.constraint(equalTo: giphyInfo.leadingAnchor, constant: 10),
            userInfo.trailingAnchor.constraint(equalTo: giphyInfo.trailingAnchor, constant: -10),
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
