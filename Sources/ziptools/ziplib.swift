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
    var start_off : Int = 0
    var eocd_sig = EOCD_SIG
    var disk_num : UInt16 = 0
    var cd_start : UInt16 = 0
    var cd_count_on_disk : UInt16 = 0
    var cd_total : UInt16 = 0
    var cd_size : UInt32 = 0
    var cd_off : UInt32 = 0
    var comment_length : UInt16 = 0
    var  comment : String = ""
    
    func toData() -> Data {
        var data = Data()

        data.append(Data(eocd_sig))
        withUnsafeBytes(of: disk_num) { data.append(contentsOf: $0) }
        withUnsafeBytes(of: cd_start) { data.append(contentsOf: $0) }
        withUnsafeBytes(of: cd_count_on_disk) { data.append(contentsOf: $0) }
        withUnsafeBytes(of: cd_total) { data.append(contentsOf: $0) }
        withUnsafeBytes(of: cd_size) { data.append(contentsOf: $0) }
        withUnsafeBytes(of: cd_off) { data.append(contentsOf: $0) }
        withUnsafeBytes(of: comment_length) { data.append(contentsOf: $0) }


        if let commentData = comment.data(using: .utf8) {
            data.append(commentData)
        }

        return data
    }
}



@frozen
public struct CdHeader : Hashable{
    var compressed_size : UInt32 = 0
    var uncompressed_size : UInt32 = 0
    var filename_length : UInt16 = 0
    var extra_field_length: UInt16 = 0
    var comment_length: UInt16 = 0
    var offset: UInt32 = 0
    var filename : String = ""
    var extra_field : String = ""
    var file_comment : String = ""
    var cd_header_size : UInt16 = 0
}

func print_data_elem(from data: Data){
    let data_r = Array(data.reversed())
    print(data_r)

}

func get_2_bytes(from data: Data, start : Int) -> UInt16{
        let range = (start)..<(start+2)
        //TODO: since it gets two bytes only add the start index?
        return data.subdata(in: range).withUnsafeBytes { rawBuffer in
        var value: UInt16 = 0
        withUnsafeMutableBytes(of: &value) { destBytes in
            destBytes.copyBytes(from: rawBuffer)
        }
        return UInt16(littleEndian: value)
    }
}

func get_4_bytes(from data: Data, start : Int) -> UInt32{
    let range = (start)..<(start+4)
    return data.subdata(in: range).withUnsafeBytes { rawBuffer in
        var value: UInt32 = 0
        withUnsafeMutableBytes(of: &value) { destBytes in
            destBytes.copyBytes(from: rawBuffer)
        }
        return UInt32(littleEndian: value)
    }
}



func read_cd_header(from data: inout Data, start :Int)-> CdHeader{
    let compressed_size = get_4_bytes(from: data, start: start + 20 )
    let uncompressed_size = get_4_bytes(from: data, start: start + 24)
    let n = get_2_bytes(from: data, start:start+28 )
    let m = get_2_bytes(from: data, start: (start + 30))
    let k = get_2_bytes(from: data, start:(start + 32) )
    let offset = get_4_bytes(from: data, start: (start + 42) )
    let filename: String = String(data: data.subdata(in: (start + 46)..<(start + 46 + Int(n))), encoding: .utf8) ?? ""
    let extra_field : String = String(data: data.subdata(in: (start + 46 + Int(n))..<(start + 46 + Int(n) + Int(m))), encoding: .utf8) ?? ""
    
    let comment : String = String(data: data.subdata(in: (start + 46 + Int(n) + Int(m) )..<(start + 46 + Int(n) + Int(m) + Int(k))), encoding: .utf8) ?? ""
    let cd_header_size = 46 + Int(n) + Int(m) + Int(k)
   
     
    return CdHeader(
                    compressed_size: compressed_size,
                    uncompressed_size: uncompressed_size,
                    filename_length: n,
                    extra_field_length: m,
                    comment_length: k,
                    offset: offset,
                    filename: filename,
                    extra_field: extra_field,
                    file_comment: comment,
                    cd_header_size: UInt16(truncatingIfNeeded:cd_header_size)
    )
}


