import Foundation

public enum FileError: Error {
    case CannotOpenFile(path: String)
    case DoesNotExist(file: String)
    case CannotRemoveDirectory(file: String)
}

public enum ArgError: Error{
    case ArgumentExceded(count : Int)
    case UnrecognizableExtension(ext : String)
}

public enum AppError: Error {
    case ServiceError
}

