import Foundation
/*
    Central directory file header signature = 0x02014b50 
    Most of the signatures end with 0x4b50, which is stored in little-endian ordering
    Little Endianess: Least significant byte is stored at the Lowest memory address


*/
public let ZIP_CD_HEADER_SIG : [UInt8] = [0x50, 0x4b, 0x01, 0x02]

/* 
    End of Central directory  signature =  0x06054b50
*/
public let EOCD_SIG: [UInt8] = [0x50, 0x4b, 0x05, 0x06]

public let TEST:[UInt8] = [0x51, 0x42, 0x00, 0x01]

enum FileError: Error {
    case CannotOpenFile(path: String)
}


public struct ZipArchive {
    //maybe Data structure for archive 
    
    var files :[CdHeader] = []
    
    public init(){}
    
    public mutating func list_files(_ path :String) throws {
        let url = URL(fileURLWithPath: path)
        do {
            
            let data = try Data(contentsOf: url)
            var data_cp = data
            var start = data_cp.firstRange(of: ZIP_CD_HEADER_SIG)
            while start != nil {
                let cd_header = read_cd_header(from: data, start: start!.first!)
                self.files.append(cd_header)
                data_cp = (data_cp.suffix(from: start!.last!))
                start =  data_cp.firstRange(of: ZIP_CD_HEADER_SIG)
            }
            for cd_header in files{
                print(cd_header.filename)
            }
            
            
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


