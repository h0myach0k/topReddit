////////////////////////////////////////////////////////////////////////////////
//
//  TestLogger.swift
//  CoreTests
//
//  Created by Iurii Khomiak on 8/24/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation
@testable import Core

////////////////////////////////////////////////////////////////////////////////
class TestLogger : Logger
{
    //! MARK: - Forward Declarations
    typealias Handler = (LogLevel, String) -> Void
    
    //! MARK: - Properties
    let handler: Handler
    var logLevel: LogLevel = .none
    
    //! MARK: - Init & Deinit
    init(handler: @escaping Handler)
    {
        self.handler = handler
    }
    
    //! MARK: - As Logger
    func log(_ level: LogLevel, _ text: @autoclosure () -> String)
    {
        handler(level, text())
    }
}
