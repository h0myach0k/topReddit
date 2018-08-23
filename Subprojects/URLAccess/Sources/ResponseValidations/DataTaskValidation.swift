////////////////////////////////////////////////////////////////////////////////
//
//  DataTaskValidation.swift
//  URLAccess
//
//  Created by Iurii Khomiak on 8/23/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
/// Interface for data task validation
/// Clients can adopt this interface and provide own validation rules
public protocol DataTaskValidation
{
    /// Validates data task properties and throw an error when validation fails
    ///
    /// - Parameters:
    ///   - request: Original URLRequest
    ///   - response: Received HTTPURLResponse
    ///   - data: Received Data
    /// - Throws: Error, when validation fails
    func validate(request: URLRequest?, response: HTTPURLResponse?, data:
        Data?) throws
}
