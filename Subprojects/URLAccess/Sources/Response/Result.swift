////////////////////////////////////////////////////////////////////////////////
//
//  Result.swift
//  URLAccess
//
//  Created by Iurii Khomiak on 8/23/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
public enum Result<Object>
{
    case success(Object)
    case failure(Error)
}

////////////////////////////////////////////////////////////////////////////////
public extension Result
{
    var error: Error?
    {
        if case let .failure(error) = self
        {
            return error
        }
        return nil
    }
    
    var value: Object?
    {
        if case let .success(object) = self
        {
            return object
        }
        return nil
    }
}

////////////////////////////////////////////////////////////////////////////////
public extension Result
{
    func map<T>(_ transform: (Object) -> T) -> Result<T>
    {
        switch self
        {
            case .success(let object):
                return .success(transform(object))
            case .failure(let error):
                return .failure(error)
        }
    }
}
