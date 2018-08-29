////////////////////////////////////////////////////////////////////////////////
//
//  DataSourceTests.swift
//  Core
//
//  Created by Iurii Khomiak on 8/25/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation
import XCTest
@testable import Core

////////////////////////////////////////////////////////////////////////////////
fileprivate enum StubError : Error
{
    case error
}

////////////////////////////////////////////////////////////////////////////////
class DataSourceTests : XCTestCase
{
    func testCreation()
    {
        let dataSource = StubDataSource(simulatedResult: .value("Test"))
        
        XCTAssertNil(dataSource.value, "Value is available")
        XCTAssertNil(dataSource.lastError, "Last Error is available")
        XCTAssertNil(dataSource.lastUpdateDate, "Last Update date is available")
        XCTAssertTrue(dataSource.metadata == [], "Metadata is available")
        XCTAssertTrue(dataSource.isEmpty, "Data source is not empty")
    }
    
    func testCodingDecoding()
    {
        let loadExpectation = self.expectation(description: "DidFinishLoad")
        let dataSource = StubDataSource(simulatedResult: .value("Test"))
        dataSource.loadData(options: .initialLoad)
        { _, _ in
            loadExpectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        do
        {
            let data = try encoder.encode(dataSource)
            XCTAssertFalse(data.isEmpty)
            let copiedDataSource = try decoder.decode(StubDataSource<String>.self,
                from: data)
            XCTAssertEqual(copiedDataSource.value, "Test")
            XCTAssertNotNil(copiedDataSource.lastUpdateDate)
        }
        catch
        {
            XCTAssert(false, "\(error)")
        }
    }
    
    func testSuccessInitialLoad()
    {
        let didFinishExpectation = self.expectation(description: "DidFinishLoad")
        let didStartExpectation = self.expectation(description: "DidStartLoad")
        let didUpdateExpectation = self.expectation(description: "DidUpdateLoad")
        
        let dataSource = StubDataSource(simulatedResult: .value("Hello"))
        
        let delegate = StubDataSourceDelegate<String>()
        dataSource.delegate = delegate
        delegate.didStart = { didStartExpectation.fulfill() }
        delegate.didFinish = { didFinishExpectation.fulfill() }
        delegate.didUpdate = { [unowned self] in self.check(changeRequest: $0,
            dataSource: dataSource); didUpdateExpectation.fulfill() }
        
        dataSource.loadData(options: .initialLoad)
        { [unowned self] changeRequest, error in
            XCTAssertNotNil(changeRequest)
            changeRequest.map { self.check(changeRequest: $0, dataSource: dataSource) }
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testFailure()
    {
        let didFinishExpectation = self.expectation(description: "DidFinishLoad")
        let didStartExpectation = self.expectation(description: "DidStartLoad")
        
        let dataSource: StubDataSource<String> = StubDataSource(simulatedResult:
            .error(StubError.error))
        
        let delegate = StubDataSourceDelegate<String>()
        dataSource.delegate = delegate
        delegate.didStart = { didStartExpectation.fulfill() }
        delegate.didFinish = { didFinishExpectation.fulfill() }
        
        dataSource.loadData(options: .initialLoad)
        {changeRequest, error in
            XCTAssertNil(changeRequest)
            XCTAssertNotNil(error)
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testPagingDataSource()
    {
        let testData = ["Obj1", "Obj2", "Obj3"]
        let testIndex = 1
        let dataSource = StubPagingDataSource(simulatedResult: testData,
            currentIndex: testIndex)
        
        var expectedData = [["Obj2"], ["Obj2", "Obj3"], ["Obj1", "Obj2", "Obj3"]]
        
        let step1Expectation = self.expectation(description: "Step1")
        dataSource.loadData(options: .initialLoad)
        { changeRequest, error in
            let expectedResult = expectedData.removeFirst()
            self.check(changeRequest: changeRequest, dataSource: dataSource,
                expectedResult: expectedResult)
            step1Expectation.fulfill()
        }
        wait(for: [step1Expectation], timeout: 1)
        XCTAssertTrue(dataSource.metadata.contains(.hasNext))
        XCTAssertTrue(dataSource.metadata.contains(.hasPrevious))
        
        let step2Expectation = self.expectation(description: "Step2")
        dataSource.loadData(options: .loadNext)
        { changeRequest, error in
            let expectedResult = expectedData.removeFirst()
            self.check(changeRequest: changeRequest, dataSource: dataSource,
                expectedResult: expectedResult)
            step2Expectation.fulfill()
        }
        wait(for: [step2Expectation], timeout: 1)
        XCTAssertFalse(dataSource.metadata.contains(.hasNext))
        XCTAssertTrue(dataSource.metadata.contains(.hasPrevious))
        
        let step3Expectation = self.expectation(description: "Step3")
        dataSource.loadData(options: .loadPrevious)
        { changeRequest, error in
            let expectedResult = expectedData.removeFirst()
            self.check(changeRequest: changeRequest, dataSource: dataSource,
                expectedResult: expectedResult)
            step3Expectation.fulfill()
        }
        wait(for: [step3Expectation], timeout: 1)
        XCTAssertFalse(dataSource.metadata.contains(.hasNext))
        XCTAssertFalse(dataSource.metadata.contains(.hasPrevious))
    }
    
    //! MARK: - Utilities
    private func check<T>(changeRequest: DataSourceChangeRequest<String>,
        dataSource: T) where T : DataSourceProtocol, T.Value == String
    {
        let contentValue = changeRequest.value
        let dataSourceValue = dataSource.value
        XCTAssertNotNil(contentValue, "Content value is nil")
        XCTAssertNotNil(dataSourceValue, "DataSource value is nil")
        XCTAssertEqual(dataSourceValue, contentValue, "Different values")
        
        XCTAssertNil(dataSource.lastError)
        XCTAssertNotNil(dataSource.lastUpdateDate)
        XCTAssertFalse(dataSource.isEmpty)
    }
    
    private func check(changeRequest: DataSourceChangeRequest<[String]>?,
        dataSource: StubPagingDataSource, expectedResult: [String])
    {
        guard let changeRequest = changeRequest else
        {
            XCTAssertFalse(true, "Change request is nil")
            return
        }
        
        let contentValue = changeRequest.value
        let dataSourceValue = dataSource.value
        XCTAssertNotNil(contentValue, "Content value is nil")
        XCTAssertNotNil(dataSourceValue, "DataSource value is nil")
        XCTAssertEqual(dataSourceValue, contentValue, "Different values")
        
        XCTAssertNil(dataSource.lastError)
        XCTAssertNotNil(dataSource.lastUpdateDate)
        XCTAssertFalse(dataSource.isEmpty)
        
        XCTAssertEqual(expectedResult, contentValue)
    }
}
