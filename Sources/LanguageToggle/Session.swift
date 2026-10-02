import Foundation

enum Session {
    static func logOut() -> String? {
        let script = NSAppleScript(source: #"tell application "System Events" to log out"#)
        var error: NSDictionary?
        script?.executeAndReturnError(&error)
        return error?[NSAppleScript.errorMessage] as? String
    }
}
