import Figlet
import ArgumentParser
import ziptools

@main
struct vzip:ParsableCommand {
    
    @Option(help: "Lists the contents of an archive")
    public var list : String = ""

    @Option(help: "Zip an archive")
    public var zip : String = ""

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
     
    public func run() throws {
        Figlet.say("VZIP")
        let archive = ZipArchive()
        if list != "" {
            archive.list_files(list)
            
        }else if zip != "" {
            print(zip)
        }else if unzip != ""{

        }else if add != "" {

        }else if remove != "" {

        }else if concat != ""{

        }else if encode_base64 != "" {

        }else if encode_base32 != ""{

        }else if decode_base64 != ""{

        }else if decode_base32 != ""{

        }

    }
}
