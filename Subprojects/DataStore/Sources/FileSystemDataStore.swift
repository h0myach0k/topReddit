////////////////////////////////////////////////////////////////////////////////
//
//  FileSystemDataStore.swift
//  DataStore
//
//  Created by Iurii Khomiak on 8/24/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation
import Core

////////////////////////////////////////////////////////////////////////////////
fileprivate var storeFolderNameFormat = "com.h0myach0k.store.%@"
fileprivate var infoFileName = "com.h0myach0k.store.info"
fileprivate var fsQueueName = "com.h0myach0k.store.queue"
fileprivate var cacheFileExtension = "ds"

////////////////////////////////////////////////////////////////////////////////
/// File System data store implementation. Stores each object as separate file.
class FileSystemDataStore
{
    //! MARK: - Forward Declaration
    private enum InfoKey : String
    {
        case fileName
        case timeStamp
        case timeInterval
    }
    
    //! MARK: - Properties
    let identifier: String
    private let fsQueue = DispatchQueue.init(label: fsQueueName, attributes:
        .concurrent)
    private let storeFolder: String
    private var info: [String : [String : Any]] = [:]
    
    //! MARK: - Init & Deinit
    init(identifier: String,
        searchPathDirectory: FileManager.SearchPathDirectory = .cachesDirectory,
        searchPathDomainMask: FileManager.SearchPathDomainMask = .userDomainMask) throws
    {
        let path = try FileSystemDataStore.storeFolder(with: identifier,
            searchPathDirectory: searchPathDirectory, searchPathDomainMask:
            searchPathDomainMask)
        
        self.identifier = identifier
        self.storeFolder = path
        info = loadInfo()
        cleanupInvalidEntries()
        
        LogInfo("Store \(self) created with identifier \(identifier) and path \(path)")
    }
    
    //! MARK: - Quering Info Key properties
    private func infoValue<T>(for key: String, value: InfoKey) -> T?
    {
        return fsQueue.sync { info[key]?[value.rawValue] as? T }
    }
    
    private func filePath(for key: String) -> String?
    {
        guard let filename: String = infoValue(for: key, value: .fileName)
            else { return nil }
        return (storeFolder as NSString).appendingPathComponent(filename)
    }
    
    //! MARK: - Remove
    private func cleanup()
    {
        LogInfo("Called to cleanup entries in \(self)")
        
        do
        {
            try fsQueue.sync(flags: .barrier)
            {
                try FileManager.default.removeItem(atPath: storeFolder)
                info = [:]
                try FileManager.default.createDirectory(atPath: storeFolder,
                    withIntermediateDirectories: false, attributes: nil)
            }
        }
        catch
        {
            LogError("Error during cleanup \(self) - \(error). Trying to " +
                "delete all records")
            cleanupAllEntries()
        }
    }
    
    private func cleanupAllEntries()
    {
        let keysToRemove = fsQueue.sync { info.keys }
        removeObjects(for: keysToRemove)
    }
    
    private func cleanupInvalidEntries()
    {
        let keysToRemove = fsQueue.sync { info.keys.filter
            { !self.isEntryValid(for: $0)} }
        removeObjects(for: keysToRemove)
    }
    
    private func removeObjects<S>(for keys: S) where S : Sequence,
        S.Iterator.Element == String
    {
        var cacheInfoChanged = false
        keys.forEach
        { key in
            guard let path = filePath(for: key) else { return }
            if FileManager.default.fileExists(atPath: path)
            {
                do
                {
                    try fsQueue.sync(flags: .barrier)
                    {
                        try FileManager.default.removeItem(atPath: path)
                        info[key] = nil
                        cacheInfoChanged = true
                    }
                }
                catch
                {
                    LogError("File with path \(path) can't be removed \(error)")
                }
            }
        }
        
        if cacheInfoChanged
        {
            try? synchronizeInfo()
        }
    }
    
    //! MARK: Validation
    private func isEntryValid(for key: String) -> Bool
    {
        let fileInfo = fsQueue.sync { info[key] ?? [:] }
        
        guard let timestamp = fileInfo[InfoKey.timeStamp.rawValue] as? Date
            else { return false }
        guard let timeInterval = fileInfo[InfoKey.timeInterval.rawValue]
            as? TimeInterval else { return true }
        
        let storageInterval = Date().timeIntervalSince(timestamp)
        return storageInterval > 0 && storageInterval < timeInterval
    }
    
