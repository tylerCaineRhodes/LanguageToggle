import SwiftUI

@main
struct LanguageToggleApp: App {
    @StateObject private var model = ToggleModel()

    var body: some Scene {
        MenuBarExtra {
            Text(model.statusLine)
            Divider()
            ForEach(model.options) { option in
                Toggle(option.displayName, isOn: Binding(
                    get: { option == model.selected },
                    set: { _ in model.switchTo(option) }
                ))
            }
            if model.needsLogOut {
                Button("Log Out Now…") {
                    model.confirmLogOut()
                }
            }
            Divider()
            Toggle("Open at Login", isOn: Binding(
                get: { model.opensAtLogin },
                set: { _ in model.toggleOpenAtLogin() }
            ))
            Button("Quit Language Toggle") {
                NSApplication.shared.terminate(nil)
            }
        } label: {
            Text(model.selected?.menuBarSymbol ?? "?")
        }
    }
}
