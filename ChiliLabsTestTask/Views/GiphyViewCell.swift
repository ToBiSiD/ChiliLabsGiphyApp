//
//  GiphyViewCell.swift
//  ChiliLabsTestTask
//
//  Created by Tobias on 21.03.2024.
//

import Foundation
import UIKit
import SwiftUI
import AVKit
import Combine

#Preview {
    let cell = GiphyViewCell()
    
    return cell.preview
        .frame(
            width: UIScreen.main.bounds.width/2,
            height: UIScreen.main.bounds.width/2
        )
        .foregroundStyle(.black)
    
}

final class GiphyViewCell: UICollectionViewCell {
    private let placeholderView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray
        view.setCornerRadius(20)
        view.setShadow(radius: 5, color: .black, opacity: 1)
        
        return view
    }()
    
    private let spinnerView: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .yellow
        
        return spinner
    }()
    
    private let videoContainerView: UIView = {
        let view = UIView()
        view.setCornerRadius(20)
        
        return view
    }()
    
    private let gifLayer: AVPlayerLayer = {
        let layer = AVPlayerLayer()
        layer.videoGravity = .resizeAspectFill
        
        return layer
    }()
    
    private var cancellables = Set<AnyCancellable>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        configure()

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ gifLink: URL? = nil) {
        if let url = gifLink {
            spinnerView.stopAnimating()
            let player = AVPlayer(url: url)
            gifLayer.player = player
            NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
                .sink { [weak self] _ in
                    self?.playerDidFinishPlaying()
                }
                .store(in: &cancellables)
            
            player.play()
            videoContainerView.isHidden = false
        } else {
            spinnerView.startAnimating()
            videoContainerView.isHidden = true
        }
    }
}

private extension GiphyViewCell {
    func setupUI() {
        addSubviews(placeholderView, videoContainerView)
        placeholderView.addSubviews(spinnerView)
        
        setupConstrains()
        setupGifView()
    }
    
    func setupGifView() {
        gifLayer.frame = bounds
        videoContainerView.layer.addSublayer(gifLayer)
        videoContainerView.layer.masksToBounds = true
    }
    
    func setupConstrains() {
        NSLayoutConstraint.activate([
            placeholderView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            placeholderView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            placeholderView.topAnchor.constraint(equalTo: self.topAnchor),
            placeholderView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            videoContainerView.leadingAnchor.constraint(equalTo: placeholderView.leadingAnchor),
            videoContainerView.trailingAnchor.constraint(equalTo: placeholderView.trailingAnchor),
            videoContainerView.topAnchor.constraint(equalTo: self.topAnchor),
            videoContainerView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            spinnerView.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor),
            spinnerView.centerYAnchor.constraint(equalTo: placeholderView.centerYAnchor)
        ])
    }
    
    func playerDidFinishPlaying() {
        gifLayer.player?.seek(to: .zero)
        gifLayer.player?.play()
    }
}
