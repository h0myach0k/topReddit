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
    
    public func changeRequest(toReplaceValue value: Value?) -> ChangeRequest
    {
        return ChangeRequest(replace: self.value, with: value)
    }
}
    
////////////////////////////////////////////////////////////////////////////////
public extension DataSource where Value : RangeReplaceableCollection,
    Value.Index == Int
{
    public func changeRequestToCleanValue() -> ChangeRequest
    {
        return ChangeRequest(delete: value)
    }
    
    public func changeRequest(toReplaceValue value: Value?) -> ChangeRequest
    {
        return ChangeRequest(replace: self.value, with: value)
    }
    
    public func changeRequestToAppend(items: Value) -> ChangeRequest
    {
        return ChangeRequest(append: items, to: value ?? Value())
    }
    
    public func changeRequestToInsert(items: Value, at index: Int) -> ChangeRequest
    {
        return ChangeRequest(insert: items, at: index, to: value ?? Value())
    }
}
