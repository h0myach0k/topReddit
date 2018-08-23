////////////////////////////////////////////////////////////////////////////////
//
//  StatusCodeValidation.swift
//  URLAccess
//
//  Created by Iurii Khomiak on 8/23/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
/// Responsible for validation of response based on status code
class StatusCodeValidator<T> where T : Sequence, T.Iterator.Element == Int
{
    let allowedStatusCodes: T
    
    init(allowedStatusCodes: T)
    {
        self.allowedStatusCodes = allowedStatusCodes
    }
}

////////////////////////////////////////////////////////////////////////////////
extension StatusCodeValidator : DataTaskValidation
{
    func validate(request: URLRequest?, response: HTTPURLResponse?, data:
        Data?) throws
    {
        guard let response = response else
        {
            throw URLAccessError.HTTPResponseIsEmpty
        }
        
        let statusCode = response.statusCode
        if !allowedStatusCodes.contains(statusCode)
        {
            throw URLAccessError.validationStatusCodesFailed(statusCode:
                statusCode)
        }
    }
}
