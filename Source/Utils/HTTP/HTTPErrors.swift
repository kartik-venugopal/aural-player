//
//  HTTPErrors.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A generic base class for errors encountered when making HTTP requests.
///
class HTTPError: Error {
    
    // Constants representing different HTTP error codes.
    static let error_notFound: Int = 404
    static let error_forbidden: Int = 403
    static let error_internalServerError: Int = 500
    static let error_serviceUnavailable: Int = 503

    ///
    /// HTTP error code.
    ///
    var code: Int
    
    ///
    /// A user-friendly description of this error.
    ///
    var description: String
    
    ///
    /// The URL that the failed request was trying to access.
    ///
    var url: URL
    
    init(code: Int, description: String, url: URL) {
        
        self.code = code
        self.description = description
        self.url = url
    }
    
    ///
    /// A factory method that constructs a suitable HTTPError object from an error code.
    ///
    static func fromCode(_ code: Int, forURL url: URL) -> HTTPError {
        
        switch code {
        
        case Self.error_notFound:   return HTTPNotFoundError(url: url)
            
        case Self.error_forbidden:  return HTTPForbiddenError(url: url)
            
        case Self.error_internalServerError:    return HTTPInternalServerError(url: url)
            
        case Self.error_serviceUnavailable:     return HTTPServiceUnavailableError(url: url)
            
        default:    return HTTPError(code: code, description: "The request failed with error code \(code).", url: url)
            
        }
    }
}

///
/// Represents an HTTP "404 Not Found" error.
///
class HTTPNotFoundError: HTTPError {
    
    init(url: URL) {
        super.init(code: HTTPError.error_notFound, description: "The requested resource was not found.", url: url)
    }
}

///
/// Represents an HTTP "403 Forbidden" error.
///
class HTTPForbiddenError: HTTPError {
    
    init(url: URL) {
        super.init(code: HTTPError.error_forbidden, description: "Access to the requested resource is forbidden by the server.", url: url)
    }
}

///
/// Represents an HTTP "500 Internal Server Error" error.
///
class HTTPInternalServerError: HTTPError {
    
    init(url: URL) {
        super.init(code: HTTPError.error_internalServerError, description: "The server encountered an error while accessing the requested resource.", url: url)
    }
}

///
/// Represents an HTTP "503 Service Unavailable" error.
///
class HTTPServiceUnavailableError: HTTPError {
    
    init(url: URL) {
        super.init(code: HTTPError.error_serviceUnavailable, description: "The server is unavailable and cannot retrieve the requested resource.", url: url)
    }
}
