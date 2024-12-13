import Figlet
import ArgumentParser
import ziptools

@main
struct vzip:ParsableCommand {
    
    @Option(help: "Specify a command")
    public var list : String = ""

    @Option(help: "Specify a command")
    public var zip : String = ""

    @Option(help: "Specify a command")
    public var unzip : String = ""

    @Option(help: "Specify a command")
    public var add : String = ""

    @Option(help: "Specify a command")
    public var remove : String = ""

    @Option(help: "Specify a command")
    public var concat : String = ""

    @Option(help: "Specify a command")
    public var encode_base64 : String = ""

    @Option(help: "Specify a command")
    public var encode_base32 : String = ""

    @Option(help: "Specify a command")
    public var decode_base64 : String = ""

    @Option(help: "Specify a command")
    public var decode_base32 : String = ""
     
    public func run() throws {
        Figlet.say("VZIP")
        if list != "" {
            print(list)
            
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
