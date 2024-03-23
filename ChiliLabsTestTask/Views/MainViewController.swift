import Foundation
import UIKit
import SwiftUI
import Combine

#Preview {
    MainViewController().preview
}

final class MainViewController: UIViewController {
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
        label.textColor = .systemRed
        label.isHidden = true
        
        return label
    }()
    
    private var searchTimer: Timer?
    private var viewModel: GiphyViewModel
    private var cancellables: Set<AnyCancellable> = []
    
    private let searchDelay: TimeInterval = 2
    private let horizontalOffset: CGFloat = 20.0
    private let collectionHorizontalOffset: CGFloat = 10
    private let cellIdentifier: String = "giphyCell"
    
    init() {
        self.viewModel = .init()
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

private extension MainViewController {
    func setupUI() {
        view.addSubviews(collectionView, searchBar)
        
        setupConstrains()
        setupSearchBar()
        setupCollectionView()
    }
    
    func setupConstrains() {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 50),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -horizontalOffset),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: horizontalOffset),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func setupCollectionView() {
        collectionView.register(GiphyViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func setupSearchBar() {
        searchBar.delegate = self
    }
}

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
            errorView.isHidden = true
            //TODO: add loading view
            break
        case .loaded:
            errorView.isHidden = true
            addLoadedGiphy()
        case .error(let message):
            errorView.isHidden = false
            errorView.text = message
            break
        }
    }
    
    func addLoadedGiphy() {
        let newIndexPaths = (viewModel.offset...viewModel.gifs.count - 1)
            .map { IndexPath(item: $0, section: 0) }
        
        collectionView.performBatchUpdates {
            collectionView.insertItems(at: newIndexPaths)
        }
    }
}

extension MainViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTimer?.invalidate()
        
        searchTimer = Timer.scheduledTimer(withTimeInterval: searchDelay, repeats: false) { [weak self] _ in
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! GiphyViewCell
        
        let gifURL = URL(string: viewModel.gifs[indexPath.item].images.fixedWidth.getLink())
        cell.configure(gifURL)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = viewModel.gifs[indexPath.item]
        let details = DetailsViewController(giphyData: data)
        
        navigationController?.pushViewController(details, animated: true)
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / 2 - 2 * collectionHorizontalOffset
        let size = CGSize(width: width, height: 150.0)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        2 * collectionHorizontalOffset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(
            top: 20,
            left: collectionHorizontalOffset,
            bottom: 0,
            right: collectionHorizontalOffset
        )
    }
}
