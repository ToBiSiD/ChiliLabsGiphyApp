import SwiftUI

extension UIViewController {
    func addGradientBackground(colors: [UIColor], startPoint: CGPoint = CGPoint(x: 0.5, y: 0.0), endPoint: CGPoint = CGPoint(x: 0.5, y: 1.0)) {
        view.addGradientBackground(colors: colors, startPoint: startPoint, endPoint: endPoint)
    }
    
    func updateGradientFrame() {
        view.updateGradientFrame()
    }
    
    func dismissPopup(completion: (() -> Void)? = nil) {
        self.dismiss(animated: true, completion: completion)
    }
    
    func mapButton(_ button: UIButton, for event: UIControl.Event = .touchUpInside, action: @escaping () -> Void) {
        let uiAction = UIAction(handler: { _ in
            action()
        })
        button.addAction(uiAction, for: event)
    }
    
    func mapSegmentedControl(_ control: UISegmentedControl, action: @escaping () -> Void) {
        let uiAction = UIAction(handler: { _ in
            action()
        })
        
        control.addAction(uiAction, for: .valueChanged)
    }
}

//MARK: - Preview Logic
extension UIViewController {
    var preview: some View {
        Preview(self).ignoresSafeArea()
    }
    
    private struct Preview: UIViewControllerRepresentable {
        let preView: UIViewController
        
        init(_ vc: UIViewController) {
            self.preView = vc
        }
        
        func makeUIViewController(context: Context) -> some UIViewController {
            preView
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        }
    }
}

