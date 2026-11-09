import UIKit

/// Presents the system share sheet from the top-most view controller.
/// Used instead of `ShareLink` so the sheet isn't torn down when live Watch updates redraw the screen.
enum ShareSheetPresenter {
    @MainActor
    static func share(text: String, subject: String) {
        guard let scene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }),
              let root = scene.keyWindow?.rootViewController else { return }

        var presenter = root
        while let presented = presenter.presentedViewController { presenter = presented }

        let item = TextShareItem(text: text, subject: subject)
        let controller = UIActivityViewController(activityItems: [item], applicationActivities: nil)
        if let popover = controller.popoverPresentationController {
            popover.sourceView = presenter.view
            popover.sourceRect = CGRect(x: presenter.view.bounds.midX, y: presenter.view.bounds.maxY - 80, width: 0, height: 0)
            popover.permittedArrowDirections = .down
        }
        presenter.present(controller, animated: true)
    }
}

/// Plain-text share payload that also gives Mail a subject line.
private final class TextShareItem: NSObject, UIActivityItemSource {
    let text: String
    let subject: String

    init(text: String, subject: String) {
        self.text = text
        self.subject = subject
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any { text }

    func activityViewController(_ activityViewController: UIActivityViewController,
                                itemForActivityType activityType: UIActivity.ActivityType?) -> Any? { text }

    func activityViewController(_ activityViewController: UIActivityViewController,
                                subjectForActivityType activityType: UIActivity.ActivityType?) -> String { subject }
}
