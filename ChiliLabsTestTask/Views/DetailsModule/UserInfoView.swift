import UIKit
import SwiftUI

#Preview {
    UserInfoView(user: GiphyObject.mockGiphy.user).preview
}

final class UserInfoView: UIView {
    private let profileRedirectButton: UIButton = {
        let button = UIButton(type: .system)
        button.setCornerRadius(20)
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemGray3.cgColor
        
        return button
    }()
    
    private let avatarView: UIImageView = {
        let avatar = UIImageView()
        avatar.contentMode = .scaleAspectFill
        avatar.setCornerRadius(20)
        avatar.clipsToBounds = true
        
        return avatar
    }()
    
    private let userName: UILabel = {
        let name = UILabel()
        name.font = .preferredFont(forTextStyle: .body).boldItalic
        name.textAlignment = .left
        name.numberOfLines = 2
        
        return name
    }()
    
    private let user: User?
    
    init(user: User?) {
        self.user = user
        super.init(frame: .zero)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension UserInfoView {
    func setupUI() {
        addSubviews(profileRedirectButton)
        profileRedirectButton.addSubviews(avatarView, userName)
        
        setupConstraints()
        updateData()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            profileRedirectButton.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            profileRedirectButton.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            profileRedirectButton.topAnchor.constraint(equalTo: self.topAnchor),
            profileRedirectButton.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            avatarView.leadingAnchor.constraint(equalTo: profileRedirectButton.leadingAnchor, constant: 10),
            avatarView.centerYAnchor.constraint(equalTo: profileRedirectButton.centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 40),
            avatarView.heightAnchor.constraint(equalToConstant: 40),
            
            userName.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 10),
            userName.trailingAnchor.constraint(equalTo: profileRedirectButton.trailingAnchor, constant: -10),
            userName.topAnchor.constraint(equalTo: self.topAnchor),
            userName.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    func updateData() {
        guard let user = user else {
            return
        }
        
        tryLoadImage(for: user.avatarURL)
        userName.text = user.displayName
        
        mapButton(profileRedirectButton) { [weak self] in
            if let url = URL(string: self?.user?.profileURL ?? "") {
                UIApplication.shared.open(url)
            }
        }
        
    }
    
    func tryLoadImage(for urlString: String) {
        guard let url = URL(string: urlString) else {
            avatarView.isHidden = true
            return
        }
        
        avatarView.isHidden = false
        avatarView.load(url: url)
    }
}
