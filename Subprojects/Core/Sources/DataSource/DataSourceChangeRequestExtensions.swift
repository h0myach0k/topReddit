////////////////////////////////////////////////////////////////////////////////
//
//  DataSourceChangeRequestExtensions.swift
//  Core
//
//  Created by Iurii Khomiak on 8/25/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
public extension DataSource
{
    func changeRequestToCleanValue() -> ChangeRequest
    {
        return ChangeRequest(delete: value)
    }
    
    public func changeRequest(toReplaceValue value: Value?) ->
        DataSourceChangeRequest<Value>
    {
        return ChangeRequest(replace: self.value, with: value)
    }
}
    
////////////////////////////////////////////////////////////////////////////////
public extension DataSource where Value : RangeReplaceableCollection,
    Value.Index == Int
{
    public func changeRequestToCleanValue() -> DataSourceChangeRequest<Value>
    {
        return ChangeRequest(delete: value)
    }
    
    public func changeRequest(toReplaceValue value: Value?) ->
        DataSourceChangeRequest<Value>
    {
        return ChangeRequest(replace: self.value, with: value)
    }    
}
