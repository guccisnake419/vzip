import Foundation
import ZIPFoundation

//TODO: Replace prints with throws

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
        //TODO: Add size and last modified
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
        //TODO: Add fature to unzip a specific file from the archive
        let source_url = URL(fileURLWithPath: source_path)
        var dest_url = dest_path.isEmpty ? source_url.deletingLastPathComponent() :URL(fileURLWithPath: dest_path)
        
        guard source_url.pathExtension == "zip" else {
            throw ArgError.UnrecognizableExtension(ext: source_url.pathExtension)
        }
        let trimmed = source_url.lastPathComponent.hasSuffix(".zip") ? String(source_url.lastPathComponent.dropLast(4)) : source_url.lastPathComponent
        dest_url.appendingPathComponent("\(trimmed)")
        let fileManager = FileManager()
        do {
            try fileManager.createDirectory(at: dest_url, withIntermediateDirectories: true, attributes: nil)
            try fileManager.unzipItem(at: source_url, to: dest_url)
        } catch {
            print("Extraction of ZIP archive failed with error:")
        }
        
    }
    public func add(to dest:String, from source:String, compressionMethod: CompressionMethod ) throws{
        //source could be a dir or a file
        //create central directory header
        //create file entry and
        //update eod entry
    
        
    }
    public func remove(from path:String, file:String ){
        //verify presence of file / directory
        //remove Central directory header
            //change the date of the first cd record possibly?
        //remove file entry header and file entry
        //decrease EOCD Num of central directory records
        
        
    }
    /*
     concatenates two zip files together
     */
    public func concat(_ path1: String, _ path2: String, _ dest: String ) throws{
        let url1 = URL(fileURLWithPath: path1)
        let url2 = URL(fileURLWithPath: path2)
        do{
            let data1 = try Data(contentsOf: url1)
            let data2 = try Data(contentsOf: url2)
            let (big, small) = data1.count > data2.count ? (data1, data2): (data1, data2)
            let big_info = dissectZip(big)
            let small_info = dissectZip(small)
            let combined = concatArchive(big, big_info, small, small_info )
            
            
            
            
        } catch {
           throw FileError.CannotOpenFile(path: path1)
            
        }
        
    }
    public func encode_base64(_ path: String){}
    public func decode_base64(_ path: String){}
    public func encode_base32(_ path: String){}
    public func decode_base32(_ path: String){}
}


