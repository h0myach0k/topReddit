////////////////////////////////////////////////////////////////////////////////
//
//  DataResponse.swift
//  URLAccess
//
//  Created by Iurii Khomiak on 8/23/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
/// Describes data structure for serialized response
public struct DataResponse<Object>
{
    /// Contains original URLRequest
    public let request: URLRequest?
    /// Contains received HTTPURLResponse
    public let response: HTTPURLResponse?
    /// Contains serialized result
    public let result: Result<Object>
    /// Returns error if available
    public var error: Error? { return result.error }
    /// Returns value if available
    public var value: Object? { return result.value }
}
