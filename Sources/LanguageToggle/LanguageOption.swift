import Foundation

struct LanguageOption: Identifiable, Equatable {
    let identifier: String

    var id: String { identifier }

    private var components: Locale.Language.Components {
        Locale.Language.Components(identifier: identifier)
    }

    private var languageCode: String {
        components.languageCode?.identifier ?? identifier
    }

    private var baseIdentifier: String {
        [languageCode, components.script?.identifier]
            .compactMap { $0 }
            .joined(separator: "-")
    }

    var displayName: String {
        Locale(identifier: baseIdentifier).localizedString(forIdentifier: baseIdentifier) ?? identifier
    }

    var menuBarSymbol: String {
        languageCode.uppercased()
    }

    var localeIdentifier: String {
        guard let region else { return baseIdentifier }
        return "\(baseIdentifier)_\(region)"
    }

    private var region: String? {
        if let explicitRegion = components.region?.identifier, isRealLocale(region: explicitRegion) {
            return explicitRegion
        }
        return Locale.Language(identifier: baseIdentifier).maximalIdentifier
            .split(separator: "-")
            .last
            .map(String.init)
    }

    private func isRealLocale(region: String) -> Bool {
        let candidate = "\(baseIdentifier)_\(region)".replacingOccurrences(of: "-", with: "_")
        return Locale.availableIdentifiers.contains(candidate)
    }
}
