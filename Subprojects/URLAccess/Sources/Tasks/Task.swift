////////////////////////////////////////////////////////////////////////////////
//
//  Task.swift
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
/// Represents URLSessionTask wrapper, contains response serializers, and
/// response validation rules
public class Task
{
    //! MARK: - Properties
    /// URL session instance that are responsible for urlSessionTask running
    public let urlSession: URLSession
    /// URL session data task
    public let urlSessionTask: URLSessionTask
    /// Instance conforming to URLSessionDelegate(s) that will receive messages
    ///     from urlSessionTask
    let sessionDelegate: TaskSessionDelegate
    
    /// HTTPURLResponse produced by urlSessionTask
    var response: HTTPURLResponse? { return urlSessionTask.response as?
        HTTPURLResponse}
    /// URLRequest that represents original request
    var request: URLRequest? { return urlSessionTask.originalRequest }
    /// Error produced by task or sessionDelegate
    var error: Error? { return sessionDelegate.error }
    /// Operation Queue, containing response serializers as a tasks.
    /// Initially suspended, will be started after SessionTask completes.
    private var operationQueue = Task.createOperationQueue()
    
    //! MARK: - Init & Deinit
    init(urlSession: URLSession, urlSessionTask: URLSessionTask)
    {
        self.urlSession = urlSession
        self.urlSessionTask = urlSessionTask
        self.sessionDelegate = TaskSessionDelegate(task: urlSessionTask)
        self.sessionDelegate.didCompleteTask = {[unowned self] in
            self.sessionDelegateDidCompleteTask() }
    }
    
    deinit
    {
        LogInfo("Task deinit \(self)")
    }
    
    //! MARK: - Start/Stop
    public func resume()
    {
        urlSessionTask.resume()
    }
    
    public func suspend()
    {
        urlSessionTask.suspend()
    }
        
    public func cancel()
    {
        urlSessionTask.cancel()
    }
    
    //! MARK: - Validation
    @discardableResult
    func addValidation(with validation: @escaping () throws -> Void) -> Self
    {
        sessionDelegate.addValidation(validation)
        return self
    }
    
    //! MARK: - Response
    @discardableResult
    func addResponse(with operation: Operation) -> Self
    {
        operationQueue.addOperation(operation)
        return self
    }
    
    //! MARK: - SessionDelegate callbacks
    private func sessionDelegateDidCompleteTask()
    {
        LogInfo("Session delegate \(sessionDelegate) did complete task")
        operationQueue.isSuspended = false
        LogInfo("Operation queue \(operationQueue) is resumed")
    }
    
    //! MARK: - Private
    private static func createOperationQueue() -> OperationQueue
    {
        let result = OperationQueue()
        result.isSuspended = true
        result.maxConcurrentOperationCount = 1
        return result
    }
}

////////////////////////////////////////////////////////////////////////////////
//! MARK: - As Equatable
extension Task : Equatable
{
    public static func ==(lhs: Task, rhs: Task) -> Bool
    {
        return lhs.urlSessionTask == rhs.urlSessionTask
    }
}
