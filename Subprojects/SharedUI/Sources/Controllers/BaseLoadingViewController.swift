////////////////////////////////////////////////////////////////////////////////
//
//  BaseLoadingViewController.swift
//  SharedUI
//
//  Created by Iurii Khomiak on 8/26/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
/// View controller that extends BaseStatesViewController with methods
/// related to data loading.
open class BaseLoadingViewController : BaseStatesViewController
{
    //! MARK: - Properties
    
    /// Returns last update date (also includes failed events)
    public var lastUpdateDate: Date?
    /// Returns last error
    public var lastError: Error?
    /// Returns true if data is empty, false if not
    /// To be overriden by subclasses
    open var isEmpty: Bool { return true }
    /// Returns true if view controller will display error view on error
    /// To be overriden by subclasses
    open var showsErrorView: Bool { return true }
    /// Returns true if view controller will display no data view if controller
    /// loads empty content
    /// To be overriden by subclasses
    open var showsNoDataView: Bool { return true }
    /// Returns true if view controller will display loading view
    /// To be overriden by subclasses
    open var showsLoadingView: Bool { return true }
    /// Indicates view controller behaviour on view did disappear
    public var cancelsLoadOnViewDidDisappear = true
    public internal(set) var isLoading = false
    open override var errorMessage: String? { return lastError?.localizedDescription }
    private var loadedSynchronously = false
    
    //! MARK: - Init & Deinit
    deinit
    {
        cancel()
    }
    
    //! MARK: - UIViewController overrides
    open override func viewDidLoad()
    {
        super.viewDidLoad()
        setScreen(isEmpty && showsLoadingView ? .loading : .content)
    }
    
    open override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        loadDataIfNeeded()
    }
    
    open override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        if cancelsLoadOnViewDidDisappear
        {
            cancel()
        }
    }
    
    //! MARK: - Public/Open methods
    public func loadDataIfNeeded()
    {
        guard isViewLoaded else { return }
        guard isLoadDataNeeded() else { return }
        if showsLoadingView
        {
            setScreen(.loading, animated: true)
        }
        performLoadData()
    }
    
    public func performLoadData()
    {
        if isLoading
        {
            cancel()
        }
        
        loadedSynchronously = true
        willStartLoadData()
        loadData()
        didStartLoadData()
        loadedSynchronously = false
    }
    
    public func performCleanAndReloadData()
    {
        clean()
        if isEmpty, showsLoadingView
        {
            setScreen(.loading, animated: true)
        }
        performLoadData()
    }
    
    public func finish(error: Error?)
    {
        lastError = error
        lastUpdateDate = Date()
        didFinishLoadData()
    }
    
    /// Method is called before data is started to load.
    /// Subclasses must call super
    open func willStartLoadData()
    {
        isLoading = true
    }
    
    /// Method is called after data is started to load.
    /// Default implementation does noting
    open func didStartLoadData()
    {
    
    }
    
    /// Method is called after data is loaded.
    /// Subclasses must call super
    open func didFinishLoadData()
    {
        let shouldShowError = (isEmpty && nil != lastUpdateDate && nil !=
            lastError) && showsErrorView
        let shouldShowNoData = (isEmpty && nil != lastUpdateDate && nil ==
            lastError) && showsNoDataView
        let shouldShowContent = (!shouldShowError && !shouldShowNoData)
        if shouldShowError
        {
            setScreen(.error, animated: !loadedSynchronously)
        }
        else if shouldShowContent
        {
            setScreen(.content, animated: !loadedSynchronously)
        }
        else if shouldShowNoData
        {
            setScreen(.noData, animated: !loadedSynchronously)
        }
        isLoading = false
    }
    
    //! MARK: - Subclassing hooks
    open func isLoadDataNeeded() -> Bool
    {
        return nil == lastUpdateDate && isEmpty && !isLoading
    }
    
    /// Override in subclasses and start load data in this place
    open func loadData()
    {
    }
    
    /// Override in subclasses and provide cancelling mechanism
    /// Subclasses must call super
    open func cancel()
    {
        isLoading = false
    }
    
    /// Override in subclasses and provide cleaning
    /// Subclasses must call super
    open func clean()
    {
        lastUpdateDate = nil
        lastError = nil
    }
    
    //! MARK: - ErrorViewDelegate
    open func errorViewRequestToRetry(_ sender: UIView)
    {
        if showsLoadingView
        {
            setScreen(.loading, animated: true)
        }
        performLoadData()
    }
}
