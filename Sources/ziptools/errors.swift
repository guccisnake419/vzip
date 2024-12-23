import Foundation

public enum FileError: Error {
    case CannotOpenFile(path: String)
}

public enum ArgError: Error{
    case ArgumentExceded(count : Int)
    case UnrecognizableExtension(ext : String)
}

