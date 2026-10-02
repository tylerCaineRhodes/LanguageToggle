import Foundation

enum SystemLanguage {
    private static let application = kCFPreferencesAnyApplication
    private static let user = kCFPreferencesCurrentUser
    private static let host = kCFPreferencesAnyHost

    static var languages: [String] {
        CFPreferencesSynchronize(application, user, host)
        return CFPreferencesCopyValue("AppleLanguages" as CFString, application, user, host) as? [String] ?? []
    }

    static var options: [LanguageOption] {
        languages.map(LanguageOption.init(identifier:))
    }

    static func apply(_ option: LanguageOption) -> Bool {
        let current = languages
        let newLanguages = reorderedLanguages(current, toLead: option.identifier)
        guard newLanguages.first == option.identifier, Set(newLanguages) == Set(current) else { return false }

        CFPreferencesSetValue("AppleLanguages" as CFString, newLanguages as CFArray, application, user, host)
        CFPreferencesSetValue("AppleLocale" as CFString, option.localeIdentifier as CFString, application, user, host)
        return CFPreferencesSynchronize(application, user, host)
    }
}
