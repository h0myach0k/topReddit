////////////////////////////////////////////////////////////////////////////////
//
//  URLAccess.swift
//  URLAccess
//
//  Created by Iurii Khomiak on 8/22/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation
import Core

////////////////////////////////////////////////////////////////////////////////
/// Responsible for request creation and managing of its URLSession instance.
/// Please note, that current implementation supports only minimum functionality
///  with DataRequests.
public final class URLAccess
{    
    //! MARK: - Static properties
    /// Provides access to shared URLAccess instance
    public static let shared = URLAccess(configuration: .default)
    
    //! MARK: - Properties
    /// Returns URLSession assotiated with URLAccess
    public let session: URLSession
    /// Returns session delegate assotiated with URLAccess
    public let sessionDelegate: SessionDelegate
    /// Property containing collection of tasks that are assotiated with URLAccess
    private var tasks: [Task] = []
    /// Property containing modification lock for tasks
    private let tasksLock = NSRecursiveLock()
    
    //! MARK: - Init & Deinit
    /// Initializes new instance of URLAccess
    ///
    /// - Parameters:
    ///   - configuration: URLSession configuration
    ///   - delegate: Session Delegate
    public init(configuration: URLSessionConfiguration, delegate:
        SessionDelegate = SessionDelegate())
    {
        self.session = URLSession(configuration: configuration, delegate:
            delegate, delegateQueue: nil)
        self.sessionDelegate = delegate
    }
    
    deinit
    {
        cancelAllTasks()
        session.invalidateAndCancel()
    }
    
    //! MARK: - Public methods
    /// Creates and schedule new data task for execution
    ///
    /// - Parameter request: configured URLRequest
    /// - Returns: newly created DataTask instance
    @discardableResult
    public func peform(request: URLRequest) -> DataTask
    {
        LogInfo("Prepare to perform request \(request) in \(self)")
        
        //! Obtain data task
        let urlSessionDataTask = session.dataTask(with: request)
        let result = DataTask(urlSession: session, urlSessionDataTask:
            urlSessionDataTask)
        
        //! Future request unregistration
        result.response
        { [weak self, weak result] _ in
            guard let `self` = self else { return }
            guard let result = result else { return }
            self.unregisterTask(result)
        }
        
        //! Registration
        registerTask(result)
        
        //! Schedule
        result.resume() 
        
        return result
    }
    
    /// Checks if given task is assotiated with URLAccess
    ///
    /// - Parameter task: Task to check assotiativity
    /// - Returns: true if URLAccess contains task, false otherwise
    public func contains(task: Task) -> Bool
    {
        tasksLock.lock()
        defer { tasksLock.unlock() }
        return tasks.contains(task)
    }
        
    /// Cancels given task
    ///
    /// - Parameter task: Task to cancel
    public func cancel(task: Task)
    {
        task.cancel()
    }
    
    /// Cancels all tasks
    public func cancelAllTasks()
    {
        tasks.forEach { $0.cancel() }
    }
    
    //! MARK: - Private
    private func registerTask(_ task: Task)
    {
        LogInfo("Registers task \(task) in \(self)")
        
        tasksLock.lock()
        defer { tasksLock.unlock() }
        tasks.append(task)
        sessionDelegate.register(task: task)
    }
    
    private func unregisterTask(_ task: Task)
    {
        LogInfo("Unregisters task \(task) in \(self)")
        
        tasksLock.lock()
        defer { tasksLock.unlock() }
        if let index = tasks.index(of: task)
        {
            tasks.remove(at: index)
        }
        sessionDelegate.unregister(task: task)
    }
}
