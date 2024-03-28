import UIKit
import SwiftUI
import AVKit
import Combine

final class GiphyContentView: UIView {
    private let placeholderView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColor.giphyBack
        view.setCornerRadius(20)
        
        return view
    }()
    
    private let spinnerView: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = AppColor.spinner
        
        return spinner
    }()
    
    private let loadErrorText: UILabel = {
        let text = UILabel()
        text.text = "Loading error"
        text.font = .preferredFont(forTextStyle: .body)
        text.textColor = AppColor.error
        text.isHidden = true
        
        return text
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
    
    convenience init(_ frame: CGRect, gifAspect: AVLayerVideoGravity = .resizeAspectFill) {
        self.init(frame: frame)
        gifLayer.videoGravity = gifAspect
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        configure()
        subscribeOnApplicationState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        cleanUp()
    }
    
    func configure(_ gifLink: URL? = nil) {
        guard let url = gifLink else {
            resetViews()
            return
        }
        tryPlayGif(url)
    }
    
    func stopGiphy() {
        gifLayer.player?.pause()
    }
    
    func prepareForReuse() {
        gifLayer.player?.pause()
        gifLayer.player?.replaceCurrentItem(with: nil)
        resetViews()
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
    
    func resetViews() {
        loadErrorText.isHidden = true
        spinnerView.startAnimating()
        videoContainerView.isHidden = true
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
        if gifLayer.player == nil {
            let player = AVPlayer(url: url)
            gifLayer.player = player
        } else {
            gifLayer.player?.replaceCurrentItem(with: AVPlayerItem(url: url))
        }
        
        subscribeOnPlayer(player: gifLayer.player)
    }
    
    func subscribeOnPlayer(player: AVPlayer?) {
        guard let player = player else { return }
        
        player.currentItem?.publisher(for: \.status)
            .sink { [weak self] status in
                self?.handlePlayerStatusChange(status)
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object:  player.currentItem)
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
    func cleanUp() {
        cancellables.forEach { $0.cancel() }
        gifLayer.player?.pause()
        gifLayer.player?.replaceCurrentItem(with: nil)
    }
    
    func subscribeOnApplicationState() {
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.applicationDidBecomeActive()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { [weak self] _ in
                self?.applicationDidEnterBackground()
            }
            .store(in: &cancellables)
    }
    
    func handlePlayerStatusChange(_ status: AVPlayerItem.Status) {
        switch status {
        case .readyToPlay:
            videoContainerView.isHidden = false
            spinnerView.stopAnimating()
            gifLayer.player?.play()
        case .failed:
            spinnerView.stopAnimating()
            loadErrorText.isHidden = false
        case .unknown:
            loadErrorText.isHidden = true
        @unknown default:
            fatalError("Unhandled AVPlayerItem status")
        }
    }
    
    func applicationDidBecomeActive() {
        if let player = gifLayer.player {
            DebugLogger.printLog("Play player", type: .action)
            player.play()
        }
    }
    
    func applicationDidEnterBackground() {
        if let player = gifLayer.player {
            DebugLogger.printLog("Pause player", type: .action)
            player.pause()
        }
    }
}
