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
fileprivate let dataSourceCodingKey = "dataSource"

////////////////////////////////////////////////////////////////////////////////
open class DataSourceViewController<DataSourceType> : BaseLoadingViewController
    where DataSourceType : DataSourceProtocol
{
    //! MARK: - Forward Declarations
    public typealias Encoder = JSONEncoder
    public typealias Decoder = JSONDecoder
    public typealias Value = DataSourceType.Value
    public enum DataSourceError : Error
    {
        case noDataToDecode
    }
    
    //! MARK: - Propertis
    /// Data source responsible for data loading
    public var dataSource: DataSourceType?
    {
        willSet
        {
            dataSource?.cancel()
            dataSource?.delegate = nil
        }
        didSet
        {
            dataSource?.delegate = self
            dataSourceDidChange()
        }
    }
    
    /// Value produced by data source
    public private(set) var value: Value?
    /// Returns true if loaded content is empty, false if not
    open override var isEmpty: Bool { return dataSource?.isEmpty ?? true }
    public var dataSourceLoadOptions: DataSourceLoadOption = [.initialLoad]
    private var currentLoadOptions: DataSourceLoadOption = [.initialLoad]
    
    //! MARK: - Init & Deinit
    public init(dataSource: DataSourceType)
    {
        super.init()
        self.dataSource = dataSource
        self.dataSource?.delegate = self
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
    
    //! MARK: UIViewController overrides
    open override func viewDidLoad()
    {
        super.viewDidLoad()
        dataSourceDidChange()
    }
    
    //! MARK - Coding / Decoding
    /// Returns true if data source should be encoded by restorable state coder,
    /// false if not.
    /// Defaults to true
    open func shouldEncodeDataSource() -> Bool
    {
        return true
    }
    
    /// Returns true if data source should be decoded by restorable state coder,
    /// false if not. If subclasses will return false, its their responsibility
    /// to set proper data source object.
    /// Defaults to true
    open func shouldDecodeDataSource() -> Bool
    {
        return true
    }
    
    /// Returns data source encoder. Subclasses may override and modify
    /// encoder properties
    open func dataSourceEncoder() -> Encoder
    {
        return Encoder()
    }
    
    /// Returns data source decoder. Subclasses may override and modify
    /// decoder properties
    open func dataSourceDecoder() -> Decoder
    {
        return Decoder()
    }
    
    /// Method that will be called before data source is started decoding.
    /// Default implementation does nothing
    open func willStartDataSourceDecoding()
    {
    }
    
    /// Method that will be called before data source is started encoding.
    /// Default implementation does nothing
    open func willStartDataSourceEncoding()
    {
    }
    
    /// Method that will be called after data source is finised decoding.
    /// Data Source object is propertly restored during this method call.
    /// Default implementation does nothing
    open func didFinishDataSourceDecoding()
    {
    }
    
    /// Method that will be called after data source is finised encoding.
    /// Default implementation does nothing
    open func didFinishDataSourceEncoding()
    {
    }
    
    /// Method that will be called when data source is failed to decode.
    /// Subclasses that supports Application State preservation/restoration
    /// must set dataSource object.
    /// Default implementation does nothing
    open func didFailDataSourceDecoding(error: Error)
    {
    }
    
    /// Method that will be called when data source is failed to encode.
    /// Default implementation does nothing
    open func didFailDataSourceEncoding(error: Error)
    {
    }
    
    override open func decodeRestorableState(with coder: NSCoder)
    {
        super.decodeRestorableState(with: coder)
        
        guard shouldDecodeDataSource() else { return }
        willStartDataSourceDecoding()
        LogInfo("\(self): will start data source decoding")
        guard let data = coder.decodeObject(forKey: dataSourceCodingKey)
            as? Data else
        {
            let error = DataSourceError.noDataToDecode
            didFailDataSourceDecoding(error: error)
            LogError("\(self): did fail data source decoding with \(error)")
            return
        }
        let decoder = dataSourceDecoder()
        do
        {
            self.dataSource = try decoder.decode(DataSourceType.self, from:
                data)
            didFinishDataSourceDecoding()
            LogInfo("\(self): did finish data source decoding")
        }
        catch
        {
            didFailDataSourceDecoding(error: error)
            LogError("\(self): did fail data source decoding with \(error)")
        }
    }
    
    override open func encodeRestorableState(with coder: NSCoder)
    {
        super.encodeRestorableState(with: coder)
        
        guard shouldEncodeDataSource() else { return }
        willStartDataSourceEncoding()
        LogInfo("\(self): will start data source encoding")
        let encoder = dataSourceEncoder()
        do
        {
            let data = try encoder.encode(dataSource)
            coder.encode(data, forKey: dataSourceCodingKey)
            didFinishDataSourceEncoding()
            LogInfo("\(self): did finish data source encoding")
        }
        catch
        {
            didFailDataSourceEncoding(error: error)
            LogError("\(self): did fail data source encoding with \(error)")
        }
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
    
    open func didReloadData()
    {
        
    }
    
    open func willReloadData()
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
        dataSource?.loadData(options: currentLoadOptions, completion: nil)
    }
    
    open override func clean()
    {
        super.clean()
        dataSource?.clean()
    }
    
    final public override func performLoadData()
    {
        currentLoadOptions = dataSourceLoadOptions
        super.performLoadData()
    }
    
    //! MARK: - Private
    private func dataSourceContentDidChange()
    {
        self.value = dataSource?.value
        self.lastUpdateDate = dataSource?.lastUpdateDate
        self.lastError = dataSource?.lastError
    }
    
    private func dataSourceDidChange()
    {
        dataSourceContentDidChange()
        
        guard isViewLoaded else { return }
        guard let dataSource = dataSource else { return }
        
        if nil != dataSource.lastUpdateDate
        {
            willStartLoadData()
            if let value = value
            {
                let changeRequest = dataSource.changeRequest(toReplaceValue:
                    value)
                willReloadData()
                reloadData(changeRequest: changeRequest, completion:
                    didReloadData)
            }
            didFinishLoadData()
        }
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
        willReloadData()
        reloadData(changeRequest: changeRequest, completion: didReloadData)
    }
    
    public func dataSourceDidCancelPreviouslyRunningRequest<T>(_ sender: T)
        where T : DataSourceProtocol
    {
    }
}
