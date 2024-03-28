import Foundation
import UIKit
import SwiftUI
import Combine

#Preview {
    let coordinator = MainCoordinator(UINavigationController())
    
    return MainViewController(coordinator: coordinator).preview
}

final class MainViewController: UIViewController {
    private let containerView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 20
        
        return view
    }()
    
    private let contentControl: UISegmentedControl = {
        let segmented: UISegmentedControl = .init(items: [
            ContentType.gif.rawValue,
            ContentType.stiker.rawValue
        ])
        segmented.selectedSegmentIndex = 0
        segmented.selectedSegmentTintColor = .systemMint
        
        return segmented
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        
        return view
    }()
    
    private let searchBar: UISearchBar = {
        let view = UISearchBar()
        view.placeholder = "Search gif"
        
        return view
    }()
    
    private let errorView: UILabel = {
        let label = UILabel()
        label.text = "Loading error"
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = AppColor.error
        label.isHidden = true
        
        return label
    }()
    
    private var searchTimer: Timer?
    private var viewModel: GiphyViewModel
    private var cancellables: Set<AnyCancellable> = []
    
    private var cellShadow: UIBezierPath?
    private var cellSize: CGFloat?
    
    private var coordinator: MainCoordinator
    
    init(coordinator: MainCoordinator) {
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
}

//MARK: - UI Setup
private extension MainViewController {
    func setupUI() {
        view.addSubviews(containerView, searchBar, contentControl)
        containerView.addArrangedSubviews(errorView, collectionView)
        
        setupContentControl()
        setupConstrains()
        setupSearchBar()
        setupCollectionView()
        setupTapGesture()
    }
    
    func setupConstrains() {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 50),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -UIConstants.horizontalPadding),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: UIConstants.horizontalPadding),
            
            contentControl.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            contentControl.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor),
            contentControl.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor),
            contentControl.heightAnchor.constraint(equalToConstant: 30),
            
            containerView.topAnchor.constraint(equalTo: contentControl.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            errorView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func setupCollectionView() {
        collectionView.register(GiphyViewCell.self, forCellWithReuseIdentifier: UIConstants.giphyCellId)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func setupSearchBar() {
        searchBar.delegate = self
    }
    
    func setupContentControl() {
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
            hideErrorView()
        case .loaded:
            hideErrorView()
            addLoadedGiphy()
        case .error(let message):
            showErrorView(with: message)
        }
    }
    
    func onContentTypeChanged() {
        viewModel.clearData()
        collectionView.reloadData()
        switch contentControl.selectedSegmentIndex {
        case 0:
            viewModel.tryChangeContentType(.gif)
        case 1:
            viewModel.tryChangeContentType(.stiker)
        default:
            break
        }
    }
    
    func showErrorView(with message: String) {
        errorView.isHidden = false
        errorView.text = message
    }
    
    func hideErrorView() {
        errorView.isHidden = true
    }
    
    func addLoadedGiphy() {
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
        viewModel.clearData()
        collectionView.reloadData()
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.gifs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UIConstants.giphyCellId, for: indexPath) as? GiphyViewCell else {
            fatalError("Failed to dequeue GiphyViewCell")
        }
        
        if cellShadow == nil {
            DebugLogger.printLog("Create cell Shadow", type: .action)
            cellShadow = UIBezierPath(rect: cell.bounds)
        }
        
        cell.setShadow(radius: 10, color: AppColor.shadow, opacity: 1, using: cellShadow?.cgPath)
        
        let gifURL = URL(string: viewModel.gifs[indexPath.item].images.fixedWidth.getLink())
        cell.configure(gifURL)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = viewModel.gifs[indexPath.item]
        
        coordinator.openDetails(for: data)
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
