import SwiftUI

extension UIView {
    func addSubview(_ childView: UIView, applyConstraints: Bool = false) {
        childView.translatesAutoresizingMaskIntoConstraints = applyConstraints
        self.addSubview(childView)
    }
    
    func addSubviews(_ childViews: UIView..., applyConstraints: Bool = false) {
        childViews.forEach { child in
            addSubview(child, applyConstraints: applyConstraints)
        }
    }
    
    func mapButton(_ button: UIButton, for event: UIControl.Event = .touchUpInside, action: @escaping () -> Void) {
        let uiAction = UIAction(handler: { _ in
            action()
        })
        button.addAction(uiAction, for: event)
    }
}

extension UIView {
    private func setShadow(radius: CGFloat, color: UIColor, opacity: Float, offset: CGSize = CGSize(width: 0, height: 0)) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        layer.shadowOffset = offset
    }
    
    func setShadow(radius: CGFloat, color: UIColor, opacity: Float, offset: CGSize = CGSize(width: 0, height: 0), using path: CGPath? = nil) {
        setShadow(radius: radius, color: color, opacity: opacity, offset: offset)
        
        layer.shadowPath = path
    }
    
    func setCornerRadius(_ radius: CGFloat) {
        layer.cornerRadius = radius
    }
    
    func setBorder(width: CGFloat, color: UIColor, opacity: CGFloat = 1) {
        layer.borderWidth = width
        layer.borderColor = color.withAlphaComponent(opacity).cgColor
    }
    
    func addGradientBackground(colors: [UIColor], startPoint: CGPoint = CGPoint(x: 0.5, y: 0.0), endPoint: CGPoint = CGPoint(x: 0.5, y: 1.0), with radius: CGFloat = 0) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.masksToBounds = true
        gradientLayer.cornerRadius = radius
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func updateGradientFrame() {
        guard let gradientLayer = layer.sublayers?.first(where: { $0 is CAGradientLayer }) as? CAGradientLayer else {
            return
        }
    
        gradientLayer.frame = self.bounds
    }
}

//MARK: - Preview Logic
extension UIView {
    var preview: some View {
        Preview(self)
    }
    
    private struct Preview: UIViewRepresentable {
        let preView: UIView
        
        init(_ view: UIView) {
            self.preView = view
        }
        
        func makeUIView(context: Context) -> UIView {
            preView
        }
        
        func updateUIView(_ uiView: UIView, context: Context) {
        }
    }
}
