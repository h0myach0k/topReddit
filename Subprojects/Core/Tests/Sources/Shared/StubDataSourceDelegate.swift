////////////////////////////////////////////////////////////////////////////////
//
//  StubDataSourceDelegate.swift
//  Core
//
//  Created by Iurii Khomiak on 8/25/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
class StubDataSourceDelegate<Value> : DataSourceDelegate
{
    var didStart: (() -> Void)?
    var didUpdate: ((DataSourceChangeRequest<Value>) -> Void)?
    var didFinish: (() -> Void)?
    var didCancel: (() -> Void)?
    
    func dataSourceDidFinishLoading<T>(_ sender: T) where T : DataSourceProtocol
    {
        didFinish?()
    }
    
    func dataSourceDidStartLoading<T>(_ sender: T) where T : DataSourceProtocol
    {
        didStart?()
    }
    
    func dataSourceDidCancelPreviouslyRunningRequest<T>(_ sender: T)
        where T : DataSourceProtocol
    {
        didCancel?()
    }
    
    func dataSource<T>(_ sender: T, didUpdateContentWith changeRequest:
        DataSourceChangeRequest<T.Value>) where T : DataSourceProtocol
    {
        didUpdate?(changeRequest as! DataSourceChangeRequest<Value>)
    }
}
