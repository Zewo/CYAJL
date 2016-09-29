//
//  YAJL.swift
//  YAJL
//
//  Created by Robert Payne on 30/03/16.
//  Copyright © 2016 Sense Medical Limited. All rights reserved.
//

import Foundation

public struct YAJLError: Error {
    public let message: String
    
    public init(message: String) {
        self.message = message
    }
}

public struct YAJL {
    
    public static func parse(_ data: UnsafePointer<UInt8>, length: Int) throws -> Map {
        return try Parser.parse(data, length: length)
    }
    
    public static func parse(_ bytes: [UInt8]) throws -> Map {
        return try bytes.withUnsafeBufferPointer {
            try Parser.parse($0.baseAddress!, length: bytes.count)
        }
        
    }
    
    public static func generate(_ object: AnyObject) throws -> String {
        return try Generator.generate(object)
    }
    
}
