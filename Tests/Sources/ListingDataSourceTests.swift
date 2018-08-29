////////////////////////////////////////////////////////////////////////////////
//
//  ListingDataSourceTests.swift
//  TopRedditTests
//
//  Created by Iurii Khomiak on 8/25/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import XCTest
@testable import TopReddit
import RedditAccess
import URLAccess
import Core

////////////////////////////////////////////////////////////////////////////////
class ListingDataSourceTests: XCTestCase
{
    var container: DependencyContainer!
    let responseManager = StubRedditResponseManager(baseUrl: URL(
        fileURLWithPath: NSTemporaryDirectory()))
    
    override func setUp()
    {
        super.setUp()
        container = DependencyContainer()
        container.register(RedditAccess.self, in: .singleton)
        { [unowned self] _ in
            RedditAccessFactory().createRedditAccess(urlAccess:
                .shared, parameters: RedditAccessParameters(baseUrl:
                self.responseManager.baseUrl))
        }
    }
    
    func testDataSource()
    {
        let query = ListingQuery(listing: .top(.all), count: 2)
        let dataSource = ListingDataSource.init(query: query, container:
            container)
        
        let testData1 = data(testFileName: "top_1")
        let expectedData1 = titles(testFileName: "top_1")
        let testData2 = data(testFileName: "top_2")
        let expectedData2 = titles(testFileName: "top_2")
        let testData3 = data(testFileName: "top_3")
        let expectedData3 = titles(testFileName: "top_3")
        
        XCTAssertFalse(dataSource.metadata.contains(.hasNext))
        XCTAssertFalse(dataSource.metadata.contains(.hasPrevious))
        
        //! Load Page 1
        let loadExpectationPage1 = self.expectation(description: "Page1")
        
        var expectedTitles = titles(testFileName: "top_1")
        responseManager.registerResponse(data: testData1, for: query)
        
        dataSource.loadData(options: .initialLoad)
        { changeRequest, error in
            defer { loadExpectationPage1.fulfill() }
            XCTAssertNil(error)
            XCTAssertNotNil(changeRequest)
            guard let changeRequest = changeRequest else { return }
            XCTAssertEqual(changeRequest.deletedIndexes.count, 0)
            XCTAssertEqual(changeRequest.updatedIndexes.count, 0)
            XCTAssertEqual(changeRequest.insertedIndexes.count, 2)
            
            let titles = changeRequest.value?.map {$0.title} ?? []
            XCTAssertEqual(expectedTitles, titles)
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(dataSource.metadata.contains(.hasNext))
        XCTAssertFalse(dataSource.metadata.contains(.hasPrevious))
        
        //! Load Page 2
        let loadExpectationPage2 = self.expectation(description: "Page2")
        
        expectedTitles += titles(testFileName: "top_2")
        responseManager.registerResponse(data: testData2, for: query)
        
        dataSource.loadData(options: .loadNext)
        { changeRequest, error in
            defer { loadExpectationPage2.fulfill() }
            XCTAssertNil(error)
            XCTAssertNotNil(changeRequest)
            guard let changeRequest = changeRequest else { return }
            XCTAssertEqual(changeRequest.deletedIndexes.count, 0)
            XCTAssertEqual(changeRequest.updatedIndexes.count, 0)
            XCTAssertEqual(changeRequest.insertedIndexes.count, 2)
            
            let titles = changeRequest.value?.map {$0.title} ?? []
            XCTAssertEqual(expectedTitles, titles)
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(dataSource.metadata.contains(.hasNext))
        XCTAssertFalse(dataSource.metadata.contains(.hasPrevious))
        
        //! Load Page 3
        let loadExpectationPage3 = self.expectation(description: "Page3")
        
        expectedTitles += titles(testFileName: "top_3")
        responseManager.registerResponse(data: testData3, for: query)
        
        dataSource.loadData(options: .loadNext)
        { changeRequest, error in
            defer { loadExpectationPage3.fulfill() }
            XCTAssertNil(error)
            XCTAssertNotNil(changeRequest)
            guard let changeRequest = changeRequest else { return }
            XCTAssertEqual(changeRequest.deletedIndexes.count, 0)
            XCTAssertEqual(changeRequest.updatedIndexes.count, 0)
            XCTAssertEqual(changeRequest.insertedIndexes.count, 2)
            
            let titles = changeRequest.value?.map {$0.title} ?? []
            XCTAssertEqual(expectedTitles, titles)
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertFalse(dataSource.metadata.contains(.hasNext))
        XCTAssertFalse(dataSource.metadata.contains(.hasPrevious))
    }
    
    //! MARK: - Private
    private func data(testFileName: String) -> Data
    {
        let url = Bundle(for: type(of: self)).url(forResource:
            testFileName, withExtension: "json")!
        return try! Data(contentsOf: url)
    }
    
    private func titles(testFileName: String) -> [String]
    {
        let url = Bundle(for: type(of: self)).url(forResource:
            testFileName, withExtension: "plist")!
        let data = try! Data(contentsOf: url)
        return try! PropertyListSerialization.propertyList(from: data,
            options: [], format: nil) as! [String]
    }
}
