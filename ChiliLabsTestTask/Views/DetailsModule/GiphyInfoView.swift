import Foundation
import UIKit
import SwiftUI

#Preview {
    ZStack {
        Color.mint
            .ignoresSafeArea()
        
        GiphyInfoView(giphy: .mockGiphy, cacheService: GiphyVideoCacheService())
            .preview
            .background(Color.blue)
            .frame(height: 200)
            .padding(.top, 20)
    }
}

final class GiphyInfoView: UIView {
    private let contentStack: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 20
        
        return view
    }()
    
    private let datesStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fillEqually
        view.alignment = .firstBaseline
        
        return view
    }()
    
    private let importDate: DateLabelView = .init()
    private let trendingDate: DateLabelView = .init()
    
    private lazy var giphyView: GiphyContentView = {
        let view = GiphyContentView(
            frame: CGRect(x: 0, y: 0, width: gifSize.width, height: gifSize.height),
            cacheService: cacheService,
            gifAspect: .resize
        )
        view.setShadow(radius: 10, color: AppColor.detailsText, opacity: 1)
        
        return view
    }()
    
    private let cacheService: VideoCacheService
    private let giphyData: GiphyObject
    private let gifSize: (width: Int, height: Int)
    
    init(giphy: GiphyObject, cacheService: VideoCacheService) {
        self.cacheService = cacheService
        self.giphyData = giphy
        self.gifSize = giphy.images.fixedWidth.getSize()
        super.init(frame: .zero)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension GiphyInfoView {
    func setupUI() {
        addSubviews(contentStack)
        
        contentStack.addArrangedSubviews(giphyView, datesStack)
        datesStack.addArrangedSubviews(importDate, trendingDate)
        
        setupConstraints()
        updateData()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            contentStack.topAnchor.constraint(equalTo: self.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            giphyView.widthAnchor.constraint(equalToConstant: CGFloat(gifSize.width)),
            giphyView.heightAnchor.constraint(equalToConstant: CGFloat(gifSize.height))
        ])
    }
    
    func updateData() {
        giphyView.updateData(using: giphyData.images.fixedWidth.getLink())
        
        trendingDate.isHidden = giphyData.trendingDate.isEmpty
        importDate.isHidden = giphyData.importDate.isEmpty
        
        let importString = giphyData.importDate.toPublsihedDate()
        let trendingString = giphyData.trendingDate.toPublsihedDate()
        
        if !trendingString.isEmpty {
            trendingDate.updateText(
                with: "Trending:",
                date: trendingString
            )
        }
        
        if !importString.isEmpty {
            importDate.updateText(
                with: "Imported:",
                date: importString
            )
        }
    }
}
