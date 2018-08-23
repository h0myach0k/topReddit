////////////////////////////////////////////////////////////////////////////////
//
//  JSONDecoderResponseSerializer.swift
//  URLAccess
//
//  Created by Iurii Khomiak on 8/23/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
/// Response serializer based on JSONDecoder
class JSONDecoderResponseSerializer<Object> : DataResponseSerialization
    where Object : Decodable
{
    //! MARK: - Properties
    let decoder: JSONDecoder
    
    //! MARK: - Init & Deinit
    init(decoder: JSONDecoder)
    {
        self.decoder = decoder
    }
    
    //! MARK: - As ResponseSerialization
    func serialize(request: URLRequest?, response: HTTPURLResponse?,
        data: Data?) -> Result<Object>
    {
        guard let data = data else
        {
            return .failure(URLAccessError.jsonSerializationDataIsEmpty)
        }
        do
        {
            let result = try decoder.decode(Object.self, from: data)
            return .success(result)
        }
        catch
        {
            return .failure(URLAccessError.jsonSerializationError(error))
        }
    }
}
