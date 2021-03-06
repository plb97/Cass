//
//  AuthenticatorCallbacks.swift
//  Cass
//
//  Created by Philippe on 30/12/2017.
//  Copyright © 2017 PLHB. All rights reserved.
//

typealias initial_callback_f = @convention(c) (OpaquePointer?, UnsafeMutableRawPointer?) -> ()
typealias challenge_callback_f = @convention(c) (OpaquePointer?, UnsafeMutableRawPointer?, UnsafePointer<Int8>?, Int) -> ()
typealias success_callback_f = @convention(c) (OpaquePointer?, UnsafeMutableRawPointer?, UnsafePointer<Int8>?, Int) -> ()
typealias cleanup_callback_f = @convention(c) (OpaquePointer?, UnsafeMutableRawPointer?) -> ()
typealias data_cleanup_callback_f = @convention(c) (UnsafeMutableRawPointer?) -> ()

public typealias InitialCallback_f = (Authenticator, Response) -> ()
public typealias ChallengeCallback_f = (Authenticator, Response, String?) -> ()
public typealias SuccessCallback_f = (Authenticator, Response, String?) -> ()
public typealias CleanupCallback_f = (Authenticator, Response) -> ()
public typealias DataCleanupCallback_f = (Response) -> ()

func default_inital_callback(_ auth_: OpaquePointer?,_ data_: UnsafeMutableRawPointer?) {
    if let auth = auth_, let data = data_ {
        let authenticatorCallbacks = pointee(data, as: AuthenticatorCallbacks.self)
        if let initialCallback = authenticatorCallbacks.initialCallback_ {
            let authenticator = Authenticator(auth: auth)
            let response = authenticatorCallbacks.response
            initialCallback(authenticator, response)
        }
    } else {
        fatalError(FATAL_ERROR_MESSAGE)
    }
}
func default_challenge_callback(_ auth_: OpaquePointer?,_ data_: UnsafeMutableRawPointer?,_ token_: UnsafePointer<Int8>? = nil, _ token_length: Int = 0) {
    if let auth = auth_, let data = data_ {
        let authenticatorCallbacks = pointee(data, as: AuthenticatorCallbacks.self)
        if let challengeCallback = authenticatorCallbacks.challengeCallback_ {
            let authenticator = Authenticator(auth: auth)
            let response = authenticatorCallbacks.response
            let token = String(ptr: token_, len: token_length)
            challengeCallback(authenticator, response, token)
        }
    } else {
        fatalError(FATAL_ERROR_MESSAGE)
    }
}
func default_success_callback(_ auth_: OpaquePointer?,_ data_: UnsafeMutableRawPointer?,_ token_: UnsafePointer<Int8>? = nil, _ token_length: Int = 0) {
    if let auth = auth_, let data = data_ {
        let authenticatorCallbacks = pointee(data, as: AuthenticatorCallbacks.self)
        if let successCallback = authenticatorCallbacks.successCallback_ {
            let authenticator = Authenticator(auth: auth)
            let response = authenticatorCallbacks.response
            let token = String(ptr: token_, len: token_length)
            successCallback(authenticator, response, token)
        }
    } else {
        fatalError(FATAL_ERROR_MESSAGE)
    }
}
func default_cleanup_callback(_ auth_: OpaquePointer?,_ data_: UnsafeMutableRawPointer?) {
    if let auth = auth_, let data = data_ {
        let authenticatorCallbacks = pointee(data, as: AuthenticatorCallbacks.self)
        if let cleanupCallback = authenticatorCallbacks.cleanupCallback_ {
            let authenticator = Authenticator(auth: auth)
            let response = authenticatorCallbacks.response
            cleanupCallback(authenticator, response)
        }
    } else {
        fatalError(FATAL_ERROR_MESSAGE)
    }
}
func default_data_cleanup_callback(_ data_: UnsafeMutableRawPointer?) {
    defer {
        deallocPointer(data_, as: AuthenticatorCallbacks.self)
    }
    if let data = data_ {
        let authenticatorCallbacks = pointee(data, as: AuthenticatorCallbacks.self)
        if let dataCleanupCallback = authenticatorCallbacks.dataCleanupCallback_ {
            dataCleanupCallback(authenticatorCallbacks.response)
        }
    } else {
        fatalError(FATAL_ERROR_MESSAGE)
    }
}

var default_exchange_callbacks = CassAuthenticatorCallbacks(
    initial_callback: default_inital_callback,
    challenge_callback: default_challenge_callback,
    success_callback: default_success_callback,
    cleanup_callback: default_cleanup_callback)

public
struct AuthenticatorCallbacks {
    let initialCallback_: InitialCallback_f?
    let challengeCallback_: ChallengeCallback_f?
    let successCallback_: SuccessCallback_f?
    let cleanupCallback_: CleanupCallback_f?
    let dataCleanupCallback_: DataCleanupCallback_f?
    let response: Response
    public init(initialCallback: InitialCallback_f? = nil
        , challengeCallback: ChallengeCallback_f? = nil
        , successCallback: SuccessCallback_f? = nil
        , cleanupCallback: CleanupCallback_f? = nil
        , dataCleanupCallback: DataCleanupCallback_f? = nil
        , response: Response) {
        initialCallback_ = initialCallback
        challengeCallback_ = challengeCallback
        successCallback_ = successCallback
        cleanupCallback_ = cleanupCallback
        dataCleanupCallback_ = dataCleanupCallback
        self.response = response
    }
}
