////////////////////////////////////////////////////////////////////////////////
//
//  Log.swift
//  Core
//
//  Created by Iurii Khomiak on 8/24/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

/// Logs message with registered loggers with given log level
///
/// - Parameters:
///   - level: Message log level
///   - text: Text to log
public func Log(_ level: LogLevel, _ text: @autoclosure () -> String)
{
    LoggerManager.shared.log(level, text)
}

/// Logs message with info log level with registered loggers
///
/// - Parameter text: Text to log
public func LogInfo(_ text: @autoclosure () -> String)
{
    Log(.info, text)
}

/// Logs message with warning log level with registered loggers
///
/// - Parameter text: Text to log
public func LogWarn(_ text: @autoclosure () -> String)
{
    Log(.warning, text)
}

/// Logs message with error log level with registered loggers
///
/// - Parameter text: Text to log
public func LogError(_ text: @autoclosure () -> String)
{
    Log(.error, text)
}
