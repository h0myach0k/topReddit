////////////////////////////////////////////////////////////////////////////////
//
//  SessionDelegate.swift
//  URLAccess
//
//  Created by Iurii Khomiak on 8/22/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
/// URLAccess Session Delegate instance that adopts URLSessionDelegates, and
/// forwards its methods directly to task delegate
open class SessionDelegate : NSObject
{
    //! MARK: - Properties
    private let lock = NSRecursiveLock()
    private var tasks: [URLSessionTask : Task] = [:]
    
    //! MARK: - Task Management
    func contains(task: Task) -> Bool
    {
        lock.lock()
        defer { lock.unlock() }
        return nil != tasks[task.urlSessionTask]
    }
    
    func register(task: Task)
    {
        print("Registering task \(task) in \(self)")
        
        lock.lock()
        defer { lock.unlock() }
        tasks[task.urlSessionTask] = task
    }
    
    func unregister(task: Task)
    {
        print("Unregistering task \(task) in \(self)")
        
        lock.lock()
        defer { lock.unlock() }
        tasks[task.urlSessionTask] = nil
    }
    
    //! MARK: - Utilities
    fileprivate func task(for urlSessionTask: URLSessionTask) -> Task?
    {
        lock.lock()
        defer { lock.unlock() }
        return tasks[urlSessionTask]
    }
}

////////////////////////////////////////////////////////////////////////////////
//! MARK: - As
extension SessionDelegate : URLSessionDelegate
{
    public func urlSession(_ session: URLSession, task: URLSessionTask,
        didCompleteWithError error: Error?)
    {
        guard let accessTask = self.task(for: task) else
        {
            print("Delegate received message from non registered task")
            return
        }
        accessTask.sessionDelegate.urlSession(session, task: task,
            didCompleteWithError: error)
        unregister(task: accessTask)
    }
}

////////////////////////////////////////////////////////////////////////////////
//! MARK: - URLSessionDataDelegate
extension SessionDelegate : URLSessionDataDelegate
{
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask,
        didReceive data: Data)
    {
        guard let task = self.task(for: dataTask) else
        {
            print("Delegate received message from non registered task")
            return
        }
        
        task.sessionDelegate.urlSession(session, dataTask: dataTask, didReceive:
            data)
    }
}

