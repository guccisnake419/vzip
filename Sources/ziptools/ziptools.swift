import Foundation
import ZIPFoundation

//TODO: Replace prints with throws

public struct ZipArchive {
    //maybe Data structure for archive 
     
    var files : [CdHeader] = []
    
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
            files.append(cd_header)
            data_cp = (data_cp.suffix(from: start!.last!))
            start =  data_cp.firstRange(of: ZIP_CD_HEADER_SIG)
        }
    }
    
    public mutating func list_files(_ path :String) throws {
        //TODO: Add size and last modified
        let url = URL(fileURLWithPath: path)
        
        guard url.pathExtension == "zip" else{
            throw FileError.CannotOpenFile(path: path)
        }
        
        do {
            
            let data = try Data(contentsOf: url)
            read_cd_headers(from: data)
            
            for file in files {
                print("\(file.filename)\t \(file.offset)")
            }
            
        }catch {
           throw FileError.CannotOpenFile(path: path)
            
        }
    }
    
    public func zip(_ source_path :String, to dest_path : String = "", compressionMethod: CompressionMethod) throws{
        let source_url = URL(fileURLWithPath: source_path)
        var dest_url = dest_path.isEmpty ? source_url.deletingLastPathComponent() :URL(fileURLWithPath: dest_path)
        let fileManager = FileManager()
        let _ = dest_url.appendPathComponent("\(source_url.lastPathComponent).zip")
        do {
            try fileManager.zipItem(at: source_url, to: dest_url, compressionMethod: compressionMethod)
        } catch {
            print("Creation of ZIP archive failed with error:")
        }
        
    }
    
    public func unzip(_ source_path :String, to dest_path : String = "") throws{
        //TODO: Add fature to unzip a specific file from the archive
        let source_url = URL(fileURLWithPath: source_path)
        let dest_url = dest_path.isEmpty ? source_url.deletingLastPathComponent() :URL(fileURLWithPath: dest_path)
        
        guard source_url.pathExtension == "zip" else {
            throw ArgError.UnrecognizableExtension(ext: source_url.pathExtension)
        }
        let trimmed = source_url.lastPathComponent.hasSuffix(".zip") ? String(source_url.lastPathComponent.dropLast(4)) : source_url.lastPathComponent
        let _ = dest_url.appendingPathComponent("\(trimmed)")
        let fileManager = FileManager()
        do {
            try fileManager.createDirectory(at: dest_url, withIntermediateDirectories: true, attributes: nil)
            try fileManager.unzipItem(at: source_url, to: dest_url)
        } catch {
            print("Extraction of ZIP archive failed with error:")
        }
        
    }
    
    //users could alternatively zip and concat the file/dir
    public func add(to dest:String, from source:String, compressionMethod: CompressionMethod ) throws{
        
        throw AppError.ServiceError
        
        //source could be a dir or a file
        //create central directory header
        //create file entry and
        //update eod entry
    
        
    }
    public mutating func remove(from path:String, file:String ) throws{
        //verify presence of file / directory
        //remove Central directory header
            //change the date of the first cd record possibly?
        //remove file entry header and file entry
        //decrease EOCD Num of central directory records
        
        let url = URL(fileURLWithPath: path)
        
        guard !file.hasSuffix("/") else {
            throw FileError.CannotRemoveDirectory(file: file)
        }
        
        do {
            var data = try Data(contentsOf: url)
            
            var start = data.firstRange(of: ZIP_CD_HEADER_SIG)
            var cd_header : CdHeader = CdHeader()
            var start_index:Int = 0, cd_index :Int = 0
            var filefound = false
            var n = UInt16()
            var m = UInt16()
            var fe_size : UInt32 = 0
            var file_entry_header_end = 0
            while start != nil {
                start_index = start!.first!
                let temp_cd_header = read_cd_header(from: data, start:start_index)
                if temp_cd_header.filename == file {
                    cd_index = start_index
                    cd_header = temp_cd_header
                    filefound = true
                    n = get_2_bytes(from: data, start: Int(cd_header.offset) + 26)
                    m = get_2_bytes(from: data, start: Int(cd_header.offset) + 28)
                    fe_size = 30 + UInt32(m) + UInt32(n) + UInt32(cd_header.compressed_size)
                    file_entry_header_end = Int(cd_header.offset) + Int(fe_size)
                    var gpb_flag = get_2_bytes(from: data, start: Int(cd_header.offset)+6)
                    gpb_flag = (gpb_flag << 12)>>15 //get 3rd least significant bit
                    if gpb_flag != 0 {
                        //data descriptor table exists
                        fe_size += 16
                        file_entry_header_end += 16
                    }
                    start = data.firstRange(of: ZIP_CD_HEADER_SIG, in:(start!.last!)..<(data.count))
                    
                    continue
                }
                
                if filefound  {
                    //update the file entry header offset for the remaining central directory entry.
                    let offset = get_4_bytes(from: data, start: start_index + 42) - fe_size
                    print(offset)
                    data.replaceSubrange((start_index + 42)..<(start_index+46), with: withUnsafeBytes(of: offset){Data($0)})
                   
                }
                
                start = data.firstRange(of: ZIP_CD_HEADER_SIG, in:(start!.last!)..<(data.count))
            }
            
            guard cd_header.filename == file else{
                throw FileError.DoesNotExist(file: file)
            }
            
            //remove cd_header
            data.removeSubrange((cd_index)..<(Int(cd_header.cd_header_size) + cd_index))
            
            //remove file entry header
            
            data.removeSubrange((Int(cd_header.offset))..<(file_entry_header_end))
            
            //edit eocd header
            var eocd_header = read_eocd_from_data(data)
            eocd_header.cd_size = eocd_header.cd_size - UInt32(cd_header.cd_header_size)
            eocd_header.cd_total -= 1
            eocd_header.cd_count_on_disk -= 1
            eocd_header.cd_off = UInt32(data.firstRange(of: ZIP_CD_HEADER_SIG)!.first!)//optimize later
            data.replaceSubrange((eocd_header.start_off)..<(data.count), with: eocd_header.toData())
            
            try data.write(to:url, options: .atomic )

            
        }catch is FileError{
            
            throw FileError.DoesNotExist(file: file)
        }
        
        
    }
    /*
     concatenates two zip files together
     */
    public func concat(_ path1: String, _ path2: String, _ dest: String ) throws{
        let fileManager = FileManager()
    
        do{
            let data1 = try Data(contentsOf: URL(fileURLWithPath: path1))
            let data2 = try Data(contentsOf: URL(fileURLWithPath: path2))
            let (big, small) = data1.count > data2.count ? (data1, data2): (data1, data2)
            let big_info = dissectZip(big)
            let small_info = dissectZip(small)
            let combined = concatArchive(big, big_info, small, small_info )
//            let dest_url = URL(fileURLWithPath: dest)
           
                
            fileManager.createFile(atPath: dest, contents: combined)
            
            
            
            
        } catch {
           throw FileError.CannotOpenFile(path: path1)
            
        }
        
    }
    public func encode_base64(_ path: String){}
    public func decode_base64(_ path: String){}
    public func encode_base32(_ path: String){}
    public func decode_base32(_ path: String){}
}


