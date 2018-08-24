////////////////////////////////////////////////////////////////////////////////
//
//  DataStoreTests.swift
//  DataStoreTests
//
//  Created by Iurii Khomiak on 8/24/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import XCTest
@testable import DataStore

////////////////////////////////////////////////////////////////////////////////
fileprivate let testStoreIdentifier = "test"
fileprivate let testKey = "testKey"

////////////////////////////////////////////////////////////////////////////////
class DataStoreTests: XCTestCase
{
    func testDataStoreCreation()
    {
        do
        {
            _ = try DataStoreFactory().createDataStore(identifier:
                testStoreIdentifier, type: .fileSystem(directory: .cachesDirectory,
                domainMask: .userDomainMask))
        }
        catch
        {
            XCTAssert(false, "Data Store can't be created")
        }
    }
    
    func testDataStoreDataValues()
    {
        guard let dataStore = getDataStore() else { XCTAssert(false,
            "Data Store can't be created"); return }
        dataStore.clear()
        
        let testObject = "Test".data(using: .utf8)!
        XCTAssertFalse(dataStore.containsObject(for: testKey),
            "Data store shouldn't contain testKey object")
        XCTAssertEqual(dataStore.identifier, testStoreIdentifier,
            "Data Store identifier differs")
        
        do
        {
            try dataStore.store(object: testObject, for: testKey)
        }
        catch
        {
            XCTAssert(false, "Data Store save failed \(error)")
            return
        }
        
        XCTAssertTrue(dataStore.containsObject(for: testKey),
            "Data store should contain testKey object")
        guard let objectFromDataStore: Data = dataStore.object(for: testKey)
            else
            {
                XCTAssert(false, "Data Store should return object")
                return
            }
        XCTAssertEqual(objectFromDataStore, testObject, "Objects should be the same")
        
        dataStore.removeObject(for: testKey)
        XCTAssertFalse(dataStore.containsObject(for: testKey),
            "Data store should contain testKey object")
    }
    
    func testDataStoreDataOverride()
    {
        guard let dataStore = getDataStore() else { XCTAssert(false,
            "Data Store can't be created"); return }
        dataStore.clear()
        
        let testObject1 = "Test".data(using: .utf8)!
        let testObject2 = "TestData".data(using: .utf8)!
        XCTAssertFalse(dataStore.containsObject(for: testKey),
            "Data store shouldn't contain testKey object")
        XCTAssertEqual(dataStore.identifier, testStoreIdentifier,
            "Data Store identifier differs")
        
        do
        {
            try dataStore.store(object: testObject1, for: testKey)
            try dataStore.store(object: testObject2, for: testKey)
        }
        catch
        {
            XCTAssert(false, "Data Store save failed \(error)")
            return
        }
        
        XCTAssertTrue(dataStore.containsObject(for: testKey),
            "Data store should contain testKey object")
        guard let objectFromDataStore: Data = dataStore.object(for: testKey)
            else
            {
                XCTAssert(false, "Data Store should return object")
                return
            }
        XCTAssertEqual(objectFromDataStore, testObject2, "Objects should be the same")
        
        dataStore.removeObject(for: testKey)
        XCTAssertFalse(dataStore.containsObject(for: testKey),
            "Data store should contain testKey object")
    }
    
    //! MARK: - Private
    private func getDataStore() -> DataStore?
    {
        return try? DataStoreFactory().createDataStore(identifier:
            testStoreIdentifier, type: .fileSystem(directory: .cachesDirectory,
            domainMask: .userDomainMask))
    }
}
