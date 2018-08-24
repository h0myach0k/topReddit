////////////////////////////////////////////////////////////////////////////////
//
//  CoreTests.swift
//  CoreTests
//
//  Created by Iurii Khomiak on 8/24/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import XCTest
@testable import Core

////////////////////////////////////////////////////////////////////////////////
fileprivate let defaultTimeout: TimeInterval = 3

////////////////////////////////////////////////////////////////////////////////
fileprivate extension Notification.Name
{
    static var expectationNotification = Notification.Name("ExpectationNotification")
}

////////////////////////////////////////////////////////////////////////////////
class LoggerTests: XCTestCase
{
    func testLogger()
    {
        let loggerManager = LoggerManager.shared
        loggerManager.logLevel = .info
        let logExpectation = self.expectation(description: "Log Expectation")
        let logger = TestLogger { _, _ in logExpectation.fulfill() }
        loggerManager.add(logger: logger)
        
        Log(.info, "Text")
        waitForExpectations(timeout: defaultTimeout)
    }
    
    func testNoLogInfo()
    {
        let loggerManager = LoggerManager()
        loggerManager.logLevel = .none
        testLogToBeInvoked(in: loggerManager, false, .info)
    }
    
    func testNoLogWarning()
    {
        let loggerManager = LoggerManager()
        loggerManager.logLevel = .none
        testLogToBeInvoked(in: loggerManager, false, .warning)
    }
    
    func testNoLogError()
    {
        let loggerManager = LoggerManager()
        loggerManager.logLevel = .none
        testLogToBeInvoked(in: loggerManager, false, .error)
    }
    
    func testLogInfo()
    {
        let loggerManager = LoggerManager()
        loggerManager.logLevel = .info
        testLogToBeInvoked(in: loggerManager, true, .info)
    }
    
    func testLogWarning()
    {
        let loggerManager = LoggerManager()
        loggerManager.logLevel = .info
        testLogToBeInvoked(in: loggerManager, true, .warning)
    }
    
    func testLogError()
    {
        let loggerManager = LoggerManager()
        loggerManager.logLevel = .error
        testLogToBeInvoked(in: loggerManager, true, .error)
    }
    
    //! MARK: - Helpers
    func testLogToBeInvoked(in loggerManager: LoggerManager, _ value: Bool,
        _ logLevel: LogLevel)
    {
        _ = self.expectation(forNotification:
            .expectationNotification, object: nil, handler: nil)
        
        var logInvoked = false
        let logger = TestLogger
        { [weak self] _, _ in
            logInvoked = true
            self?.postNotification()
        }
        loggerManager.add(logger: logger)
        DispatchQueue.main.asyncAfter(deadline: .now() +
            .milliseconds(500), execute: postNotification)
        loggerManager.log(logLevel, "Test")
        
        waitForExpectations(timeout: defaultTimeout)
        XCTAssertEqual(logInvoked, value)
    }
    
    private func postNotification()
    {
        NotificationCenter.default.post(name: .expectationNotification,
            object: nil)
    }
}