func dissectZip(_ archive: Data) -> ArchiveInfo {
    return ArchiveInfo(
        file_entry_start: 0,
        cd_entry_start: UInt64(archive.firstRange(of: ZIP_CD_HEADER_SIG)!.first!),
        eocd_entry_start: UInt64(archive.firstRange(of: EOCD_SIG)!.first!)
    )
}

func concatArchive(_ first: Data, _ first_info : ArchiveInfo, _ second: Data, _ second_info: ArchiveInfo) -> Data{
    
    //second is the smaller one by size
    //TODO: use the file with the smallest count of Central directories instead?
    //TODO: bounds check each file to not exceed .zip 4GB capacity
    let first_ecod = read_eocd_from_data(first)
    let second_ecod = read_eocd_from_data(second)
    let new_comment = "NOTE: This file has been concatenated \n first comment: \(first_ecod.comment) \n second comment \(second_ecod.comment)"
    let new_ecod = EocdHeader(
        cd_count_on_disk: first_ecod.cd_count_on_disk+second_ecod.cd_count_on_disk,
                              cd_total: first_ecod.cd_total + second_ecod.cd_total,
        cd_size: first_ecod.cd_size+second_ecod.cd_size, cd_off: UInt32(truncatingIfNeeded: first_info.cd_entry_start + second_info.cd_entry_start),
        comment_length: UInt16(truncatingIfNeeded: new_comment.count), comment: new_comment)
    
    

    
    var second_cp: Data = second
    var start = second_cp.firstRange(of: ZIP_CD_HEADER_SIG)
    while start != nil {
        let start_index = start!.first!
        let offset_start = start_index + 42
        var offset = get_4_bytes(from: second_cp, start: offset_start) + UInt32(truncatingIfNeeded:first_info.cd_entry_start )
        let offset_bytes = Array(withUnsafeBytes(of: &offset) {Data($0)})
        for i in 0...3 {
            second_cp[offset_start + i] = offset_bytes[i]
        }
        
        start = second_cp.firstRange(of: ZIP_CD_HEADER_SIG, in:(start!.last!)..<(second_cp.count))
        
    }

    let entry_comb = first.subdata(in: (0)..<(Int(first_info.cd_entry_start))) +  second.subdata(in: (0)..<(Int(second_info.cd_entry_start)))
    
   
    let combination = entry_comb +
    first.subdata(in: (Int(first_info.cd_entry_start))..<(Int(first_info.eocd_entry_start))) +
    second_cp.subdata(in: (Int(second_info.cd_entry_start))..<(Int(second_info.eocd_entry_start))) + new_ecod.toData()
    return combination
}

func read_eocd_from_data(_ data: Data) -> EocdHeader {
    let start = Int(data.firstRange(of: EOCD_SIG)!.first!)
    let disk_num = get_2_bytes(from: data, start:(start+4) )
    let cd_start = get_2_bytes(from: data, start:(start+6))
    let cd_count_on_disk = get_2_bytes(from: data, start: (start+8))
    let cd_total = get_2_bytes(from: data , start:(start+10) )
    let cd_size = get_4_bytes(from: data, start:(start+12))
    let offset = get_4_bytes(from: data, start: (start+16))
    let comment_length = get_2_bytes(from: data, start: start+20)
    let comment : String = String(data: data.subdata(in: (start + 22)..<(data.count)), encoding: .utf8) ?? ""
    
    return EocdHeader(
        start_off: start, disk_num: disk_num, cd_start: cd_start, cd_count_on_disk: cd_count_on_disk, cd_total: cd_total, cd_size: cd_size, cd_off: offset, comment_length: comment_length, comment: comment
    
    )
}
