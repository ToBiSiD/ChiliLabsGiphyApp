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
    
    private let giphyLayer: AVPlayerLayer = {
        let layer = AVPlayerLayer()
        layer.videoGravity = .resizeAspectFill
        
        return layer
    }()
    
    private var cacheService: VideoCacheService?
    private var cancellables = Set<AnyCancellable>()
    private var isActive: Bool = false
    
    init(frame: CGRect, cacheService: VideoCacheService? = nil, gifAspect: AVLayerVideoGravity = .resizeAspectFill) {
        self.cacheService = cacheService
        giphyLayer.videoGravity = gifAspect
        super.init(frame: frame)
        
        setupUI()
        subscribeOnApplicationState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        cleanUp()
    }
}

//MARK: - Public methods
extension GiphyContentView {
    func setCachedService(_ cachedService: VideoCacheService?) {
        if self.cacheService == nil {
            self.cacheService = cachedService
        }
    }
    
    func updateData(using url: String) {
        loadVideo(from: url)
    }
    
    func changeActive(_ isActive: Bool = true) {
        self.isActive = isActive
        if self.isActive {
            resumeGiphy()
        } else {
            pauseGiphy()
        }
    }
    
    func resetData() {
        cleanUp()
        resetViews()
    }
}

//MARK: - Setup UI
private extension GiphyContentView {
    func setupUI() {
        addSubviews(placeholderView, videoContainerView)
        placeholderView.addSubviews(spinnerView, loadErrorText)
        
        setupConstrains()
        setupGiphyView()
    }
    
    func setupGiphyView() {
        giphyLayer.frame = bounds
        videoContainerView.layer.addSublayer(giphyLayer)
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
    
    func replayGiphy() {
        giphyLayer.player?.seek(to: .zero)
        giphyLayer.player?.play()
    }
    
    func cleanGiphy() {
        giphyLayer.player?.pause()
        giphyLayer.player = nil
    }
    
    func playGiphy() {
        hideError()
        videoContainerView.isHidden = false
        replayGiphy()
    }
    
    func hideError(stopSpinner: Bool = true) {
        if stopSpinner {
            spinnerView.stopAnimating()
        }
        
        loadErrorText.isHidden = true
    }
    
    func showError() {
        videoContainerView.isHidden = true
        cleanGiphy()
        spinnerView.stopAnimating()
        loadErrorText.isHidden = false
    }
}

//MARK: - Subscription logic 
private extension GiphyContentView {
    func cleanUp() {
        cleanGiphy()
        cancellables.forEach { $0.cancel() }
    }
    
    func loadVideo(from url: String) {
        cacheService?.loadVideo(from: url)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(_):
                    self.showError()
                }
            } receiveValue: { result in
                self.isActive = true
                self.handleLoadingAVAsset(result)
            }
            .store(in: &cancellables)
    }
    
    func handleLoadingAVAsset(_ asset: AVAsset?) {
        guard let asset = asset else {
            showError()
            return
        }
        
        let item = AVPlayerItem(asset: asset)
        
        if self.giphyLayer.player == nil {
            self.giphyLayer.player = AVPlayer(playerItem: item)
        } else {
            self.giphyLayer.player?.replaceCurrentItem(with: item)
        }
        
        self.subscribeOnPlayer(player: self.giphyLayer.player)
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
                self?.replayGiphy()
            }
            .store(in: &cancellables)
    }
    
    func subscribeOnApplicationState() {
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.resumeGiphy()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { [weak self] _ in
                if self?.isActive ?? true {
                    self?.pauseGiphy()
                }
            }
            .store(in: &cancellables)
    }
    
    func handlePlayerStatusChange(_ status: AVPlayerItem.Status) {
        switch status {
        case .readyToPlay:
            playGiphy()
        case .failed:
            showError()
        case .unknown:
            hideError(stopSpinner: false)
        @unknown default:
            fatalError("Unhandled AVPlayerItem status")
        }
    }
    
    func resumeGiphy() {
        if let player = giphyLayer.player, isActive {
            DebugLogger.printLog("Play player", type: .action)
            player.play()
        }
    }
    
    func pauseGiphy() {
        if let player = giphyLayer.player {
            DebugLogger.printLog("Pause player", type: .action)
            player.pause()
        }
    }
}
