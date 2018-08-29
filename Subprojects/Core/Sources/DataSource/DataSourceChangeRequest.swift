////////////////////////////////////////////////////////////////////////////////
//
//  DataSourceChangeRequest.swift
//  Core
//
//  Created by Iurii Khomiak on 8/25/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
/// Private representation of additional data linked with collections
fileprivate struct Indexes
{
    var inserted: IndexSet?
    var deleted: IndexSet?
    var updated: IndexSet?
    
    init(inserted: IndexSet? = nil, deleted: IndexSet? = nil, updated:
        IndexSet? = nil)
    {
        self.inserted = inserted
        self.deleted = deleted
        self.updated = updated
    }
}

////////////////////////////////////////////////////////////////////////////////
/// Describes data source change request
public struct DataSourceChangeRequest<Value>
{
    public let value: Value?
    fileprivate let indexes: Indexes?
}

////////////////////////////////////////////////////////////////////////////////
public extension DataSourceChangeRequest where Value : Collection
{
    /// Contains indexes that were inserted
    var insertedIndexes: IndexSet { return indexes?.inserted ?? .init()}
    /// Contains indexes that were deleted
    var deletedIndexes: IndexSet { return indexes?.deleted ?? .init()}
    /// Contains indexes that were updated
    var updatedIndexes: IndexSet { return indexes?.updated ?? .init()}
}

////////////////////////////////////////////////////////////////////////////////
extension DataSourceChangeRequest
{
    init(replace oldValue: Value?, with value: Value?)
    {
        self.init(value: value, indexes: nil)
    }
    
    init(delete value: Value?)
    {
        self.init(value: nil, indexes: nil)
    }
}

////////////////////////////////////////////////////////////////////////////////
extension DataSourceChangeRequest where Value : RangeReplaceableCollection,
    Value.Index == Int
{
    init(append items: Value, to current: Value)
    {
        let value = current + items
        let inserted = IndexSet(current.count..<value.count)
        self.init(value: value, indexes: Indexes(inserted: inserted))
    }
    
    init(insert item: Value.Iterator.Element, at index: Int, to current: Value)
    {
        var value = current
        value.insert(item, at: index)
        let inserted = IndexSet(index..<index + 1)
        self.init(value: value, indexes: Indexes(inserted: inserted))
    }
    
    init(insert items: Value, at index: Int, to current: Value)
    {
        var value = current
        value.insert(contentsOf: items, at: index)
        let inserted = IndexSet(index..<index + items.count)
        self.init(value: value, indexes: Indexes(inserted: inserted))
    }
    
    init(replace oldValue: Value?, with value: Value?)
    {
        let inserted = IndexSet(0..<(value?.count ?? 0))
        let deleted = IndexSet(0..<(oldValue?.count ?? 0))
        self.init(value: value, indexes: Indexes(inserted: inserted,
            deleted: deleted))
    }
    
    init(delete value: Value?)
    {
        let deleted = nil != value ? IndexSet(0..<value!.count) : nil
        self.init(value: Value(), indexes: Indexes(deleted: deleted))
    }
}
