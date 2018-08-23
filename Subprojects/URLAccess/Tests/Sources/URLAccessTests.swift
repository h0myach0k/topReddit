////////////////////////////////////////////////////////////////////////////////
//
//  URLAccessTests.swift
//  URLAccessTests
//
//  Created by Iurii Khomiak on 8/22/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import XCTest
@testable import URLAccess

////////////////////////////////////////////////////////////////////////////////
class URLAccessTests: XCTestCase
{
    func testURLAccessCreation()
    {
        let sharedURLAccess = URLAccess.shared
        let customURLAccess = URLAccess(configuration: .default)
        
        XCTAssertTrue(sharedURLAccess !== customURLAccess,
            "URLAccess instances should be different objects")
    }
    
    func testPerformRequest()
    {
        let task = URLAccess.shared.peform(request: testJSUrlRequest())
        XCTAssertTrue(URLAccess.shared.contains(task: task),
            "URL Access doesnt register task")
        
        _ = self.expectation(for: NSPredicate(block:
        { object, _ -> Bool in
            !URLAccess.shared.contains(task: task)
        }), evaluatedWith: task, handler: nil)
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testPerformRequestAndValidation()
    {
        let task = URLAccess.shared.peform(request: testJSUrlRequest())
            .validate(allowedStatusCodes: 0..<1)
        XCTAssertTrue(URLAccess.shared.contains(task: task),
            "URL Access doesnt register task")
        
        _ = self.expectation(for: NSPredicate(block:
        { object, _ -> Bool in
            !URLAccess.shared.contains(task: task)
        }), evaluatedWith: task, handler: nil)
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testPerformRequestValidationResponse()
    {
        let expectation = self.expectation(description: "URL Access")
        
        let task = URLAccess.shared.peform(request: testJSUrlRequest())
            .validate(allowedStatusCodes: 0..<1)
            .response
            { r in
                expectation.fulfill()
            }
        XCTAssertTrue(URLAccess.shared.contains(task: task),
            "URL Access doesnt register task")
        waitForExpectations(timeout: 1.0)
        XCTAssertFalse(URLAccess.shared.contains(task: task))
    }
    
    func testCancellation()
    {
        let task = URLAccess.shared.peform(request: testJSUrlRequest())
            .response
            { r in
                XCTAssertEqual((r.error as? URLError)?.code, URLError.cancelled)
            }
        XCTAssertTrue(URLAccess.shared.contains(task: task),
            "URL Access doesnt register task")
        task.cancel()
        
        _ = self.expectation(for: NSPredicate(block:
        { [task] object, _ -> Bool in
            !URLAccess.shared.contains(task: task)
        }), evaluatedWith: task, handler: nil)
        
        waitForExpectations(timeout: 1)
    }
    
    func testJSON()
    {
        let data = try! Data(contentsOf: testJSUrl())
        let decoder = JSONDecoder()
        let testResponse = try! decoder.decode(TestResponse.self, from: data)
        
        let expectation = self.expectation(description: "URL Access")
        _ = URLAccess.shared.peform(request: testJSUrlRequest())
            .responseDecodable
            { (response: DataResponse<TestResponse>) in
                XCTAssertNotNil(response.request)
                XCTAssertNil(response.error)
                XCTAssertNotNil(response.value)
                XCTAssertEqual(response.value, testResponse)
                expectation.fulfill()
            }
        
        waitForExpectations(timeout: 1)
    }
    
    //! MARK: - Private
    private func testJSUrl() -> URL
    {
        let url = Bundle(for: URLAccessTests.self).url(forResource: "test",
            withExtension: "js")!
        return url
    }
    
    private func testJSUrlRequest() -> URLRequest
    {
        return URLRequest(url: testJSUrl())
    }
}
