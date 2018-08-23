////////////////////////////////////////////////////////////////////////////////
//
//  DefaultDataResponse.swift
//  URLAccess
//
//  Created by Iurii Khomiak on 8/23/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
/// Provides data structure to hold raw/unserialized response information
public struct DefaultDataResponse
{
    /// Contains original URLRequest
    public let request: URLRequest?
    /// Contains received HTTPURLResponse
    public let response: HTTPURLResponse?
    /// Contains downloaded data
    public let data: Data?
    /// Contains error
    public let error: Error?
}
