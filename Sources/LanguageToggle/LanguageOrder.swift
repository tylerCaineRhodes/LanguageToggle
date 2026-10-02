import Foundation

func reorderedLanguages(_ current: [String], toLead identifier: String) -> [String] {
    guard current.contains(identifier) else { return current }
    return [identifier] + current.filter { $0 != identifier }
}
