import Figlet
import ArgumentParser
import ziptools
import ZIPFoundation

@main
struct vzip:ParsableCommand {
    
    @Option(help: "Lists the contents of an archive")
    public var list : String = ""

    @Option(parsing: .upToNextOption, help: "Zip an archive")
    public var zip : [String] = []

    @Option(help: "Unzip an archive")
    public var unzip : String = ""

    @Option(help: "Add a file/Directory to an archive")
    public var add : String = ""

    @Option(help: "Remove a file from an archive")
    public var remove : String = ""

    @Option(help: "Concatenate two archives")
    public var concat : String = ""

    @Option(help: "Encode base64")
    public var encode_base64 : String = ""

    @Option(help: "Encode base32")
    public var encode_base32 : String = ""

    @Option(help: "Decode base64")
    public var decode_base64 : String = ""

    @Option(help: "Decode base32")
    public var decode_base32 : String = ""
    
    @Flag(help: "Use deflate compression method")
    public var no_deflate : Bool = false
     
    
    public func run() throws {
       
        var archive = ZipArchive()
        if list != "" {
            try archive.list_files(list)
            
        }else if zip != [] {
            print(zip)
            let compression_method = no_deflate ? CompressionMethod.none : CompressionMethod.deflate
            print(compression_method)
            switch zip.count {
            case 1:
                try archive.zip(zip[0], compressionMethod: compression_method)
            case 2:
                try archive.zip(zip[0], to: zip[1], compressionMethod: compression_method)
            default:
                throw ArgError.ArgumentExceded(count: zip.count)
            }
            
        }else if unzip != ""{
            archive.unzip(unzip)
        }else if add != "" {

        }else if remove != "" {

        }else if concat != ""{

        }else if encode_base64 != "" {

        }else if encode_base32 != ""{

        }else if decode_base64 != ""{

        }else if decode_base32 != ""{

        }else{
            Figlet.say("VZIP")
            print(vzip.helpMessage())
        } 

    }
}