    private func isEntryExists(for key: String) -> Bool
    {
        let fileInfo = fsQueue.sync { info[key] ?? [:] }
        
        guard let _ = fileInfo[InfoKey.timeStamp.rawValue] as? Date
            else { return false }
        guard let _ = fileInfo[InfoKey.fileName.rawValue] as? TimeInterval
            else { return false }
        
        return true
    }
    
    //! MARK: Store Info methods
    private func loadInfo() -> [String : [String : Any]]
    {
        var result: [String : [String : Any]] = [:]
        
        let infoFilePath = (storeFolder as NSString).appendingPathComponent(
            infoFileName)
        let infoFileUrl = URL(fileURLWithPath: infoFilePath)
        
        do
        {
            let data = try fsQueue.sync { try Data(contentsOf: infoFileUrl) }
            let dictionary = try PropertyListSerialization.propertyList(from:
                data, options: [], format: nil)
            result = dictionary as? [String : [String : Any]] ?? [:]
        }
        catch
        {
            LogError("Data store was unable to load info dictionary with \(error)")
        }
        
        return result
    }
    
    private func synchronizeInfo() throws
    {
        let infoFilePath = (storeFolder as NSString).appendingPathComponent(
            infoFileName)
        let infoFileUrl = URL(fileURLWithPath: infoFilePath)
        
        let data = try PropertyListSerialization.data(fromPropertyList: info,
            format: .binary, options: 0)
        try fsQueue.sync { try data.write(to: infoFileUrl, options: .atomic) }
    }
    
    //! MARK: - Utilities
    private static func storeFolder(with identifier: String, searchPathDirectory:
        FileManager.SearchPathDirectory, searchPathDomainMask:
        FileManager.SearchPathDomainMask) throws -> String
    {
        let paths = NSSearchPathForDirectoriesInDomains(searchPathDirectory,
            searchPathDomainMask, true)
        guard let path = paths.first else { throw DataStoreErrors
            .failedToLocateStoreFolder }
        
        let result = (path as NSString).appendingPathComponent(String(
            format: storeFolderNameFormat, identifier))
        
        guard !FileManager.default.fileExists(atPath: result) else
        {
            return result
        }
        
        try FileManager.default.createDirectory(atPath: result,
            withIntermediateDirectories: false, attributes: nil)
        return result
    }
}

////////////////////////////////////////////////////////////////////////////////
//! MARK: - As DataStore
extension FileSystemDataStore : DataStore
{
    func store<T>(object: T, for key: String) throws where T : Storable
    {
        try store(object: object, for: key, properties: StoreProperties())
    }
    
    func store<T>(object: T, for key: String, properties: StoreProperties) throws 
        where T : Storable
    {
        guard let data = object.data else { throw DataStoreErrors
            .noDataRepresentation(object: object) }
        
        let path: String
        if let value = filePath(for: key)
        {
            path = value
        }
        else
        {
            let fileName = UUID().uuidString
            let value = (storeFolder as NSString).appendingPathComponent(fileName)
            path = (value as NSString).appendingPathExtension(
                cacheFileExtension) ?? value
        }
        let url = URL(fileURLWithPath: path)
        try data.write(to: url, options: .atomic)
        
        var dict: [String : Any] = [
            InfoKey.fileName.rawValue : (path as NSString).lastPathComponent,
            InfoKey.timeStamp.rawValue : Date()]
        if let validTimeInterval = properties.validTimeInterval
        {
            dict[InfoKey.timeInterval.rawValue] = validTimeInterval
        }
        
        fsQueue.sync(flags: .barrier) { info[key] = dict }
        
        try synchronizeInfo()
        LogInfo("Item with identifier \(identifier) is added to cache \(self)")
    }
    
    func object<T>(for key: String) -> T? where T : Storable
    {
        guard containsObject(for: key) else { return nil }
        guard let path = filePath(for: key) else { return nil }
        let url = URL(fileURLWithPath: path)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return T(data: data)
    }
    
    func containsObject(for key: String) -> Bool
    {
        var result = false
        if isEntryValid(for: key), let path = filePath(for: key)
        {
            result = FileManager.default.fileExists(atPath: path)
        }
        else if isEntryExists(for: key)
        {
            removeObject(for: key)
        }
        return result
    }
    
    func removeObject(for key: String)
    {
        removeObjects(for: [key])
    }
    
    func clear()
    {
        cleanup()
    }
}
