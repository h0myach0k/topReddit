////////////////////////////////////////////////////////////////////////////////
//
//  DataTaskValidationExtension.swift
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
    Extends DataTask with methods for response validation.
    Validation process is designed to be performed right after request is
        completed without error, before response parsing.
*/

////////////////////////////////////////////////////////////////////////////////
public extension DataTask
{
    /// Registers given validator
    ///
    /// - Parameter validator: Instance conforming to DataTaskValidation interface
    /// - Returns: Returns self for chaining purposes.
    @discardableResult
    func validate(validator: DataTaskValidation) -> Self
    {
        addValidation
        { [weak self] in
            guard let `self` = self else { return }
            try validator.validate(request: self.request, response:
                self.response, data: self.data)
        }
        return self
    }
    
    /// Registers status code validator with given allowed status codes
    ///
    /// - allowedStatusCodes: Any sequnce that elements are Int values
    /// - Returns: Returns self for chaining purposes.
    @discardableResult
    func validate<S>(allowedStatusCodes: S) -> Self
        where S : Sequence, S.Iterator.Element == Int
    {
        validate(validator: StatusCodeValidator(allowedStatusCodes:
            allowedStatusCodes))
        return self
    }
}

