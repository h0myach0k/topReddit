////////////////////////////////////////////////////////////////////////////////
//
//  DataSourceDelegate.swift
//  Core
//
//  Created by Iurii Khomiak on 8/25/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
public protocol DataSourceDelegate: class
{
    /// Sent to delegate right after loading operation started
    func dataSourceDidStartLoading<T>(_ sender: T)
        where T : DataSourceProtocol
    /// Sent when data source content is changed
    func dataSource<T>(_ sender: T, didUpdateContentWith changeRequest:
        DataSourceChangeRequest<T.Value>) where T : DataSourceProtocol
    /// Sent to delegate right after loading operation finished
    func dataSourceDidFinishLoading<T>(_ sender: T) where T : DataSourceProtocol
    /// Sent when data source cancels previously running operation
    func dataSourceDidCancelPreviouslyRunningRequest<T>(_ sender: T)
        where T : DataSourceProtocol
}
