////////////////////////////////////////////////////////////////////////////////
//
//  DataStore.swift
//  DataStore
//
//  Created by h0myach0k on 8/24/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
/// Structure describes additional store properties
public struct StoreProperties
{
    /// Property containing time interval that allows stored object live in
    ///     data store
    var validTimeInterval: TimeInterval?
}

////////////////////////////////////////////////////////////////////////////////
/// Interface for data store provider
protocol DataStore
{
    /// Stores object for given key
    ///
    /// - Parameters:
    ///   - object: Object to store
    ///   - key: Unique key that is used for object identification
    func store<T>(object: T, for key: String) where T : Storable
    
    /// Stores object for given key with given properties
    ///
    /// - Parameters:
    ///   - object: Object to store
    ///   - key: Unique key that is used for object identification
    ///   - properties: Additional storage properties
    func store<T>(object: T, for key: String, properties: StoreProperties)
        where T : Storable
    
    /// Returns object from storage it its available
    ///
    /// - Parameter key: Unique key that is used for object identification
    /// - Returns: Serialized object if its available in storage, nil otherwise
    func object<T>(for key: String) -> T? where T : Storable
    
    /// Checks if store contains object for given key
    ///
    /// - Parameter key: Unique key that is used for object identification
    /// - Returns: true if data store contains object, false otherwise
    func containsObject(for key: String) -> Bool
    
    /// Removes object for given key
    ///
    /// - Parameter key: Unique key that is used for object identification
    func removeObject(for key: String)
    
    /// Removes all objects that are stored in data store
    func clear()
}
