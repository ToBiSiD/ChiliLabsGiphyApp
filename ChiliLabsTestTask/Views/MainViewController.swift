import Foundation
import UIKit
import SwiftUI
import Combine

#Preview {
    MainViewController.preview
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
    
    private var searchTimer: Timer?
    private var viewModel: GiphyViewModel
    private var cancellables: Set<AnyCancellable> = []
    private let searchDelay: TimeInterval = 0.5
    private let horizontalOffset: CGFloat = 20.0
    private let collectionHorizontalOffset: CGFloat = 10
    
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
        collectionView.register(GiphyViewCell.self, forCellWithReuseIdentifier: "giphyCell")
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func setupSearchBar() {
        searchBar.delegate = self
    }
}

private extension MainViewController {
    func setupViewModel() {
        viewModel.$gifs
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.updateGifs()
            }
            .store(in: &cancellables)
    }
    
    func updateGifs() {
        collectionView.reloadData()
    }
}

extension MainViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchTimer?.invalidate()
        
        searchTimer = Timer.scheduledTimer(withTimeInterval: searchDelay, repeats: false) { [weak self] _ in
            guard let query = searchBar.text else { return }
            self?.updateGifs()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchTimer?.invalidate()
        
        guard let query = searchBar.text else { return }
        
        updateGifs()
        searchBar.resignFirstResponder()
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / 2 - 2 * collectionHorizontalOffset
        let size = CGSize(width: width, height: 150.0)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(
            top: 20,
            left: collectionHorizontalOffset,
            bottom: 0,
            right: collectionHorizontalOffset
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.gifs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "giphyCell", for: indexPath) as! GiphyViewCell
        
        let gifURL = URL(string: viewModel.gifs[indexPath.item].images.original.getLink() ?? "")
        cell.configure(gifURL)
        return cell
    }
    
    
}
