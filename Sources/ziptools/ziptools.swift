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

enum FileError: Error {
    case CannotOpenFile(path: String)
}


public struct ZipArchive {
    //maybe Data structure for archive 
    struct ZipFile{
        var filename_length : UInt16 = 0
        var filename : String = ""
        var offset: UInt32 = 0
        var extra_field_length: UInt16
        var comment_length: UInt16
    }
    var files :[ZipFile] = []
    
    public init(){}
    public func list_files(_ path :String) throws {
        let url = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: url)
            if #available(macOS 13.0, *) {
                if data.contains(ZIP_CD_HEADER_SIG) {
                    let start = data.firstRange(of: ZIP_CD_HEADER_SIG)!.first!
                    let filename_length: UInt16 = data.subdata(in: (start + 28)..<(start + 30)).withUnsafeBytes { rawBuffer in
                        var value: UInt16 = 0
                        // Get a mutable raw buffer to 'value'
                        withUnsafeMutableBytes(of: &value) { destBytes in
                            destBytes.copyBytes(from: rawBuffer)
                        }
                        return UInt16(littleEndian: value)
                    }
                    let extra_field_length: UInt16 = data.subdata(in: (start + 30)..<(start + 32)).withUnsafeBytes { rawBuffer in
                        var value: UInt16 = 0
                        // Get a mutable raw buffer to 'value'
                        withUnsafeMutableBytes(of: &value) { destBytes in
                            destBytes.copyBytes(from: rawBuffer)
                        }
                        return UInt16(littleEndian: value)
                    }
                    let comment_length: UInt16 = data.subdata(in: (start + 32)..<(start + 34)).withUnsafeBytes { rawBuffer in
                        var value: UInt16 = 0
                        // Get a mutable raw buffer to 'value'
                        withUnsafeMutableBytes(of: &value) { destBytes in
                            destBytes.copyBytes(from: rawBuffer)
                        }
                        return UInt16(littleEndian: value)
                    }
                    let data = data.subdata(in: (start + 46)..<(start + 46+Int(filename_length)))
                    let filename: String = String(data: data, encoding: .utf8)!
                    


                    print(filename_length)
                    print(extra_field_length)
                    print(comment_length)
                    print(filename)
                
                     
                
                }
            }else{
                // if data.contains(EOCD_SIG){

                // }
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
