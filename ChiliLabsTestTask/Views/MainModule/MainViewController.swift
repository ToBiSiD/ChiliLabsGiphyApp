import Foundation
import UIKit
import SwiftUI
import Combine

#Preview {
    let coordinator = MainCoordinator(UINavigationController())
    
    return MainViewController(coordinator: coordinator).preview
}

final class MainViewController: UIViewController {
    private let contentControl = UISegmentedControl()
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let searchBar = UISearchBar()
    private let spinnerView = UIActivityIndicatorView(style: .large)
    
    private var viewModel: GiphyViewModel
    private var coordinator: MainCoordinatorProtocol
    private var cancellables: Set<AnyCancellable> = []
    
    private var cellShadow: UIBezierPath?
    private var cellSize: CGFloat?
    private var searchTimer: Timer?
    
    init(coordinator: MainCoordinatorProtocol) {
        self.coordinator = coordinator
        self.viewModel = coordinator.getViewModel()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateGradientFrame()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        changeGiphysStates(isPlay: true)
    }
}

//MARK: - UI Setup
private extension MainViewController {
    func setupUI() {
        addGradientBackground(colors: AppColor.backgroundGradient)
        view.addSubviews(searchBar, contentControl, collectionView, spinnerView)
        
        setupContentControl()
        setupSearchBar()
        setupCollectionView()
        setupSpinnerView()
        
        setupConstrains()
        setupTapGesture()
    }
    
    func setupConstrains() {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 50),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -UIConstants.horizontalPadding),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: UIConstants.horizontalPadding),
            
            contentControl.topAnchor.constraint(equalTo: searchBar.bottomAnchor,constant: UIConstants.collectionSpacing),
            contentControl.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor, constant: UIConstants.horizontalPadding),
            contentControl.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor, constant: -UIConstants.horizontalPadding),
            contentControl.heightAnchor.constraint(equalToConstant: 30),
            
            collectionView.topAnchor.constraint(equalTo: contentControl.bottomAnchor, constant: UIConstants.collectionSpacing),
            collectionView.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            spinnerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinnerView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func setupCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.register(GiphyViewCell.self, forCellWithReuseIdentifier: UIConstants.giphyCellId)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func setupSearchBar() {
        let color = AppColor.detailsText
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        searchBar.searchTextField.leftView?.tintColor = color.withAlphaComponent(0.4)
        searchBar.searchTextField.textColor = color
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Search giphy",
            attributes: [ .foregroundColor : color.withAlphaComponent(0.4) ]
        )
        
        searchBar.delegate = self
    }
    
    func setupSpinnerView() {
        spinnerView.color = AppColor.spinner
    }
    
    func setupContentControl() {
        contentControl.insertSegment(withTitle: ContentType.gif.title, at: 0, animated: false)
        contentControl.insertSegment(withTitle: ContentType.stiker.title, at: 1, animated: false)
        contentControl.selectedSegmentIndex = 0
        contentControl.selectedSegmentTintColor = AppColor.shadow
        contentControl.backgroundColor = .clear
        contentControl.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
        contentControl.setTitleTextAttributes([.foregroundColor: AppColor.detailsText], for: .normal)
        mapSegmentedControl(contentControl, action: onContentTypeChanged)
    }
    
    func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
}

private extension MainViewController {
    func changeSpinnerState(isPlay: Bool = true) {
        spinnerView.isHidden = !isPlay
        if isPlay {
            spinnerView.startAnimating()
        } else {
            spinnerView.stopAnimating()
        }
    }
    
    func showErrorView(with message: String) {
        changeSpinnerState(isPlay: false)
        coordinator.showError(with: message, onDismiss: nil)
    }
    
    func updateContentState() {
        changeSpinnerState(isPlay: true)
        viewModel.clearData()
        collectionView.reloadData()
    }
}

//MARK: - Subscriptions and UIState changes
private extension MainViewController {
    func setupViewModel() {
        viewModel.$dataState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleDataStateChange(state)
            }
            .store(in: &cancellables)
    }
    
    func handleDataStateChange(_ state: DataState) {
        switch state {
        case .idle:
            changeSpinnerState(isPlay: true)
        case .loaded:
            addLoadedGiphy()
        case .error(let message):
            showErrorView(with: message)
        }
    }
    
    func onContentTypeChanged() {
        updateContentState()
        
        switch contentControl.selectedSegmentIndex {
        case 0:
            viewModel.tryChangeContentType(.gif)
        case 1:
            viewModel.tryChangeContentType(.stiker)
        default:
            break
        }
    }
    
    func addLoadedGiphy() {
        changeSpinnerState(isPlay: false)
        
        let newIndexPaths = (viewModel.offset...viewModel.gifs.count - 1)
            .map { IndexPath(item: $0, section: 0) }
        
        collectionView.performBatchUpdates {
            collectionView.insertItems(at: newIndexPaths)
        }
    }
}

//MARK: - Implement Search delegate
extension MainViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTimer?.invalidate()
        
        searchTimer = Timer.scheduledTimer(withTimeInterval: UIConstants.searchDelay, repeats: false) { [weak self] _ in
            guard let query = searchBar.text else { return }
            
            self?.search(for: query)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchTimer?.invalidate()
        
        guard let query = searchBar.text else { return }
        
        search(for: query)
        searchBar.resignFirstResponder()
    }
    
    func search(for query: String) {
        updateContentState()
        viewModel.search(for: query)
    }
}

//MARK: - Implement Collections' delegates
extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == collectionView.numberOfItems(inSection: indexPath.section) - 1 {
            viewModel.tryFecthNext()
        }
    }
    
    func changeGiphysStates(isPlay: Bool = true) {
        for indexPath in collectionView.indexPathsForVisibleItems {
            if let cell = collectionView.cellForItem(at: indexPath) as? GiphyViewCell {
                cell.changeGiphyState(isPlay: isPlay)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.gifs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UIConstants.giphyCellId, for: indexPath) as? GiphyViewCell else {
            fatalError("Failed to dequeue GiphyViewCell")
        }

        configureCell(cell, with: indexPath.item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        changeGiphysStates(isPlay: false)
        let data = viewModel.gifs[indexPath.item]
        
        coordinator.openDetails(for: data)
    }
    
    func configureCell(_ cell: GiphyViewCell, with index: Int) {
        if cellShadow == nil {
            DebugLogger.printLog("Create cell Shadow", type: .action)
            cellShadow = UIBezierPath(rect: cell.bounds)
        }
        
        let link = viewModel.gifs[index].images.fixedWidth.getLink()
        cell.setShadow(
            radius: 10,
            color: AppColor.shadow,
            opacity: 1,
            using: cellShadow?.cgPath
        )
        
        cell.configure(
            using: coordinator.getCacheService(),
            with: link
        )
    }
}

//MARK: - Implement CollectionFlowLayout
extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let cellSize = cellSize else {
            let size = UIConstants.calculateCellSize(for: UIConstants.cellInRow, with: UIConstants.collectionSpacing * 4)
            self.cellSize = size
            return CGSize(width: size, height: size)
        }
        
        return CGSize(width: cellSize, height: cellSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        2 * UIConstants.collectionSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(
            top: 20,
            left: UIConstants.collectionSpacing,
            bottom: 0,
            right: UIConstants.collectionSpacing
        )
    }
}
