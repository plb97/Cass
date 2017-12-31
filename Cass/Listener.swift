//
//  Listener.swift
//  Cass
//
//  Created by Philippe on 16/12/2017.
//  Copyright © 2017 PLB. All rights reserved.
//

typealias callback_t = @convention(c) (OpaquePointer?, UnsafeMutableRawPointer?) -> ()
public typealias Listener_f = (Future?, UnsafeMutableRawPointer?) -> ()
public
struct Listener {
    public let callback: Listener_f
    public let data_: UnsafeMutableRawPointer?
    public init(_ callback: @escaping Listener_f,_ data_: UnsafeMutableRawPointer? = nil) {
        self.callback = callback
        self.data_ = data_
    }
}
//@_silgen_name("callback_f")
func callback_f(future_: OpaquePointer?, data_: UnsafeMutableRawPointer?) -> () {
    if let future = future_ {
        if let data = data_ {
            let listener = data.bindMemory(to: Listener.self, capacity: 1).pointee
            defer {
                data.deallocate(bytes: MemoryLayout<Listener>.stride, alignedTo: MemoryLayout<Listener>.alignment)
            }
            listener.callback(Future(future), listener.data_)
        }
    }
}

