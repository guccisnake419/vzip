import Foundation
public let ZIP_CD_HEADER_SIG : UInt32 = 0x02014b50
public let EOCD: UInt32 = 0x06054b50

enum FileError: Error {
    case CannotOpenFile(path: String)
}


public struct ZipArchive {
    //maybe Data structure for archive 
    public init(){}
    public func list_files(_ path :String) throws {
        let url = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: url)
            
            
        }catch {
           throw FileError.CannotOpenFile(path: path)
            
        }
        

    }
    public func zip(_ path :String){
        
    }
    public func unzip(_ path :String){}
    public func add(to dest:String, from source:String ){}
    public func remove(from path:String, file:String ){}
    public func concat(_ path1: String, _ path2: String, _ dest: String ){}
    public func encode_base64(_ path: String){}
    public func decode_base64(_ path: String){}
    public func encode_base32(_ path: String){}
    public func decode_base32(_ path: String){}
}
