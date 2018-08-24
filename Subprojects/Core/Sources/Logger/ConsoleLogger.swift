////////////////////////////////////////////////////////////////////////////////
//
//  ConsoleLogger.swift
//  Core
//
//  Created by Iurii Khomiak on 8/24/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
class ConsoleLogger : Logger
{
    func log(_ level: LogLevel, _ text: @autoclosure () -> String)
    {        
        let string: String
        let prefix: String
        switch level
        {
            case .info:
                prefix = ""
                string = "I"
            case .warning:
                string = "W"
                prefix = "☣️ "
            case .error:
                prefix = "🔴 "
                string = "E"
            default:
                prefix = ""
                string = ""
        }
        
        print("\(prefix) *** [\(string)]> " + text())
    }
}
