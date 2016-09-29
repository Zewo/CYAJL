////
////  Parser.swift
////  YAJL
////
////  Created by Robert Payne on 29/03/16.
////  Copyright © 2016 Sense Medical Limited. All rights reserved.
////
//
//import Foundation
//import CoreFoundation
//import CYAJL
//
//
//public final class JSONParser {
//
//    public static func parse(_ data: UnsafePointer<UInt8>, length: Int) throws -> Map {
//        var ctx = Parser()
//        let handle = yajl_alloc(&yajl_handle_callbacks, nil, &ctx)
//        yajl_config_set(handle, yajl_allow_comments, 1)
//        yajl_config_set(handle, yajl_dont_validate_strings, 0)
//        yajl_config_set(handle, yajl_allow_trailing_garbage, 0)
//        yajl_config_set(handle, yajl_allow_partial_values, 0)
//        defer {
//            yajl_free(handle)
//        }
//        
//        guard yajl_parse(handle, data, length) == yajl_status_ok && yajl_complete_parse(handle) == yajl_status_ok else {
//            let messageRaw = yajl_get_error(handle, 1, data, length)
//            defer {
//                yajl_free_error(handle, messageRaw)
//            }
//            
//            let message = String(cString: messageRaw!)
//            
//            throw YAJLError(message: message)
//        }
//        
//        return ctx.value
//    }
//
//    fileprivate struct State {
//        let isDictionary: Bool
//        var dictionaryKey: String = ""
//        
//        var map: Map {
//            if self.isDictionary {
//                return .dictionary(self.dictionary)
//            } else {
//                return .array(self.array)
//            }
//        }
//        
//        private var dictionary: [String: Map]
//        private var array: [Map]
//        
//        init(dictionary: Bool) {
//            self.isDictionary = dictionary
//            if dictionary {
//                self.dictionary = Dictionary<String, Map>(minimumCapacity: 32)
//                self.array = []
//            } else {
//                self.dictionary = [:]
//                self.array = []
//                self.array.reserveCapacity(32)
//            }
//        }
//        
//        mutating func append(_ value: Bool) -> Int32 {
//            if self.isDictionary {
//                self.dictionary[self.dictionaryKey] = .bool(value)
//            } else {
//                self.array.append(.bool(value))
//            }
//            return 1
//        }
//        
//        mutating func append(_ value: Int64) -> Int32 {
//            if self.isDictionary {
//                self.dictionary[self.dictionaryKey] = .int(Int(value))
//            } else {
//                self.array.append(.int(Int(value)))
//            }
//            return 1
//        }
//        
//        mutating func append(_ value: Double) -> Int32 {
//            if self.isDictionary {
//                self.dictionary[self.dictionaryKey] = .double(value)
//            } else {
//                self.array.append(.double(value))
//            }
//            return 1
//        }
//        
//        mutating func append(_ value: String) -> Int32 {
//            if self.isDictionary {
//                self.dictionary[self.dictionaryKey] = .string(value)
//            } else {
//                self.array.append(.string(value))
//            }
//            return 1
//        }
//        
//        mutating func appendNull() -> Int32 {
//            if self.isDictionary {
//                self.dictionary[self.dictionaryKey] = .null
//            } else {
//                self.array.append(.null)
//            }
//            return 1
//        }
//        
//        mutating func append(_ value: Map) -> Int32 {
//            if self.isDictionary {
//                self.dictionary[self.dictionaryKey] = value
//            } else {
//                self.array.append(value)
//            }
//            return 1
//        }
//    }
//    
//    fileprivate var state: State = State(dictionary: true)
//    fileprivate var stack: [State] = []
//    
//    fileprivate let bufferCapacity = 8*1024
//    fileprivate let buffer = UnsafeMutablePointer<CChar>.allocate(capacity: 8*1024)
//    
//    
//    fileprivate var value: Map {
//        let root = self.stack.first ?? self.state
//        switch root.map {
//        case .dictionary(let values):
//            return values["root"] ?? .null
//        default:
//            fatalError()
//        }
//    }
//    
//    deinit {
//        buffer.deallocate(capacity: bufferCapacity)
//    }
//    
//    fileprivate init() {
//        self.state.dictionaryKey = "root"
//        self.stack.reserveCapacity(12)
//    }
//    
//    fileprivate final func appendNull() -> Int32 {
//        return self.state.appendNull()
//    }
//    
//    fileprivate final func appendBoolean(_ value: Bool) -> Int32 {
//        return self.state.append(value)
//    }
//    
//    fileprivate final func appendInteger(_ value: Int64) -> Int32 {
//        return self.state.append(value)
//    }
//    
//    fileprivate final func appendDouble(_ value: Double) -> Int32 {
//        return self.state.append(value)
//    }
//    
//    fileprivate final func appendString(_ value: String) -> Int32 {
//        return self.state.append(value)
//    }
//    
//    fileprivate final func startMap() -> Int32 {
//        self.stack.append(self.state)
//        self.state = State(dictionary: true)
//        return 1
//    }
//    
//    fileprivate final func mapKey(_ key: String) -> Int32 {
//        self.state.dictionaryKey = key
//        return 1
//    }
//    
//    fileprivate final func endMap() -> Int32 {
//        if self.stack.count == 0 {
//            return 0
//        }
//        var previousState = self.stack.removeLast()
//        let result: Int32 = previousState.append(self.state.map)
//        self.state = previousState
//        return result
//    }
//    
//    fileprivate final func startArray() -> Int32 {
//        self.stack.append(self.state)
//        self.state = State(dictionary: false)
//        return 1
//    }
//    
//    fileprivate final func endArray() -> Int32 {
//        if self.stack.count == 0 {
//            return 0
//        }
//        var previousState = self.stack.removeLast()
//        let result: Int32 = previousState.append(self.state.map)
//        self.state = previousState
//        return result
//    }
//    
//}
//
//private var yajl_handle_callbacks = yajl_callbacks(
//    yajl_null: yajl_null,
//    yajl_boolean: yajl_boolean,
//    yajl_integer: yajl_integer,
//    yajl_double: yajl_double,
//    yajl_number: nil,
//    yajl_string: yajl_string,
//    yajl_start_map: yajl_start_map,
//    yajl_map_key: yajl_map_key,
//    yajl_end_map: yajl_end_map,
//    yajl_start_array: yajl_start_array,
//    yajl_end_array: yajl_end_array
//)
//
//private func yajl_null(_ ptr: UnsafeMutableRawPointer?) -> Int32 {
//    let ctx = ptr!.assumingMemoryBound(to: Parser.self).pointee
//    return ctx.appendNull()
//}
//    
//private func yajl_boolean(_ ptr: UnsafeMutableRawPointer?, value: Int32) -> Int32 {
//    let ctx = ptr!.assumingMemoryBound(to: Parser.self).pointee
//    return ctx.appendBoolean(value != 0)
//}
//
//private func yajl_integer(_ ptr: UnsafeMutableRawPointer?, value: Int64) -> Int32 {
//    let ctx = ptr!.assumingMemoryBound(to: Parser.self).pointee
//    return ctx.appendInteger(value)
//}
//
//private func yajl_double(_ ptr: UnsafeMutableRawPointer?, value: Double) -> Int32 {
//    let ctx = ptr!.assumingMemoryBound(to: Parser.self).pointee
//    return ctx.appendDouble(value)
//}
//
//private func yajl_string(_ ptr: UnsafeMutableRawPointer?, buffer: UnsafePointer<UInt8>?, bufferLength: Int) -> Int32 {
//    let ctx = ptr!.assumingMemoryBound(to: Parser.self).pointee
//    
//    let str: String
//    if bufferLength > 0 {
//        if bufferLength < ctx.bufferCapacity {
//            memcpy(UnsafeMutableRawPointer(ctx.buffer), UnsafeRawPointer(buffer), bufferLength)
//            ctx.buffer[bufferLength] = 0
//            str = String(cString: UnsafePointer(ctx.buffer))
//        } else {
//            var buffer = UnsafeMutablePointer<CChar>.allocate(capacity: bufferLength + 1)
//            defer { buffer.deallocate(capacity: bufferLength + 1) }
//            buffer[bufferLength] = 0
//            str = String(cString: UnsafePointer(buffer))
//        }
//    } else {
//        str = ""
//    }
//    
//    return ctx.appendString(str)
//}
//
//private func yajl_start_map(_ ptr: UnsafeMutableRawPointer?) -> Int32 {
//    let ctx = ptr!.assumingMemoryBound(to: Parser.self).pointee
//    return ctx.startMap()
//}
//
//private func yajl_map_key(_ ptr: UnsafeMutableRawPointer?, buffer: UnsafePointer<UInt8>?, bufferLength: Int) -> Int32 {
//    let ctx = ptr!.assumingMemoryBound(to: Parser.self).pointee
//    
//    let str: String
//    if bufferLength > 0 {
//        if bufferLength < ctx.bufferCapacity {
//            memcpy(UnsafeMutableRawPointer(ctx.buffer), UnsafeRawPointer(buffer), bufferLength)
//            ctx.buffer[bufferLength] = 0
//            str = String(cString: UnsafePointer(ctx.buffer))
//        } else {
//            var buffer = UnsafeMutablePointer<CChar>.allocate(capacity: bufferLength + 1)
//            defer { buffer.deallocate(capacity: bufferLength + 1) }
//            buffer[bufferLength] = 0
//            str = String(cString: UnsafePointer(buffer))
//        }
//    } else {
//        str = ""
//    }
//    
//    return ctx.mapKey(str)
//}
//
//private func yajl_end_map(_ ptr: UnsafeMutableRawPointer?) -> Int32 {
//    let ctx = ptr!.assumingMemoryBound(to: Parser.self).pointee
//    return ctx.endMap()
//}
//
//private func yajl_start_array(_ ptr: UnsafeMutableRawPointer?) -> Int32 {
//    let ctx = ptr!.assumingMemoryBound(to: Parser.self).pointee
//    return ctx.startArray()
//}
//    
//private func yajl_end_array(_ ptr: UnsafeMutableRawPointer?) -> Int32 {
//    let ctx = ptr!.assumingMemoryBound(to: Parser.self).pointee
//    return ctx.endArray()
//}
