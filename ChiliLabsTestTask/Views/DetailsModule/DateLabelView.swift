import UIKit
import SwiftUI

#Preview {
    let details = DateLabelView()
    details.updateText(with: "Imported:", date: "24 march")
    
    return details.preview
}

final class DateLabelView: UIView {
    private let titleText: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body).bold
        label.textColor = .label
        label.textAlignment = .left
        
        return label
    }()
    
    private let dateText: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1).boldItalic
        label.textColor = .label
        label.textAlignment = .left
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateText(with title: String, date: String) {
        update(title, date: date)
    }
}

private extension DateLabelView {
    func setupUI() {
        addSubviews(titleText, dateText)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            titleText.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            titleText.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            titleText.topAnchor.constraint(equalTo: self.topAnchor),
            titleText.heightAnchor.constraint(lessThanOrEqualToConstant: 70),
            
            dateText.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            dateText.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            dateText.topAnchor.constraint(equalTo: titleText.bottomAnchor, constant: 20),
            dateText.heightAnchor.constraint(lessThanOrEqualToConstant: 70)
        ])
    }
    
    func update(_ title: String, date: String) {
        dateText.text = date
        titleText.text = title
    }
}
