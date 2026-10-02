import AppKit
import ServiceManagement

@MainActor
final class ToggleModel: ObservableObject {
    @Published private(set) var options = SystemLanguage.options
    @Published private(set) var opensAtLogin = SMAppService.mainApp.status == .enabled

    private let sessionLanguage = SystemLanguage.options.first
    private var refreshTimer: Timer?

    init() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
    }

    var selected: LanguageOption? {
        options.first
    }

    var needsLogOut: Bool {
        selected != sessionLanguage
    }

    var statusLine: String {
        guard let selected else { return "No languages found" }
        return needsLogOut
            ? "\(selected.displayName) after you log out"
            : "Current: \(selected.displayName)"
    }

    func refresh() {
        let latest = SystemLanguage.options
        if latest != options {
            options = latest
        }
    }

    func switchTo(_ option: LanguageOption) {
        guard option != selected else { return }
        guard SystemLanguage.apply(option) else {
            showError("Could not save the language settings.")
            return
        }
        refresh()
        if needsLogOut {
            DispatchQueue.main.async { self.confirmLogOut() }
        }
    }

    func confirmLogOut() {
        guard let selected else { return }
        NSApp.activate(ignoringOtherApps: true)
        let alert = NSAlert()
        alert.messageText = "Log out to switch to \(selected.displayName)?"
        alert.informativeText = "macOS applies a new system language at your next login. Save your work before logging out."
        alert.addButton(withTitle: "Log Out")
        alert.addButton(withTitle: "Later")

        guard alert.runModal() == .alertFirstButtonReturn else { return }
        if let message = Session.logOut() {
            showError(message)
        }
    }

    func toggleOpenAtLogin() {
        do {
            if opensAtLogin {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
        } catch {
            showError(error.localizedDescription)
        }
        opensAtLogin = SMAppService.mainApp.status == .enabled
    }

    private func showError(_ message: String) {
        NSApp.activate(ignoringOtherApps: true)
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "Language Toggle"
        alert.informativeText = message
        alert.runModal()
    }
}
