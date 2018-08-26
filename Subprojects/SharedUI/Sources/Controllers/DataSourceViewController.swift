////////////////////////////////////////////////////////////////////////////////
//
//  DataSourceViewController.swift
//  SharedUI
//
//  Created by Iurii Khomiak on 8/26/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation
import Core

////////////////////////////////////////////////////////////////////////////////
open class DataSourceViewController<DataSourceType> : BaseLoadingViewController
    where DataSourceType : DataSourceProtocol
{
    //! MARK: - Forward Declarations
    public typealias Value = DataSourceType.Value
    
    //! MARK: - Propertis
    /// Data source responsible for data loading
    public var dataSource: DataSourceType!
    {
        willSet
        {
            dataSource?.cancel()
            dataSource?.delegate = nil
        }
        didSet
        {
            dataSource.delegate = self
            dataSourceContentDidChange()
        }
    }
    
    /// Value produced by data source
    public private(set) var value: Value?
    /// Returns true if loaded content is empty, false if not
    open override var isEmpty: Bool { return dataSource.isEmpty }
    public var dataSourceLoadOptions: DataSourceLoadOption = [.initialLoad]
    private var currentLoadOptions: DataSourceLoadOption = [.initialLoad]
    
    //! MARK: - Init & Deinit
    public init(dataSource: DataSourceType)
    {
        super.init()
        self.dataSource = dataSource
        self.dataSource.delegate = self
        dataSourceContentDidChange()
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    deinit
    {
        dataSource?.delegate = nil
        dataSource?.cancel()
    }
    
    //! MARK: - Public
    public func performLoadData(_ options: DataSourceLoadOption)
    {
        currentLoadOptions = options
        super.performLoadData()
    }
    
    /// Reloads data based on change request
    /// Override in subclasses
    open func reloadData(changeRequest: DataSourceChangeRequest<Value>,
        completion: @escaping () -> Void)
    {
    }
    
    //! MARK: BaseLoadingViewController overrides
    open override func cancel()
    {
        super.cancel()
        dataSource?.cancel()
    }
    
    open override func loadData()
    {
        super.loadData()
        dataSource.loadData(options: currentLoadOptions, completion: nil)
    }
    
    open override func clean()
    {
        super.clean()
        dataSource.clean()
    }
    
    final public override func performLoadData()
    {
        currentLoadOptions = dataSourceLoadOptions
        super.performLoadData()
    }
    
    //! MARK: - Private
    private func dataSourceContentDidChange()
    {
        self.value = dataSource.value
        self.lastUpdateDate = dataSource.lastUpdateDate
        self.lastError = dataSource.lastError
    }
}

////////////////////////////////////////////////////////////////////////////////
extension DataSourceViewController : DataSourceDelegate
{
    public func dataSourceDidStartLoading<T>(_ sender: T)
        where T : DataSourceProtocol
    {
    }
    
    public func dataSourceDidFinishLoading<T>(_ sender: T)
        where T : DataSourceProtocol
    {
        dataSourceContentDidChange()
        didFinishLoadData()
    }
    
    public func dataSource<T>(_ sender: T, didUpdateContentWith
        changeRequest: DataSourceChangeRequest<T.Value>)
        where T : DataSourceProtocol
    {
        dataSourceContentDidChange()
        let changeRequest = changeRequest as! DataSourceChangeRequest<
            DataSourceType.Value>
        reloadData(changeRequest: changeRequest, completion: {})
    }
    
    public func dataSourceDidCancelPreviouslyRunningRequest<T>(_ sender: T)
        where T : DataSourceProtocol
    {
    }
}
