//
//  YAJLGenerator.swift
//  YAJL
//
//  Created by Robert Payne on 29/03/16.
//  Copyright © 2016 Sense Medical Limited. All rights reserved.
//

import Foundation
import CYAJL


internal class Generator {
    
    static func generate(_ object: AnyObject) throws -> String {
//        let gen = yajl_gen_alloc(nil)
//        defer {
//            yajl_gen_free(gen)
//        }
//        
//        try yajl_encode_value(gen!, object)
//        
//        var buffer = UnsafeMutablePointer<UnsafePointer<UInt8>>.allocate(capacity: 1)
//        var bufferSize: Int = 0
//        defer {
//            buffer.deallocate(capacity: 1)
//        }
//        
//        try yajl_check_status(yajl_gen_get_buf(gen, buffer, &bufferSize))
//    
//        guard let string = String(validatingUTF8: UnsafePointer<CChar>(buffer.pointee)) else {
//            throw YAJLError(message: "Could not convert generated json to String.")
//        }
//        
//        return string
        return ""
    }
    

}

private func yajl_check_status(_ status: yajl_gen_status) throws {
    guard status == yajl_gen_status_ok else {
        let reason: String
        
        switch status {
        case yajl_gen_keys_must_be_strings:
            reason = "Keys must be strings."
        case yajl_max_depth_exceeded:
            reason = "Max depth exceeded."
        case yajl_gen_in_error_state:
            reason = "In error state."
        case yajl_gen_generation_complete:
            reason = "Generation complete."
        case yajl_gen_invalid_number:
            reason = "Invalid number."
        case yajl_gen_no_buf:
            reason = "No buffer."
        case yajl_gen_invalid_string:
            reason = "Invalid string."
        default:
            reason = "Unknown."
        }
        
        throw YAJLError(message: reason)
    }
}

private func yajl_encode_value(_ gen: yajl_gen, _ value: AnyObject) throws {
    if let array = value as? [AnyObject] {
        try yajl_encode_array(gen, array)
    } else if let map = value as? [String: AnyObject] {
        try yajl_encode_map(gen, map)
    } else if let _ = value as? NSNull {
        try yajl_encode_null(gen)
    } else if let number = value as? NSNumber {
        try yajl_encode_number(gen, number)
    } else if let boolean = value as? Bool {
        try yajl_encode_boolean(gen, boolean)
    } else if let integer = value as? Int64 {
        try yajl_encode_integer(gen, integer)
    } else if let double = value as? Double {
        try yajl_encode_double(gen, double)
    } else if let string = value as? String {
        try yajl_encode_string(gen, string)
    } else {
        fatalError("Could not encode invalid JSON type: \(type(of: value))")
    }
}

private func yajl_encode_map(_ gen: yajl_gen, _ map: [String: AnyObject]) throws {
    try yajl_check_status(yajl_gen_map_open(gen))
    
    let keys = map.keys.sorted()
    for key in keys {
        guard let value = map[key] else {
            fatalError()
        }
        try yajl_encode_string(gen, key)
        try yajl_encode_value(gen, value)
    }
    
    try yajl_check_status(yajl_gen_map_close(gen))
}

private func yajl_encode_array(_ gen: yajl_gen, _ array: [AnyObject]) throws {
    try yajl_check_status(yajl_gen_array_open(gen))
    for value in array {
        try yajl_encode_value(gen, value)
    }
    try yajl_check_status(yajl_gen_array_close(gen))
}

private func yajl_encode_null(_ gen: yajl_gen) throws {
    try yajl_check_status(yajl_gen_null(gen))
}

private func yajl_encode_number(_ gen: yajl_gen, _ number: NSNumber) throws {
    // boolean
    if number.objCType.pointee == 99 {
        try yajl_encode_boolean(gen, number.boolValue)
    }
    // unknown
    else {
        let string: NSString = number.stringValue as NSString
        let data = string.utf8String
        try yajl_check_status(yajl_gen_number(gen, data, string.length))
    }
    
}

private func yajl_encode_boolean(_ gen: yajl_gen, _ boolean: Bool) throws {
    try yajl_check_status(yajl_gen_bool(gen, (boolean) ? 1 : 0))
}

private func yajl_encode_double(_ gen: yajl_gen, _ double: Double) throws {
    try yajl_check_status(yajl_gen_double(gen, double))
}

private func yajl_encode_integer(_ gen: yajl_gen, _ integer: Int64) throws {
    try yajl_check_status(yajl_gen_integer(gen, integer))
}

private func yajl_encode_string(_ gen: yajl_gen, _ string: String) throws {
    let string: NSString = string as NSString
    let data = string.data(using: String.Encoding.utf8.rawValue)!
    try yajl_check_status(yajl_gen_string(gen, (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count), data.count))
}

