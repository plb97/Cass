//
//  Udt.swift
//  Cass
//
//  Created by Philippe on 15/01/2018.
//  Copyright © 2018 PLHB. All rights reserved.
//


public class Udt: Collection {
    public typealias Element = Any?
    var array: Array<Element>
    var map: Dictionary<String, Int>
    public init(count: Int) {
        self.array = Array(repeating: nil, count: count)
        self.map = Dictionary()
    }
    // minimum requis pour satisfaire le protocole 'Collection'
    public var startIndex: Int { return 0 }
    public var endIndex: Int   { return array.count }
    public func index(after i: Int) -> Int {
        precondition(i < array.count, "Can't advance beyond endIndex")
        return i + 1
    }
    public subscript(index: Int) -> Element {
        get {
            precondition(0 <= index && index < array.count, "index out of bounds")
            return array[index]
        }
        set (newValue) {
            precondition(0 <= index && index < array.count, "index out of bounds")
            array[index] = newValue
        }
    }
    public subscript(name: String) -> Element {
        get {
            if let index = self.map[name] {
                return array[index]
            } else {
                precondition(false, "index out of bounds")
            }
        }
        set (newValue) {
            if let index = self.map[name] {
                array[index] = newValue
            } else {
                precondition(false, "index out of bounds")
            }
        }
    }
}
