////////////////////////////////////////////////////////////////////////////////
//
//  DataTaskResponseExtension.swift
//  URLAccess
//
//  Created by Iurii Khomiak on 8/23/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
/*
    Extends DataTask with methods for response serializion
*/

////////////////////////////////////////////////////////////////////////////////
public extension DataTask
{
    /// Registers default non serialized response handler.
    ///
    /// - Parameters:
    ///   - queue: Dispatch queue on that handler will be invoked. Defaults to main.
    ///   - handler: Handler that will be invoked when task will finish
    /// - Returns: Returns self for chaining purposes.
    @discardableResult
    func response(queue: DispatchQueue? = nil, handler: @escaping
        (_ result: DefaultDataResponse) -> Void) -> Self
    {
        let operation = BlockOperation
        { [weak self] in
            guard let `self` = self else { return }
            
            let response: DefaultDataResponse
            if let error = self.error
            {
                response = DefaultDataResponse(request: self.request,
                    response: self.response, data: nil, error: error)
            }
            else
            {
                response = DefaultDataResponse(request: self.request,
                    response: self.response, data: self.data, error: self.error)
            }
            
            let queue = queue ?? .main
            queue.async { handler(response) }
        }
        addResponse(with: operation)
        return self
    }
    
    /// Registers response handler with given response serializer for this task.
    ///
    /// - Parameters:
    ///   - serializer: Instance conforming to URLAccessDataResponseSerialization
    ///       protocol.
    ///   - queue: Dispatch queue on that handler will be invoked. Defaults to main.
    ///   - handler: Handler that will be invoked when task will finish
    /// - Returns: Returns self for chaining purposes.
    @discardableResult
    func response<T>(with serializer: T, queue: DispatchQueue? = nil, handler:
        @escaping (_ result: DataResponse<T.SerializedObject>) -> Void)
        -> Self
        where T : DataResponseSerialization
    {
        let operation = BlockOperation
        { [weak self] in
            guard let `self` = self else { return }
                        
            let result: Result<T.SerializedObject>
            if let error = self.error
            {
                result = .failure(error)
            }
            else
            {
                result = serializer.serialize(request: self.request,
                    response: self.response, data: self.data)
            }
            
            let response = DataResponse(request: self.request,
                response: self.response, result: result)
            let queue = queue ?? .main
            queue.async { handler(response) }
        }
        return addResponse(with: operation)
    }
    
    /// Registers response handler using given JSONDecoder instance.
    ///
    /// - Parameters:
    ///   - decoder: JSONDecoder instance
    ///   - queue: Dispatch queue on that handler will be invoked. Defaults to main.
    ///   - handler: Handler that will be invoked when task will finish
    /// - Returns: Returns self for chaining purposes.
    @discardableResult
    func responseDecodable<T>(decoder: JSONDecoder = .init(),
        queue: DispatchQueue? = nil,
        handler: @escaping (_ result: DataResponse<T>) -> Void)
        -> Self
        where T : Decodable
    {
        return response(with: JSONDecoderResponseSerializer(decoder: decoder),
            handler: handler)
    }
}
