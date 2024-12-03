//
//  HTTPClient.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A utility / service that is used to perform HTTP requests.
/// Deals with all the specifics of the HTTP protocol (headers, status codes, error handling, etc).
///
class HTTPClient {

    static let shared: HTTPClient = HTTPClient()

    private init() {}

    ///
    /// Performs a HTTP GET request to the specified URL, with the given request headers and connection timeout interval (specified in seconds).
    ///
    /// - Returns the data obtained from the response body as raw bytes.
    ///
    /// - throws an error if one occurred while making the request.
    ///
    func performGET(toURL url: URL, withHeaders headers: [String: String], timeout: Int = 5) throws
        -> Data
    {
        // Construct a request object with the specified URL and headers.
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        request.httpMethod = URLRequest.GETMethod
        request.timeoutInterval = TimeInterval(timeout)

        let (data, response) = try performSynchronousRequest(request)

        if let response = response as? HTTPURLResponse, response.failed {
            throw HTTPError.fromCode(response.statusCode, forURL: url)
        }

        return data
    }

    ///
    /// Performs a HTTP GET request to the specified URL, with the given request headers and connection timeout interval (specified in seconds),
    /// and deserializes the response as JSON.
    ///
    /// - Returns an optional NSDictionary containing the response body (deserialized from JSON). nil if the response could not be deserialized as JSON.
    ///
    /// - throws an error if one occurred while making the request.
    ///
    func performGETForJSON(
        toURL url: URL,
        withHeaders headers: [String: String],
        timeout: Int = 5
    )
        throws -> NSDictionary?
    {
        return try performGET(toURL: url, withHeaders: headers, timeout: timeout).toJSONObject()
    }

    ///
    /// Performs a HTTP GET request to the specified URL, with the given request headers and connection timeout interval (specified in seconds),
    /// and returns the URL from the response. This function assumes that an HTTP redirect will occur, so the function returns the redirect URL.
    ///
    /// - Returns: The response URL (redirect URL). May be nil.
    ///
    /// - throws an error if one occurred while making the request.
    ///
    func performGETForRedirect(toURL url: URL, timeout: Int = 5) throws -> URL? {

        // Construct a request object with the specified URL and headers.
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = [:]
        request.httpMethod = URLRequest.GETMethod
        request.timeoutInterval = TimeInterval(timeout)

        let (_, response) = try performSynchronousRequest(request)

        return response?.url
    }

    func performPOST(
        toURL url: URL,
        withHeaders headers: [String: String]? = nil,
        withBody body: Data? = nil,
        timeout: Int = 5
    ) throws {
        // Construct a request object with the specified URL and headers.
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        request.httpMethod = URLRequest.POSTMethod
        request.timeoutInterval = TimeInterval(timeout)

        let (_, response) = try performSynchronousRequest(request)

        // Check the response for errors (based on status code)
        if let response = response as? HTTPURLResponse, response.failed {
            // Construct an appropriate error from the status code and throw it.
            throw HTTPError.fromCode(response.statusCode, forURL: url)
        }
    }

    ///
    /// Performs a synchronous HTTP request and returns the data and response.
    ///
    /// Just a wrapper for URLSession.shared.dataTask, replace NSURLConnection.sendSynchronousRequest()
    ///
    private func performSynchronousRequest(_ request: URLRequest) throws -> (Data, URLResponse?) {
        let semaphore = DispatchSemaphore(value: 0)
        var resultData: Data?
        var resultResponse: URLResponse?
        var resultError: Error?

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            resultData = data
            resultResponse = response
            resultError = error
            semaphore.signal()
        }
        task.resume()

        _ = semaphore.wait(timeout: .now() + request.timeoutInterval)

        if let error = resultError {
            throw error
        }

        guard let data = resultData else {
            let response = resultResponse as? HTTPURLResponse
            throw HTTPError.fromCode(response?.statusCode ?? 0, forURL: request.url!)
        }

        return (data, resultResponse)
    }
}

extension URLRequest {

    static let GETMethod: String = "GET"
    static let POSTMethod: String = "POST"
}

extension HTTPURLResponse {

    ///
    /// Checks the statusCode to determine if the response indicates the successful processing of a request.
    ///
    var succeeded: Bool { statusCode.equalsOneOf(200, 307) }

    ///
    /// Checks the statusCode to determine if the response indicates the failed processing of a request.
    ///
    var failed: Bool { !succeeded }
}

extension Data {

    ///
    /// Attempts to construct an NSDictionary by deserializing this object's bytes as JSON.
    ///
    func toJSONObject() throws -> NSDictionary? {
        return try JSONSerialization.jsonObject(with: self, options: []) as? NSDictionary
    }
}
