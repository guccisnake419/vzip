import Foundation

/*
    Central directory file header signature = 0x02014b50
    Most of the signatures end with 0x4b50, which is stored in little-endian ordering
    Little Endianess: Least significant byte is stored at the Lowest memory address


*/
public let ZIP_CD_HEADER_SIG : [UInt8] = [0x50, 0x4b, 0x01, 0x02]

/*
    End of Central directory signature =  0x06054b50
*/
public let EOCD_SIG: [UInt8] = [0x50, 0x4b, 0x05, 0x06]


/*
    Central directory Header model
 */

public struct ArchiveInfo{
    var file_entry_start : UInt64 = 0
    var cd_entry_start : UInt64 = 0
    var eocd_entry_start : UInt64 = 0
}

@frozen
public struct EntryHeader{
    
    
}

@frozen
public struct EocdHeader{
    
    
}



@frozen
public struct CdHeader{
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
     
    return CdHeader(filename_length: UInt16(n),
                    extra_field_length: UInt16(m),
                    comment_length: UInt16(k),
                    offset: offset,
                    filename: filename,
                    extra_field: extra_field,
                    file_comment: comment)
}

func cd_header_from_struct(cd_header: CdHeader) -> Data {
    
    return Data()
}

func entry_header_from_struct(entry_header: EntryHeader) -> Data {
    
    return Data()
}

func dissectZip(_ archive: Data) -> ArchiveInfo {
    return ArchiveInfo(
        file_entry_start: 0,
        cd_entry_start: UInt64(archive.firstRange(of: ZIP_CD_HEADER_SIG)!.first!),
        eocd_entry_start: UInt64(archive.firstRange(of: EOCD_SIG)!.first!)
    )
}

func concatArchive(_ first: Data, _ first_info : ArchiveInfo, _ second: Data, _ second_info: ArchiveInfo) -> Data{
    
    let first_ecod = read_eocd_from_data(first)
    let combination = first.subdata(in: (0)..<(Int(first_info.cd_entry_start))) +
        second.subdata(in: (0)..<(Int(second_info.cd_entry_start))) +
    first.subdata(in: (Int(first_info.cd_entry_start))..<(Int(first_info.eocd_entry_start))) +
    second.subdata(in: (Int(second_info.cd_entry_start))..<(Int(second_info.eocd_entry_start)))
    return Data(combination)
}

func read_eocd_from_data(_ data: Data) -> EocdHeader {
    return EocdHeader()
}
