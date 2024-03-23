import SwiftUI

extension UIViewController {
    func dismissPopup(completion: (() -> Void)? = nil) {
        self.dismiss(animated: true, completion: completion)
    }
    
    func mapButton(_ button: UIButton, for event: UIControl.Event = .touchUpInside, action: @escaping () -> Void) {
        let uiAction = UIAction(handler: { _ in
            action()
        })
        button.addAction(uiAction, for: event)
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

