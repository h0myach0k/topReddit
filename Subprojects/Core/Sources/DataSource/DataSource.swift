////////////////////////////////////////////////////////////////////////////////
//
//  DataSource.swift
//  Core
//
//  Created by Iurii Khomiak on 8/25/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
/// Provides base class for DataSourceProtocol
open class DataSource<Value> : DataSourceProtocol
{
    //! MARK: - Forward Declarations
    public typealias LoadOption = DataSourceLoadOption
    public typealias Metadata = DataSourceMetadata
    public typealias ChangeRequest = DataSourceChangeRequest<Value>
    public typealias Completion = (_ changeRequest: ChangeRequest?,
        _ error: Error?) -> Void
    
    //! MARK: - Properties
    public weak var delegate: DataSourceDelegate?
    public fileprivate(set) var lastUpdateDate: Date?
    public fileprivate(set) var lastError: Error?
    public fileprivate(set) var value: Value?
    public fileprivate(set) var metadata: Metadata = []
    public fileprivate(set) var isLoading: Bool = false
    open var isEmpty: Bool
    {
        //! TODO, constraint value
        if let value = value, let array = value as? Array<Any>
        {
            return array.isEmpty
        }
        return nil == value
    }
    private var activeTaskCompletion: Completion?
    private var isCancelled = false
    
    //! MARK: - Init & Deinit
    public init() {}
    
    deinit
    {
        cancel()
    }
    
    //! MARK: - Actions
    public func loadData(options: LoadOption = [], completion: Completion? = nil)
    {
        //! Data source doesn't allow multiple load requests to be performed
        //! simultaneously, so if there is active request, data source will
        //! cancel it and notifies delegate about this incident.
        if isLoading
        {
            cancel()
            didCancelCurrentLoad()
            isCancelled = false
        }
        didStartLoadData()
        activeTaskCompletion = completion
        isLoading = true
        
        main(options: options)
    }
    
    open func cancel()
    {
        isLoading = false
        isCancelled = true
    }
    
    open func clean()
    {
        let changeRequest = changeRequestToCleanValue()
        value = nil
        lastError = nil
        lastUpdateDate = nil
        isLoading = false
        isCancelled = false
        activeTaskCompletion = nil
        metadata = []
        didChangeContent(with: changeRequest)
    }
    
    //! MARK: - Subclassing hooks
    open func main(options: LoadOption)
    {
        fatalError("To be implemented by subclasses")
    }
    
    public func finish(value: Value, metadata: Metadata)
    {
        let changeRequest = self.changeRequest(toReplaceValue: value)
        finish(changeRequest: changeRequest, metadata: metadata)
    }
    
    open func finish(changeRequest: ChangeRequest? = nil, error: Error? = nil,
        metadata: Metadata = [])
    {
        lastUpdateDate = Date()
        lastError = error
        isLoading = false
        if let changeRequest = changeRequest
        {
            value = changeRequest.value
            self.metadata = metadata
            didChangeContent(with: changeRequest)
        }
        didFinishLoadData()
        activeTaskCompletion?(changeRequest, error)
        activeTaskCompletion = nil
    }
    
    //! MARK: - Change Requests
    public func performChangeRequest(_ changeRequest: ChangeRequest)
    {
        didStartLoadData()
        value = changeRequest.value
        lastError = nil
        lastUpdateDate = Date()
        didChangeContent(with: changeRequest)
        didFinishLoadData()
    }
    
    //! MARK: - Delegate communication
    private func didStartLoadData()
    {
        delegate?.dataSourceDidStartLoading(self)
    }
    
    private func didFinishLoadData()
    {
        delegate?.dataSourceDidFinishLoading(self)
    }
    
    private func didChangeContent(with changeRequest: ChangeRequest)
    {
        delegate?.dataSource(self, didUpdateContentWith: changeRequest)
    }
    
    private func didCancelCurrentLoad()
    {
        delegate?.dataSourceDidCancelPreviouslyRunningRequest(self)
    }
}

////////////////////////////////////////////////////////////////////////////////
//! MARK:  Collection extensions
public extension DataSource where Value : RangeReplaceableCollection,
    Value.Index == Int, Value.Element : Equatable
{
    func finishLoadNext(items: Value, metadata: Metadata = [])
    {
        let changeRequest = self.changeRequestToAppend(items: items)
        finish(changeRequest: changeRequest, metadata: metadata)
    }
    
    func finishLoadPrevious(items: Value, metadata: Metadata = [])
    {
        let changeRequest = self.changeRequestToInsert(items: items, at: 0)
        finish(changeRequest: changeRequest, metadata: metadata)
    }
    
    func finishReload(items: Value, metadata: Metadata = [])
    {
        let changeRequest = self.changeRequest(toReplaceValue: items)
        finish(changeRequest: changeRequest, metadata: metadata)
    }
    
    func finish(loadOptions: LoadOption, items: Value, metadata: Metadata = [])
    {
        if loadOptions.contains(.loadNext)
        {
            finishLoadNext(items: items, metadata: metadata)
        }
        else if loadOptions.contains(.loadPrevious)
        {
            finishLoadPrevious(items: items, metadata: metadata)
        }
        else if loadOptions.contains(.initialLoad)
        {
            finishReload(items: items, metadata: metadata)
        }
    }
}
