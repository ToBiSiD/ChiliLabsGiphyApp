//
//  UIView+Extensions.swift
//  ChiliLabsTestTask
//
//  Created by Tobias on 21.03.2024.
//

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
}

extension UIView {
    func setShadow(radius: CGFloat, color: UIColor, opacity: Float, offset: CGSize = CGSize(width: 0, height: 0)) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        layer.shadowOffset = offset
    }
    
    func setCornerRadius(_ radius: CGFloat) {
        layer.cornerRadius = radius
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