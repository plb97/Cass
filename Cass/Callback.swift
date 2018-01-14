//
//  Callback.swift
//  Cass
//
//  Created by Philippe on 16/12/2017.
//  Copyright © 2017 PLB. All rights reserved.
//

/*
 !!! ATTENTION !!!

 The type T to be stored must be a trivial type. The memory at this pointer plus offset must be properly aligned for accessing T. The memory must also be uninitialized, initialized to T, or initialized to another trivial type that is layout compatible with T.

 A trivial type can be copied bit for bit with no indirection or reference-counting operations. Generally, native Swift types that do not contain strong or weak references or other forms of indirection are trivial, as are imported C structs and enumerations.

 */
/*
 REMARQUE
 Le type 'Callback' est 'trivial' (c'est une 'struct' ne contenant que des champs simples : deux pointeurs et deux entiers)
 Dans l'exemple 'callbacks' le type 'Session' est bien trivial (c'est une class (struct) ne contenant qu'un pointeur et pour lequel il ne faut pas gerer de "reference-counting")
 Dans un cas plus complexe, il faut etre conscient que l'ARC (Automatic Reference Counting) est contourne, mais c'est justemnt ce qui etait voulu...
 TODO : tester beaucoup plus severement pour etre sur que cette approche reste correcte en general.
 */
fileprivate func toPointer<T>(_ p_: T?) -> UnsafeMutableRawPointer? {
    if let p = p_ {
        let ptr = UnsafeMutableRawPointer.allocate(bytes: MemoryLayout<T>.stride, alignedTo:MemoryLayout<T>.alignment)
        ptr.storeBytes(of: p, as: type(of: p))
        return ptr
    }
    return nil
}

public struct CallbackData {
    private let data_: UnsafeMutableRawPointer?
    private let ftrp : OpaquePointer
    public let future: Future
    fileprivate init(future ftrp: OpaquePointer, data data_: UnsafeMutableRawPointer? = nil) {
        self.ftrp  = ftrp
        self.data_ = data_
        self.future = Future(ftrp)
    }
    public func data<T>(as type: T.Type) -> T? {
        if let data = self.data_ {
            return data.bindMemory(to: type, capacity: 1).pointee
        }
        return nil
    }
}
public typealias CallbackFunction = (CallbackData) -> ()

public struct Callback {
    static func setCallback(future: OpaquePointer, callback: Callback) {
        cass_future_set_callback(future, default_callback, toPointer(callback))
    }
    fileprivate let callback: CallbackFunction
    fileprivate let data_: UnsafeMutableRawPointer?
    fileprivate let data_bytes: Int
    fileprivate let data_alignment: Int
    public init<T>(callback: @escaping CallbackFunction, data p_: T? = nil) {
        self.callback = callback
        self.data_ = toPointer(p_)
        self.data_bytes = MemoryLayout<T>.stride
        self.data_alignment = MemoryLayout<T>.alignment
    }
}

//fileprivate typealias callback_t = @convention(c) (OpaquePointer?, UnsafeMutableRawPointer?) -> ()
fileprivate func default_callback(future_: OpaquePointer?, data_: UnsafeMutableRawPointer?) -> () {
    if let data = data_ {
        let callback = data.bindMemory(to: Callback.self, capacity: 1).pointee
        defer {
            if let ptr = callback.data_ {
                ptr.deallocate(bytes: callback.data_bytes, alignedTo: callback.data_alignment)
            }
            data.deallocate(bytes: MemoryLayout<Callback>.stride, alignedTo: MemoryLayout<Callback>.alignment)
        }
        if let future = future_ {
            callback.callback(CallbackData(future: future, data: callback.data_))
        }
    } else {
        fatalError("Ne devrait pas arriver")
    }
}
