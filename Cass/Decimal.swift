//
//  Decimal.swift
//  Cass
//
//  Created by Philippe on 14/01/2018.
//  Copyright © 2018 PLHB. All rights reserved.
//

import Foundation

public typealias Decimal = Foundation.Decimal

extension Decimal {
    public init(ptr data: UnsafePointer<UInt8>?, length len: Int = 0, scale: Int32 = 0) {
        let buf = Array(UnsafeBufferPointer(start: data, count: len).reversed())
        let bytesPointer = UnsafeMutableRawPointer.allocate(bytes: 8, alignedTo: 8)
        defer {
            bytesPointer.deallocate(bytes: 8, alignedTo: 8)
        }
        bytesPointer.initializeMemory(as: UInt64.self, to: 0)
        bytesPointer.copyBytes(from: buf, count: len)
        let f = Int64(1 << (8*len))
        let pu = bytesPointer.bindMemory(to: Int64.self, capacity: 1)
        let u = pu.pointee  > f >> 1 ? pu.pointee - f : pu.pointee
        if 0 > u {
            self.init(sign:.minus, exponent: -Int(scale), significand: Decimal(-u))
        } else {
            self.init(sign:.plus, exponent: -Int(scale), significand: Decimal(u))
        }
    }
    public var decimal: (varint: UnsafePointer<UInt8>, varint_size: Int, int32: Int32) {
        let exp = Int32(self.exponent)
        let u = NSDecimalNumber(decimal: self.significand).int64Value
        var ptr = UnsafeMutableRawPointer.allocate(bytes: 8, alignedTo: 8)
        defer {
            ptr.deallocate(bytes: 8, alignedTo: 8)
        }
        ptr.storeBytes(of: u, as: Int64.self)
        let ia = Array(UnsafeBufferPointer(start: ptr.bindMemory(to: UInt8.self, capacity: 8), count: 8))
        var varint_size = 0
        for b in ia {
            varint_size += 1
            if 0 == b || 255 == b {
                break
            }
        }
        let dec = ia[0..<varint_size]
        let rdec = Array(dec.reversed())
        let varint = UnsafeRawPointer(rdec).bindMemory(to: UInt8.self, capacity: varint_size)
        let int32 = -exp
        print("A revoir decimal=\(self.description) varint=\(varint) varint_size=\(varint_size) int32=\(int32)") // TODO
        return (varint, varint_size, int32)
    }
}
