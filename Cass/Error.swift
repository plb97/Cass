//
//  Error.swift
//  Cass
//
//  Created by Philippe on 03/01/2018.
//  Copyright © 2018 PLHB. All rights reserved.
//

let FATAL_ERROR_MESSAGE = "Ne devrait pas arriver"

func default_checker(_ err: Error) -> Bool {
    if .ok != err {
        print(err)
        fatalError(err.description)
    }
    return true
}

public enum Error: CustomStringConvertible {
    case ok
    case libBadParams
    case LibNoStreams
    case LibUnableToInit
    case LibMessageEncode
    case LibHostResolution
    case LibUnexpectedResponse
    case LibRequestQueueFull
    case LibNoAvailableIoThread
    case LibWriteError
    case LibNoHostsAvailable
    case LibIndexOutOfBounds
    case LibInvalidItemCount
    case LibInvalidValueType
    case LibRequestTimedOut
    case LibUnableToSetKeyspace
    case LibCallbackAlreadySet
    case LibInvalidStatementType
    case LibNameDoesNotExist
    case LibUnableToDetermineProtocol
    case LibNullValue
    case LibNotImplemented
    case LibUnableToConnect
    case LibUnableToClose
    case LibNoPagingState
    case LibParameterUnset
    case LibInvalidErrorResultType
    case LibInvalidFutureType
    case LibInternalError
    case LibInvalidCustomType
    case LibInvalidData
    case LibNotEnoughData
    case LibInvalidState
    case LibNoCustomPayload
    case ServerServerError
    case ServerProtocolError
    case ServerBadCredentials
    case ServerUnavailable
    case ServerOverloaded
    case ServerIsBootstrapping
    case ServerTruncateError
    case ServerWriteTimeout
    case ServerReadTimeout
    case ServerReadFailure
    case ServerFunctionFailure
    case ServerWriteFailure
    case ServerSyntaxError
    case ServerUnauthorized
    case ServerInvalidQuery
    case ServerConfigError
    case ServerAlreadyExists
    case ServerUnprepared
    case SslInvalidCert
    case SslInvalidPrivateKey
    case SslNoPeerCert
    case SslInvalidPeerCert
    case SslIdentityMismatch
    case SslProtocolError
    init(_ cass: CassError) {
        self = Error.fromCass(cass)
    }
    public var description: String {
        switch self {
        case .ok: return "CASS_OK"
        case .libBadParams: return "CASS_ERROR_LIB_BAD_PARAMS"
        case .LibNoStreams: return "CASS_ERROR_LIB_NO_STREAMS"
        case .LibUnableToInit: return "CASS_ERROR_LIB_UNABLE_TO_INIT"
        case .LibMessageEncode: return "CASS_ERROR_LIB_MESSAGE_ENCODE"
        case .LibHostResolution: return "CASS_ERROR_LIB_HOST_RESOLUTION"
        case .LibUnexpectedResponse: return "CASS_ERROR_LIB_UNEXPECTED_RESPONSE"
        case .LibRequestQueueFull: return "CASS_ERROR_LIB_REQUEST_QUEUE_FULL"
        case .LibNoAvailableIoThread: return "CASS_ERROR_LIB_NO_AVAILABLE_IO_THREAD"
        case .LibWriteError: return "CASS_ERROR_LIB_WRITE_ERROR"
        case .LibNoHostsAvailable: return "CASS_ERROR_LIB_NO_HOSTS_AVAILABLE"
        case .LibIndexOutOfBounds: return "CASS_ERROR_LIB_INDEX_OUT_OF_BOUNDS"
        case .LibInvalidItemCount: return "CASS_ERROR_LIB_INVALID_ITEM_COUNT"
        case .LibInvalidValueType: return "CASS_ERROR_LIB_INVALID_VALUE_TYPE"
        case .LibRequestTimedOut: return "CASS_ERROR_LIB_REQUEST_TIMED_OUT"
        case .LibUnableToSetKeyspace: return "CASS_ERROR_LIB_UNABLE_TO_SET_KEYSPACE"
        case .LibCallbackAlreadySet: return "CASS_ERROR_LIB_CALLBACK_ALREADY_SET"
        case .LibInvalidStatementType: return "CASS_ERROR_LIB_INVALID_STATEMENT_TYPE"
        case .LibNameDoesNotExist: return "CASS_ERROR_LIB_NAME_DOES_NOT_EXIST"
        case .LibUnableToDetermineProtocol: return "CASS_ERROR_LIB_UNABLE_TO_DETERMINE_PROTOCOL"
        case .LibNullValue: return "CASS_ERROR_LIB_NULL_VALUE"
        case .LibNotImplemented: return "CASS_ERROR_LIB_NOT_IMPLEMENTED"
        case .LibUnableToConnect: return "CASS_ERROR_LIB_UNABLE_TO_CONNECT"
        case .LibUnableToClose: return "CASS_ERROR_LIB_UNABLE_TO_CLOSE"
        case .LibNoPagingState: return "CASS_ERROR_LIB_NO_PAGING_STATE"
        case .LibParameterUnset: return "CASS_ERROR_LIB_PARAMETER_UNSET"
        case .LibInvalidErrorResultType: return "CASS_ERROR_LIB_INVALID_ERROR_RESULT_TYPE"
        case .LibInvalidFutureType: return "CASS_ERROR_LIB_INVALID_FUTURE_TYPE"
        case .LibInternalError: return "CASS_ERROR_LIB_INTERNAL_ERROR"
        case .LibInvalidCustomType: return "CASS_ERROR_LIB_INVALID_CUSTOM_TYPE"
        case .LibInvalidData: return "CASS_ERROR_LIB_INVALID_DATA"
        case .LibNotEnoughData: return "CASS_ERROR_LIB_NOT_ENOUGH_DATA"
        case .LibInvalidState: return "CASS_ERROR_LIB_INVALID_STATE"
        case .LibNoCustomPayload: return "CASS_ERROR_LIB_NO_CUSTOM_PAYLOAD"
        case .ServerServerError: return "CASS_ERROR_SERVER_SERVER_ERROR"
        case .ServerProtocolError: return "CASS_ERROR_SERVER_PROTOCOL_ERROR"
        case .ServerBadCredentials: return "CASS_ERROR_SERVER_BAD_CREDENTIALS"
        case .ServerUnavailable: return "CASS_ERROR_SERVER_UNAVAILABLE"
        case .ServerOverloaded: return "CASS_ERROR_SERVER_OVERLOADED"
        case .ServerIsBootstrapping: return "CASS_ERROR_SERVER_IS_BOOTSTRAPPING"
        case .ServerTruncateError: return "CASS_ERROR_SERVER_TRUNCATE_ERROR"
        case .ServerWriteTimeout: return "CASS_ERROR_SERVER_WRITE_TIMEOUT"
        case .ServerReadTimeout: return "CASS_ERROR_SERVER_READ_TIMEOUT"
        case .ServerReadFailure: return "CASS_ERROR_SERVER_READ_FAILURE"
        case .ServerFunctionFailure: return "CASS_ERROR_SERVER_FUNCTION_FAILURE"
        case .ServerWriteFailure: return "CASS_ERROR_SERVER_WRITE_FAILURE"
        case .ServerSyntaxError: return "CASS_ERROR_SERVER_SYNTAX_ERROR"
        case .ServerUnauthorized: return "CASS_ERROR_SERVER_UNAUTHORIZED"
        case .ServerInvalidQuery: return "CASS_ERROR_SERVER_INVALID_QUERY"
        case .ServerConfigError: return "CASS_ERROR_SERVER_CONFIG_ERROR"
        case .ServerAlreadyExists: return "CASS_ERROR_SERVER_ALREADY_EXISTS"
        case .ServerUnprepared: return "CASS_ERROR_SERVER_UNPREPARED"
        case .SslInvalidCert: return "CASS_ERROR_SSL_INVALID_CERT"
        case .SslInvalidPrivateKey: return "CASS_ERROR_SSL_INVALID_PRIVATE_KEY"
        case .SslNoPeerCert: return "CASS_ERROR_SSL_NO_PEER_CERT"
        case .SslInvalidPeerCert: return "CASS_ERROR_SSL_INVALID_PEER_CERT"
        case .SslIdentityMismatch: return "CASS_ERROR_SSL_IDENTITY_MISMATCH"
        case .SslProtocolError: return "CASS_ERROR_SSL_PROTOCOL_ERROR"
        }
    }
    var cass: CassError {
        switch self {
        case .ok: return CASS_OK
        case .libBadParams: return CASS_ERROR_LIB_BAD_PARAMS
        case .LibNoStreams: return CASS_ERROR_LIB_NO_STREAMS
        case .LibUnableToInit: return CASS_ERROR_LIB_UNABLE_TO_INIT
        case .LibMessageEncode: return CASS_ERROR_LIB_MESSAGE_ENCODE
        case .LibHostResolution: return CASS_ERROR_LIB_HOST_RESOLUTION
        case .LibUnexpectedResponse: return CASS_ERROR_LIB_UNEXPECTED_RESPONSE
        case .LibRequestQueueFull: return CASS_ERROR_LIB_REQUEST_QUEUE_FULL
        case .LibNoAvailableIoThread: return CASS_ERROR_LIB_NO_AVAILABLE_IO_THREAD
        case .LibWriteError: return CASS_ERROR_LIB_WRITE_ERROR
        case .LibNoHostsAvailable: return CASS_ERROR_LIB_NO_HOSTS_AVAILABLE
        case .LibIndexOutOfBounds: return CASS_ERROR_LIB_INDEX_OUT_OF_BOUNDS
        case .LibInvalidItemCount: return CASS_ERROR_LIB_INVALID_ITEM_COUNT
        case .LibInvalidValueType: return CASS_ERROR_LIB_INVALID_VALUE_TYPE
        case .LibRequestTimedOut: return CASS_ERROR_LIB_REQUEST_TIMED_OUT
        case .LibUnableToSetKeyspace: return CASS_ERROR_LIB_UNABLE_TO_SET_KEYSPACE
        case .LibCallbackAlreadySet: return CASS_ERROR_LIB_CALLBACK_ALREADY_SET
        case .LibInvalidStatementType: return CASS_ERROR_LIB_INVALID_STATEMENT_TYPE
        case .LibNameDoesNotExist: return CASS_ERROR_LIB_NAME_DOES_NOT_EXIST
        case .LibUnableToDetermineProtocol: return CASS_ERROR_LIB_UNABLE_TO_DETERMINE_PROTOCOL
        case .LibNullValue: return CASS_ERROR_LIB_NULL_VALUE
        case .LibNotImplemented: return CASS_ERROR_LIB_NOT_IMPLEMENTED
        case .LibUnableToConnect: return CASS_ERROR_LIB_UNABLE_TO_CONNECT
        case .LibUnableToClose: return CASS_ERROR_LIB_UNABLE_TO_CLOSE
        case .LibNoPagingState: return CASS_ERROR_LIB_NO_PAGING_STATE
        case .LibParameterUnset: return CASS_ERROR_LIB_PARAMETER_UNSET
        case .LibInvalidErrorResultType: return CASS_ERROR_LIB_INVALID_ERROR_RESULT_TYPE
        case .LibInvalidFutureType: return CASS_ERROR_LIB_INVALID_FUTURE_TYPE
        case .LibInternalError: return CASS_ERROR_LIB_INTERNAL_ERROR
        case .LibInvalidCustomType: return CASS_ERROR_LIB_INVALID_CUSTOM_TYPE
        case .LibInvalidData: return CASS_ERROR_LIB_INVALID_DATA
        case .LibNotEnoughData: return CASS_ERROR_LIB_NOT_ENOUGH_DATA
        case .LibInvalidState: return CASS_ERROR_LIB_INVALID_STATE
        case .LibNoCustomPayload: return CASS_ERROR_LIB_NO_CUSTOM_PAYLOAD
        case .ServerServerError: return CASS_ERROR_SERVER_SERVER_ERROR
        case .ServerProtocolError: return CASS_ERROR_SERVER_PROTOCOL_ERROR
        case .ServerBadCredentials: return CASS_ERROR_SERVER_BAD_CREDENTIALS
        case .ServerUnavailable: return CASS_ERROR_SERVER_UNAVAILABLE
        case .ServerOverloaded: return CASS_ERROR_SERVER_OVERLOADED
        case .ServerIsBootstrapping: return CASS_ERROR_SERVER_IS_BOOTSTRAPPING
        case .ServerTruncateError: return CASS_ERROR_SERVER_TRUNCATE_ERROR
        case .ServerWriteTimeout: return CASS_ERROR_SERVER_WRITE_TIMEOUT
        case .ServerReadTimeout: return CASS_ERROR_SERVER_READ_TIMEOUT
        case .ServerReadFailure: return CASS_ERROR_SERVER_READ_FAILURE
        case .ServerFunctionFailure: return CASS_ERROR_SERVER_FUNCTION_FAILURE
        case .ServerWriteFailure: return CASS_ERROR_SERVER_WRITE_FAILURE
        case .ServerSyntaxError: return CASS_ERROR_SERVER_SYNTAX_ERROR
        case .ServerUnauthorized: return CASS_ERROR_SERVER_UNAUTHORIZED
        case .ServerInvalidQuery: return CASS_ERROR_SERVER_INVALID_QUERY
        case .ServerConfigError: return CASS_ERROR_SERVER_CONFIG_ERROR
        case .ServerAlreadyExists: return CASS_ERROR_SERVER_ALREADY_EXISTS
        case .ServerUnprepared: return CASS_ERROR_SERVER_UNPREPARED
        case .SslInvalidCert: return CASS_ERROR_SSL_INVALID_CERT
        case .SslInvalidPrivateKey: return CASS_ERROR_SSL_INVALID_PRIVATE_KEY
        case .SslNoPeerCert: return CASS_ERROR_SSL_NO_PEER_CERT
        case .SslInvalidPeerCert: return CASS_ERROR_SSL_INVALID_PEER_CERT
        case .SslIdentityMismatch: return CASS_ERROR_SSL_IDENTITY_MISMATCH
        case .SslProtocolError: return CASS_ERROR_SSL_PROTOCOL_ERROR
        }
    }
    private static func fromCass(_ cass: CassError) -> Error {
        switch cass {
        case CASS_OK: return .ok
        case CASS_ERROR_LIB_BAD_PARAMS: return .libBadParams
        case CASS_ERROR_LIB_NO_STREAMS: return .LibNoStreams
        case CASS_ERROR_LIB_UNABLE_TO_INIT: return .LibUnableToInit
        case CASS_ERROR_LIB_MESSAGE_ENCODE: return .LibMessageEncode
        case CASS_ERROR_LIB_HOST_RESOLUTION: return .LibHostResolution
        case CASS_ERROR_LIB_UNEXPECTED_RESPONSE: return .LibUnexpectedResponse
        case CASS_ERROR_LIB_REQUEST_QUEUE_FULL: return .LibRequestQueueFull
        case CASS_ERROR_LIB_NO_AVAILABLE_IO_THREAD: return .LibNoAvailableIoThread
        case CASS_ERROR_LIB_WRITE_ERROR: return .LibWriteError
        case CASS_ERROR_LIB_NO_HOSTS_AVAILABLE: return .LibNoHostsAvailable
        case CASS_ERROR_LIB_INDEX_OUT_OF_BOUNDS: return .LibIndexOutOfBounds
        case CASS_ERROR_LIB_INVALID_ITEM_COUNT: return .LibInvalidItemCount
        case CASS_ERROR_LIB_INVALID_VALUE_TYPE: return .LibInvalidValueType
        case CASS_ERROR_LIB_REQUEST_TIMED_OUT: return .LibRequestTimedOut
        case CASS_ERROR_LIB_UNABLE_TO_SET_KEYSPACE: return .LibUnableToSetKeyspace
        case CASS_ERROR_LIB_CALLBACK_ALREADY_SET: return .LibCallbackAlreadySet
        case CASS_ERROR_LIB_INVALID_STATEMENT_TYPE: return .LibInvalidStatementType
        case CASS_ERROR_LIB_NAME_DOES_NOT_EXIST: return .LibNameDoesNotExist
        case CASS_ERROR_LIB_UNABLE_TO_DETERMINE_PROTOCOL: return .LibUnableToDetermineProtocol
        case CASS_ERROR_LIB_NULL_VALUE: return .LibNullValue
        case CASS_ERROR_LIB_NOT_IMPLEMENTED: return .LibNotImplemented
        case CASS_ERROR_LIB_UNABLE_TO_CONNECT: return .LibUnableToConnect
        case CASS_ERROR_LIB_UNABLE_TO_CLOSE: return .LibUnableToClose
        case CASS_ERROR_LIB_NO_PAGING_STATE: return .LibNoPagingState
        case CASS_ERROR_LIB_PARAMETER_UNSET: return .LibParameterUnset
        case CASS_ERROR_LIB_INVALID_ERROR_RESULT_TYPE: return .LibInvalidErrorResultType
        case CASS_ERROR_LIB_INVALID_FUTURE_TYPE: return .LibInvalidFutureType
        case CASS_ERROR_LIB_INTERNAL_ERROR: return .LibInternalError
        case CASS_ERROR_LIB_INVALID_CUSTOM_TYPE: return .LibInvalidCustomType
        case CASS_ERROR_LIB_INVALID_DATA: return .LibInvalidData
        case CASS_ERROR_LIB_NOT_ENOUGH_DATA: return .LibNotEnoughData
        case CASS_ERROR_LIB_INVALID_STATE: return .LibInvalidState
        case CASS_ERROR_LIB_NO_CUSTOM_PAYLOAD: return .LibNoCustomPayload
        case CASS_ERROR_SERVER_SERVER_ERROR: return .ServerServerError
        case CASS_ERROR_SERVER_PROTOCOL_ERROR: return .ServerProtocolError
        case CASS_ERROR_SERVER_BAD_CREDENTIALS: return .ServerBadCredentials
        case CASS_ERROR_SERVER_UNAVAILABLE: return .ServerUnavailable
        case CASS_ERROR_SERVER_OVERLOADED: return .ServerOverloaded
        case CASS_ERROR_SERVER_IS_BOOTSTRAPPING: return .ServerIsBootstrapping
        case CASS_ERROR_SERVER_TRUNCATE_ERROR: return .ServerTruncateError
        case CASS_ERROR_SERVER_WRITE_TIMEOUT: return .ServerWriteTimeout
        case CASS_ERROR_SERVER_READ_TIMEOUT: return .ServerReadTimeout
        case CASS_ERROR_SERVER_READ_FAILURE: return .ServerReadFailure
        case CASS_ERROR_SERVER_FUNCTION_FAILURE: return .ServerFunctionFailure
        case CASS_ERROR_SERVER_WRITE_FAILURE: return .ServerWriteFailure
        case CASS_ERROR_SERVER_SYNTAX_ERROR: return .ServerSyntaxError
        case CASS_ERROR_SERVER_UNAUTHORIZED: return .ServerUnauthorized
        case CASS_ERROR_SERVER_INVALID_QUERY: return .ServerInvalidQuery
        case CASS_ERROR_SERVER_CONFIG_ERROR: return .ServerConfigError
        case CASS_ERROR_SERVER_ALREADY_EXISTS: return .ServerAlreadyExists
        case CASS_ERROR_SERVER_UNPREPARED: return .ServerUnprepared
        case CASS_ERROR_SSL_INVALID_CERT: return .SslInvalidCert
        case CASS_ERROR_SSL_INVALID_PRIVATE_KEY: return .SslInvalidPrivateKey
        case CASS_ERROR_SSL_NO_PEER_CERT: return .SslNoPeerCert
        case CASS_ERROR_SSL_INVALID_PEER_CERT: return .SslInvalidPeerCert
        case CASS_ERROR_SSL_IDENTITY_MISMATCH: return .SslIdentityMismatch
        case CASS_ERROR_SSL_PROTOCOL_ERROR: return .SslProtocolError
        default:
            fatalError(FATAL_ERROR_MESSAGE)
        }
    }
    @discardableResult
    public func check(checker: ((_ err: Error) -> Bool) = default_checker) -> Bool {
        return checker(self)
    }
}

extension CassError: CustomStringConvertible {
    public var description: String {
        if let str = String(validatingUTF8: cass_error_desc(self)) {
            return str
        } else {
            fatalError(FATAL_ERROR_MESSAGE) // ne devrait pas se produire
        }
    }
}

