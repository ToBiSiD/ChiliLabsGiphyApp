import Foundation
import UIKit
import SwiftUI
import AVKit
import Combine

#Preview {
    let cell = GiphyViewCell()
    
    return cell.preview
        .frame(
            width: 100,
            height: 100
        )
        .foregroundStyle(.black)
}

final class GiphyViewCell: UICollectionViewCell {
    private let giphyView: GiphyContentView
    
    override init(frame: CGRect) {
        self.giphyView = .init(frame: frame)
        super.init(frame: frame)
        
        setupUI()
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ gifLink: URL? = nil) {
        giphyView.configure(gifLink)
    }
}

private extension GiphyViewCell {
    func setupUI() {
        addSubviews(giphyView)
        
        setupConstrains()
    }
    
    func setupConstrains() {
        NSLayoutConstraint.activate([
            giphyView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            giphyView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            giphyView.topAnchor.constraint(equalTo: self.topAnchor),
            giphyView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
