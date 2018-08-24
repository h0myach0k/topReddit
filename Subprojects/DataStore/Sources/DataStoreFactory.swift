////////////////////////////////////////////////////////////////////////////////
//
//  DataStoreFactory.swift
//  DataStore
//
//  Created by Iurii Khomiak on 8/24/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
/// Data store provider factory class
public class DataStoreFactory
{
    /// Describes Store Type
    ///
    /// - file: File system store
    public enum StoreType
    {
        case fileSystem(directory: FileManager.SearchPathDirectory, domainMask:
            FileManager.SearchPathDomainMask)
    }
    
    /// Creates new data store with given parameters
    ///
    /// - Parameters:
    ///   - identifier: Data store identifier
    ///   - type: Data store type
    /// - Returns: newly created DataStore
    /// - Throws: Error thrown during data store creation
    public func createDataStore(identifier: String, type: StoreType) throws -> DataStore
    {
        switch type
        {
            case let .fileSystem(directory, domain):
                return try FileSystemDataStore(identifier: identifier,
                    searchPathDirectory: directory,
                    searchPathDomainMask: domain)
        }
    }
}
