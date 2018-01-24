//
//  BLOB.swift
//  Cass
//
//  Created by Philippe on 24/01/2018.
//  Copyright © 2018 PLHB. All rights reserved.
//

struct BLOB: RandomAccessCollection, MutableCollection {
    typealias Element = UInt8
    typealias Index = Int
    var array: [Element]
    var startIndex: Int { return array.startIndex }
    var endIndex: Int { return array.endIndex }
    init(_ array: Array<UInt8>) {
        self.array = array
    }
    init(repeating: UInt8, count: Int) {
        self.array = Array(repeating: repeating, count: count)
    }
    init(ptr buf_: UnsafePointer<UInt8>? = nil, len: Int = 0) {
        if let buf = buf_, 0 < len {
            self.array = Array(UnsafeBufferPointer(start: buf, count: len))
        } else {
            self.array = Array()
        }
    }
    func index(after i: Int) -> Int {
        return array.index(after:i)
    }
    func index(before i: Int) -> Int {
        return array.index(before: i)
    }
    subscript(position: Int) -> UInt8 {
        get {
            return array[position]
        }
        set(newValue) {
            array[position] = newValue
        }
    }
    var cass: (UnsafePointer<UInt8>, size_t) { return (ptr: UnsafePointer<UInt8>(self.array), len: self.array.count) }
}

