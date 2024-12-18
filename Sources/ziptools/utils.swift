import Foundation

struct CdHeader{
    var filename_length : UInt16 = 0
    var extra_field_length: UInt16 = 0
    var comment_length: UInt16 = 0
    var offset: UInt32 = 0
    var filename : String = ""
    var extra_field : String = ""
    var file_comment : String = ""
}
func print_data_elem(from data: Data){
    let data_r = Array(data.reversed())
    print(data_r)

}

func get_2_bytes(from data: Data, range : Range<Data.Index>) -> UInt16{
        return data.subdata(in: range).withUnsafeBytes { rawBuffer in
        var value: UInt16 = 0
        // Get a mutable raw buffer to 'value'
        withUnsafeMutableBytes(of: &value) { destBytes in
            destBytes.copyBytes(from: rawBuffer)
        }
        return UInt16(littleEndian: value)
    }
}

func get_4_bytes(from data: Data, range : Range<Data.Index>) -> UInt32{
    return data.subdata(in: range).withUnsafeBytes { rawBuffer in
        var value: UInt32 = 0
        withUnsafeMutableBytes(of: &value) { destBytes in
            destBytes.copyBytes(from: rawBuffer)
        }
        return UInt32(littleEndian: value)
    }
}

func read_cd_header(from data: Data, start :Int)-> CdHeader{
    
    let n = Int(get_2_bytes(from: data, range:(start + 28)..<(start + 30) ))
    let m = Int(get_2_bytes(from: data, range: (start + 30)..<(start + 32)))
    let k = Int(get_2_bytes(from: data, range:(start + 32)..<(start + 34) ))
    let offset = get_4_bytes(from: data, range: (start + 42)..<(start + 46) )
    let filename: String = String(data: data.subdata(in: (start + 46)..<(start + 46 + n)), encoding: .utf8) ?? ""
    let extra_field : String = String(data: data.subdata(in: (start + 46 + n)..<(start + 46 + n + m)), encoding: .utf8) ?? ""
    let comment : String = String(data: data.subdata(in: (start + 46 + n + m )..<(start + 46 + n + m + k)), encoding: .utf8) ?? ""

//    print(n)
//    print(m)
//    print(k)
//    print(filename)
//    print(extra_field)
//    print(comment)
//    print(offset)
     
    return CdHeader(filename_length: UInt16(n),
                    extra_field_length: UInt16(m),
                    comment_length: UInt16(k),
                    offset: offset,
                    filename: filename,
                    extra_field: extra_field,
                    file_comment: comment
    )
}

