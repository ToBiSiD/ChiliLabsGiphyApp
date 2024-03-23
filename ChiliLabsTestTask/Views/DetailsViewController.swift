import UIKit
import SwiftUI

#Preview {
    DetailsViewController(giphyData: .mockGiphy).preview
}

final class DetailsViewController: UIViewController {
    private let titleText: UILabel = {
        let view = UILabel()
        view.font = .preferredFont(forTextStyle: .title3)
        view.textAlignment = .left
        view.textColor = .white
        view.numberOfLines = 0
        
        return view
    }()
    
    private lazy var giphyView: GiphyContentView = {
        let view = GiphyContentView(
            CGRect(x: 0, y: 0, width: gifSize.width, height: gifSize.height),
            gifAspect: .resize
        )
        
        return view
    }()
    
    private let gifSize: (width: Int, height: Int)
    private let giphyData: GiphyObject
    
    init(giphyData: GiphyObject) {
        self.giphyData = giphyData
        self.gifSize = giphyData.images.fixedWidth.getSize()
        
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
        view.addSubviews(titleText, giphyView)
        
        setupConstrains()
        setDetails()
    }
    
    func setupConstrains() {
        NSLayoutConstraint.activate([
            titleText.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            titleText.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            titleText.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleText.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),
            
            giphyView.leadingAnchor.constraint(equalTo: titleText.leadingAnchor),
            giphyView.topAnchor.constraint(equalTo: titleText.bottomAnchor, constant: 20),
            giphyView.widthAnchor.constraint(equalToConstant: CGFloat(gifSize.width)),
            giphyView.heightAnchor.constraint(equalToConstant: CGFloat(gifSize.height))
            
            ])
    }
    
    func setDetails() {
        titleText.text = giphyData.title
        giphyView.configure(URL(string: giphyData.images.fixedWidth.getLink()))
    }
}
