import Foundation
import ZIPFoundation


public struct ZipArchive {
    //maybe Data structure for archive 
    
    var files :[CdHeader] = []
    
    public init(){}
    
    /*
         A .zip file consosts of one central directory headers for each entry (file / directory), contained in the
         archive.
     */
    public mutating func read_cd_headers(from data:Data){
        var data_cp = data
        var start = data_cp.firstRange(of: ZIP_CD_HEADER_SIG)
        while start != nil {
            let cd_header = read_cd_header(from: data_cp, start: start!.first!)
            self.files.append(cd_header)
            data_cp = (data_cp.suffix(from: start!.last!))
            start =  data_cp.firstRange(of: ZIP_CD_HEADER_SIG)
        }
    }
    
    public mutating func list_files(_ path :String) throws {
        let url = URL(fileURLWithPath: path)
        do {
            
            let data = try Data(contentsOf: url)
            read_cd_headers(from: data)
            
            files.forEach{cd_header in
                print(cd_header.filename)
            }
            
        }catch {
           throw FileError.CannotOpenFile(path: path)
            
        }
    }
    
    public func zip(_ source_path :String, to dest_path : String = "", compressionMethod: CompressionMethod) throws{
        let source_url = URL(fileURLWithPath: source_path)
        var dest_url = dest_path.isEmpty ? source_url.deletingLastPathComponent() :URL(fileURLWithPath: dest_path)
        let fileManager = FileManager()
        dest_url.appendPathComponent("\(source_url.lastPathComponent).zip")
        do {
            try fileManager.zipItem(at: source_url, to: dest_url, compressionMethod: compressionMethod)
        } catch {
            print("Creation of ZIP archive failed with error:")
        }
        
    }
    
    public func unzip(_ source_path :String, to dest_path : String = "") throws{
        let source_url = URL(fileURLWithPath: source_path)
        print(source_url.pathExtension)
        guard source_url.pathExtension == "zip" else {//ok :\
            throw ArgError.UnrecognizableExtension(ext: source_url.pathExtension)
        }
        
        
    }
    public func add(to dest:String, from source:String ){}
    public func remove(from path:String, file:String ){
        //verify presence of file / directory
        //remove Central directory header
            //change the date of the first cd record possibly?
        //remove file entry header and file entry
        //decrease EOCD Num of central directory records
        
        
    }
    public func concat(_ path1: String, _ path2: String, _ dest: String ){}
    public func encode_base64(_ path: String){}
    public func decode_base64(_ path: String){}
    public func encode_base32(_ path: String){}
    public func decode_base32(_ path: String){}
}


