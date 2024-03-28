import UIKit
import SwiftUI

#Preview {
    return DetailsNavigationBar().preview
}

final class DetailsNavigationBar: UIView {
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        button.tintColor = AppColor.navigation
        
        return button
    }()
    
    private let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.tintColor = AppColor.navigation
        
        return button
    }()
    
    var onBack: (() -> Void)?
    var onShare: (()-> Void)?
    
    init() {
        super.init(frame: .zero)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupButtonAction() {
        mapButton(backButton, action: onBackClick)
        mapButton(shareButton, action: onShareClick)
    }
}

private extension DetailsNavigationBar {
    func configureUI() {
        backgroundColor = .clear
        addSubviews(backButton, shareButton)
        
        backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        backButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        shareButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
        shareButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    func onBackClick() {
        onBack?()
    }
    
    func onShareClick() {
        onShare?()
    }
}
