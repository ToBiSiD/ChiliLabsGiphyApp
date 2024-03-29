import Foundation
import UIKit
import SwiftUI

#Preview {
    PopupErrorViewController(with: "Error test description").preview
}

final class PopupErrorViewController: UIViewController {
    private let containerView: UIView = {
        let view = UIView()
        view.setCornerRadius(20)
        view.setBorder(width: 4, color: AppColor.giphyBack)
        view.setShadow(radius: 10, color: AppColor.shadow, opacity: 1)
        
        return view
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = AppColor.error
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .body).bold
        
        return label
    }()
    
    private let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Dismiss", for: .normal)
        button.setTitleColor(AppColor.detailsText, for: .normal)
        
        button.setCornerRadius(15)
        button.setBorder(width: 2, color: AppColor.giphyBack)
        button.backgroundColor = AppColor.shadow
        
        return button
    }()
    
    private var errorMessage: String
    private var onDismiss: (() -> Void)?
    
    init(with errorMessage: String, onDismiss: (() -> Void)? = nil) {
        self.onDismiss = onDismiss
        self.errorMessage = errorMessage
        
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        containerView.addGradientBackground(colors: AppColor.backgroundGradient, with: 20)
    }
}

private extension PopupErrorViewController {
    func setupUI() {
        view.backgroundColor = .black.withAlphaComponent(0.6)
        view.addSubviews(containerView)
        containerView.addSubviews(errorLabel, dismissButton)
        
        setupConstraints()
        mapButton(dismissButton, action: pop)
        updateData()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: UIConstants.errorSize.width),
            containerView.heightAnchor.constraint(equalToConstant: UIConstants.errorSize.height),
            
            errorLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: UIConstants.horizontalPadding),
            errorLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: UIConstants.horizontalPadding),
            errorLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -UIConstants.horizontalPadding),
            
            dismissButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: UIConstants.horizontalPadding),
            dismissButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -UIConstants.horizontalPadding),
            dismissButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: UIConstants.collectionSpacing),
            dismissButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -UIConstants.collectionSpacing),
            dismissButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func updateData() {
        errorLabel.text = errorMessage
    }
    
    func pop() {
        dismiss(animated: true)
        onDismiss?()
    }
}
