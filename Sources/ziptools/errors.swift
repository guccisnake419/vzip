import Foundation

enum FileError: Error {
    case CannotOpenFile(path: String)
}
