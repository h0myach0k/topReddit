////////////////////////////////////////////////////////////////////////////////
//
//  DataTask.swift
//  URLAccess
//
//  Created by Iurii Khomiak on 8/22/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
/// Represents URLSessionDataTask wrapper, contains sets of methods to add
///     validation, response serializers for URLSessionDataTask
public class DataTask : Task
{
    //! MARK: - Properties
    /// URL Session Data Task
    public var urlSessionDataTask: URLSessionDataTask { return urlSessionTask as!
        URLSessionDataTask}
    /// Contains data produced by urlSessionDataTask
    var data: Data? { return sessionDelegate.data }
    
    //! MARK: - Init & Deinit
    init(urlSession: URLSession, urlSessionDataTask: URLSessionDataTask)
    {
        super.init(urlSession: urlSession, urlSessionTask: urlSessionDataTask)
    }
}

