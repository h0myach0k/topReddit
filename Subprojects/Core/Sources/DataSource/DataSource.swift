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
open class DataSource<Value> : Codable, DataSourceProtocol
    where Value : Codable
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
    public init()
    {
    }
    
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
    
    //! MARK: - As NSCoding
    private enum CodingKeys : CodingKey
    {
        case lastUpdateDate
        case lastError
        case metadata
        case value
    }
    
    public required init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        lastUpdateDate = try container.decodeIfPresent(Date.self, forKey:
            .lastUpdateDate)
        lastError = try container.decodeIfPresent(ErrorCodingBox.self, forKey:
            .lastError)?.error
        metadata = try container.decode(Metadata.self, forKey: .metadata)
        value = try container.decodeIfPresent(Value.self, forKey: .value)
    }
    
    open func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(lastUpdateDate, forKey: .lastUpdateDate)
        try container.encodeIfPresent(lastError.map(ErrorCodingBox.init),
            forKey: .lastError)
        try container.encode(metadata, forKey: .metadata)
        try container.encodeIfPresent(value, forKey: .value)
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
    Value.Index == Int
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
