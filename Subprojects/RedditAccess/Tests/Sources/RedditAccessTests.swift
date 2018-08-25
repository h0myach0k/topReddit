////////////////////////////////////////////////////////////////////////////////
//
//  RedditAccessTests.swift
//  RedditAccessTests
//
//  Created by Iurii Khomiak on 8/25/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import XCTest
@testable import RedditAccess
import URLAccess

////////////////////////////////////////////////////////////////////////////////
class RedditAccessTests: XCTestCase
{
    var redditAccess: RedditAccess!
    let responseManager = StubRedditResponseManager(baseUrl: URL(
        fileURLWithPath: NSTemporaryDirectory()))
    
    override func setUp()
    {
        super.setUp()
        redditAccess = RedditAccessFactory().createRedditAccess(urlAccess:
            .shared, parameters: RedditAccessParameters(baseUrl:
            responseManager.baseUrl))
    }
    
    func testLoadData()
    {
        let query1 = ListingQuery(listing: .top(.all), count: 10)
        let testData1 = data(testFileName: "top_1")
        let expectedData1 = titles(testFileName: "top_1")
        let testData2 = data(testFileName: "top_2")
        let expectedData2 = titles(testFileName: "top_2")
        var query2: ListingQuery?
        
        responseManager.registerResponse(data: testData1, for: query1)
        let expectation1 = self.expectation(description: "Run Expectation")
        redditAccess.run(query: query1, completionQueue: .main)
        { result in
            defer { expectation1.fulfill() }
            XCTAssertNil(result.error)
            XCTAssertNotNil(result.value)
            guard let value = result.value else { return }
            XCTAssertEqual(value.items.map {$0.title}, expectedData1)
            query2 = value.query(for: .next)
            XCTAssertNotNil(query2)
        }
        wait(for: [expectation1], timeout: 5)
        
        guard nil != query2 else { return }
        let expectation2 = self.expectation(description: "Run Expectation 2")
        responseManager.registerResponse(data: testData2, for: query2!)
        redditAccess.run(query: query2!, completionQueue: .main)
        { result in
            defer { expectation2.fulfill() }
            XCTAssertNil(result.error)
            XCTAssertNotNil(result.value)
            guard let value = result.value else { return }
            XCTAssertEqual(value.items.map {$0.title}, expectedData2)
            XCTAssertNotNil(value.query(for: .next))
        }
        wait(for: [expectation2], timeout: 5)
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
