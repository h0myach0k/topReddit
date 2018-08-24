////////////////////////////////////////////////////////////////////////////////
//
//  LoggerManager.swift
//  Core
//
//  Created by Iurii Khomiak on 8/24/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
public final class LoggerManager
{
    /// Returns shared instance
    public static let shared = LoggerManager.createSharedManager()
    /// Log level assotiated with registered loggers
    public var logLevel: LogLevel = .none    
    
    /// Contains list of registered loggers
    private var loggers: [Logger] = []
    private var lock = NSRecursiveLock()
    
    /// Registers new logger
    public func add(logger: Logger)
    {
        lock.lock()
        defer { lock.unlock() }
        loggers.append(logger)
    }
    
    /// Unregisters logger
    public func remove(logger: Logger)
    {
        lock.lock()
        defer { lock.unlock() }
        
        if let index = loggers.index(where: {$0 === logger})
        {
            loggers.remove(at: index)
        }
    }
    
    //! MARK: - Private
    private func getLoggers() -> [Logger]
    {
        lock.lock()
        defer { lock.unlock() }
        return loggers
    }
    
    static private func createSharedManager() -> LoggerManager
    {
        let result = LoggerManager()
        result.add(logger: ConsoleLogger())
        return result
    }
}

////////////////////////////////////////////////////////////////////////////////
//! MARK: - As Logger
extension LoggerManager : Logger
{
    public func log(_ level: LogLevel, _ text: @autoclosure () -> String)
    {
        guard logLevel.rawValue >= level.rawValue else { return }
        getLoggers().forEach
        { logger in
            logger.log(level, text)
        }
    }
}
