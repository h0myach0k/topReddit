////////////////////////////////////////////////////////////////////////////////
//
//  DataResponseSerialization.swift
//  URLAccess
//
//  Created by Iurii Khomiak on 8/23/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
/// Describes interface to convert data to serialized object
/// Clients can adopt to create own implementation of response serializer
public protocol DataResponseSerialization
{
    associatedtype SerializedObject
    
    /// Performs serialization from task related properties to Result
    ///
    /// - Parameters:
    ///   - request: Original URLRequest
    ///   - response: Received HTTPURLResponse
    ///   - data: Received raw Data
    /// - Returns: Serialized Result
    func serialize(request: URLRequest?, response: HTTPURLResponse?, data:
        Data?) -> Result<SerializedObject>
}
