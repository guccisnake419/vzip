

public struct ZipArchive {
    //some Data structure for archive 
    public init(){}
    public func list_files(_ path :String){}
    public func zip(_ path :String){}
    public func unzip(_ path :String){}
    public func add(to dest:String, from source:String ){}
    public func remove(from path:String, file:String ){}
    public func concat(_ path1: String, _ path2: String, _ dest: String ){}
    public func encode_base64(_ path: String){}
    public func decode_base64(_ path: String){}
    public func encode_base32(_ path: String){}
    public func decode_base32(_ path: String){}
}