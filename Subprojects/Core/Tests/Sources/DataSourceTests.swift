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
}
