////////////////////////////////////////////////////////////////////////////////
//
//  TaskSessionDelegate.swift
//  URLAccess
//
//  Created by Iurii Khomiak on 8/22/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
/// URLSessionDelegate(s) for one linked URLSessionTask.
/// This class is also responsible for validation processing
class TaskSessionDelegate : NSObject
{
    //! MARK: - Forward Declarations
    typealias DidCompleteHandler = () -> Void
    
    //! MARK: - Properties
    /// URLSessionTask that delegate messages will be processed
    let task: URLSessionTask
    /// Did complete callback, will be called after task is complete
    var didCompleteTask: DidCompleteHandler?
    
    /// Contains data collected by URLSessionDataTask
    fileprivate(set) var data: Data?
    /// Contains error collected by URLSessionTask
    fileprivate(set) var error: Error?
    /// Locking
    fileprivate let lock = NSRecursiveLock()
    /// Validations
    fileprivate var validations: [() throws -> Void] = []
    /// Returns HTTPURLResponse if possible
    fileprivate var response: HTTPURLResponse?
    {
        return task.response as? HTTPURLResponse
    }
    
    //! MARK: - Init & Deinit
    init(task: URLSessionTask)
    {
        self.task = task
        super.init()
    }
    
    deinit
    {
        print("Task session delegate deinit")
    }
    
    //! MARK: - Validation
    /// Registers new validation
    func addValidation(_ validation: @escaping () throws -> Void)
    {
        lock.lock()
        defer { lock.unlock() }
        validations.append(validation)
    }
    
    /// Performs validation and throw error if validation fails
    fileprivate func validate() throws
    {
        lock.lock()
        let validations = self.validations
        lock.unlock()
        
        for validation in validations
        {
            try validation()
        }
    }
}

////////////////////////////////////////////////////////////////////////////////
//! MARK: - As URLSessionDataDelegate
extension TaskSessionDelegate : URLSessionDataDelegate
{
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask,
        didReceive data: Data)
    {
        lock.lock()
        defer { lock.unlock() }
        if nil == self.data
        {
            self.data = Data()
        }
        self.data?.append(data)
    }
}

////////////////////////////////////////////////////////////////////////////////
//! MARK: - As URLSessionTaskDelegate
extension TaskSessionDelegate : URLSessionTaskDelegate
{
    func urlSession(_ session: URLSession, task: URLSessionTask,
        didCompleteWithError error: Error?)
    {
        lock.lock()
        defer { lock.unlock() }
        
        self.error = error
        if nil == self.error
        {
            do
            {
                try validate()
            }
            catch
            {
                self.error = error
            }
        }
        
        didCompleteTask?()
    }
}
