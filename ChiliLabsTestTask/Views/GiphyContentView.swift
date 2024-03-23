import UIKit
import SwiftUI
import AVKit
import Combine

final class GiphyContentView: UIView {
    private let placeholderView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray3
        view.setCornerRadius(20)
        view.setShadow(radius: 10, color: .systemGray, opacity: 1)
        
        return view
    }()
    
    private let spinnerView: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .yellow
        
        return spinner
    }()
    
    private let loadErrorText: UILabel = {
        let text = UILabel()
        text.text = "Loading error"
        text.font = .preferredFont(forTextStyle: .body)
        text.textColor = .systemRed
        text.isHidden = true
        
        return text
    }()
    
    private let videoContainerView: UIView = {
        let view = UIView()
        view.setCornerRadius(20)
        view.setShadow(radius: 10, color: .systemGray, opacity: 1)
        
        return view
    }()
    
    private let gifLayer: AVPlayerLayer = {
        let layer = AVPlayerLayer()
        layer.videoGravity = .resizeAspectFill
        
        return layer
    }()
    
    private var cancellables = Set<AnyCancellable>()
    
    convenience init(_ frame: CGRect, gifAspect: AVLayerVideoGravity = .resizeAspectFill) {
        self.init(frame: frame)
        gifLayer.videoGravity = gifAspect
    }
    
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
            tryPlayGif(url)
        } else {
            loadErrorText.isHidden = true
            spinnerView.startAnimating()
            videoContainerView.isHidden = true
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            handleAVPlayerItemStatusChanges(change)
        }
    }
}

private extension GiphyContentView {
    func setupUI() {
        addSubviews(placeholderView, videoContainerView)
        placeholderView.addSubviews(spinnerView, loadErrorText)
        
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
            spinnerView.centerYAnchor.constraint(equalTo: placeholderView.centerYAnchor),
            
            loadErrorText.centerYAnchor.constraint(equalTo: placeholderView.centerYAnchor),
            loadErrorText.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor)
        ])
    }
    
    func tryPlayGif(_ url: URL) {
        let player = AVPlayer(url: url)
        gifLayer.player = player
        
        player.currentItem?.addObserver(self, forKeyPath: "status", options: [.new, .initial], context: nil)
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
            .sink { [weak self] _ in
                self?.playerDidFinishPlaying()
            }
            .store(in: &cancellables)
    }
    
    func playerDidFinishPlaying() {
        gifLayer.player?.seek(to: .zero)
        gifLayer.player?.play()
    }
}


private extension GiphyContentView {
    func handleAVPlayerItemStatusChanges(_ change: [NSKeyValueChangeKey : Any]?) {
        if let statusNumber = change?[.newKey] as? NSNumber,
           let status = AVPlayerItem.Status(rawValue: statusNumber.intValue) {
            switch status {
            case .readyToPlay:
                gifLayer.player?.play()
                videoContainerView.isHidden = false
                spinnerView.stopAnimating()
            case .failed:
                spinnerView.stopAnimating()
                loadErrorText.isHidden = false
            case .unknown:
                loadErrorText.isHidden = true
                break
            @unknown default:
                fatalError("Unhandled AVPlayerItem status")
            }
        }
    }
}
