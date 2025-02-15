import Figlet
import ArgumentParser
import ziptools
import ZIPFoundation

@main
struct vzip:ParsableCommand, Decodable {
    
    @Option(name:.shortAndLong, help: "Lists the contents of an archive (e.g., --list <from> )")
    public var list : String = ""

    @Option(name:.shortAndLong , parsing: .upToNextOption, help: "Zip an archive (e.g., --zip <from> <to>)")
    public var zip : [String] = []

    @Option(parsing: .upToNextOption, help: "Unzip an archive (e.g., --unzip <from> <to>)")
    public var unzip : [String] = []

//    @Option(parsing: .upToNextOption, help: "Add a file/Directory to an archive (e.g., --add <> <>)")
//    public var add : [String] = []

    @Option(name:.shortAndLong, parsing: .upToNextOption, help: "Remove a file from an archive (e.g., --remove <from> <file_to_remove>)")
    public var remove : [String] = []

    @Option(name:.shortAndLong, parsing: .upToNextOption, help: "Concatenate two archives (e.g., --concat <archive_1> <archive_2> <combination_archive>)")
    public var concat : [String] = []

//    @Option(help: "Encode base64")
//    public var encode_base64 : String = ""
//
//    @Option(help: "Encode base32")
//    public var encode_base32 : String = ""
//
//    @Option(help: "Decode base64")
//    public var decode_base64 : String = ""
//
//    @Option(help: "Decode base32")
//    public var decode_base32 : String = ""
    
    @Flag(help: "Use deflate compression method")
    public var no_deflate : Bool = false
     
    
    public func run() throws {
        let compression_method = no_deflate ? CompressionMethod.none : CompressionMethod.deflate
        
        var archive = ZipArchive()
        if list != "" {
            try archive.list_files(list)
            
        }else if zip != [] {
            
            switch zip.count {
            case 1:
                try archive.zip(zip[0], compressionMethod: compression_method)
            case 2:
                try archive.zip(zip[0], to: zip[1], compressionMethod: compression_method)
            default:
                throw ArgError.ArgumentExceded(count: zip.count)
            }
            
        }else if unzip != []{
            try archive.unzip(unzip[0])
        }
//        else if add != [] {
//            try archive.add(to: add[0], from: add[1], compressionMethod: compression_method)
//
//        }
        else if remove != [] {
            try archive.remove(from: remove[0], file: remove[1])
        }else if concat != [] {
            try archive.concat(concat[0], concat[1], concat[2])

        }
//        else if encode_base64 != "" {
//
//        }else if encode_base32 != ""{
//
//        }else if decode_base64 != ""{
//
//        }else if decode_base32 != ""{
//
//        }
        else{
            Figlet.say("VZIP")
            print(vzip.helpMessage())
        }
        

    }
}
