////////////////////////////////////////////////////////////////////////////////
//
//  ScrollDataSourceViewController.swift
//  SharedUI
//
//  Created by Iurii Khomiak on 8/26/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import UIKit
import Core

////////////////////////////////////////////////////////////////////////////////
open class ScrollDataSourceViewController<DataSource> : DataSourceViewController<
    DataSource>, UIScrollViewDelegate, LoadMoreFooterViewDelegate
    where DataSource : DataSourceProtocol, DataSource.Value : Collection
{
    //! MARK: - Forward declarations
    typealias Item = Value.Element
    
    //! MARK: - Properties
    /// UI Outlet connection for scroll view
    @IBOutlet public var scrollView: UIScrollView!
    /// Property indicating if scroll view hasRefreshControl.
    /// Defaults to true
    open var hasRefreshControl: Bool { return true }
    /// Refresh control assotiated with scroll view
    public private(set) var refreshControl: UIRefreshControl?
    /// Load more footer style
    open var loadMoreFooterStyle: LoadMoreFooter.Style { return .default }
    /// Value indicating if load more footer should be shown
    open var hasLoadMoreFooter: Bool
    {
        return dataSource.metadata.contains(.hasNext) && !isLoading
    }
    /// Load more footer instance
    public private(set) var loadMoreFooter: LoadMoreFooter?
    /// Data source options to perform reload operation
    open var dataSourceReloadOptions: DataSourceLoadOption
    {
        return dataSourceLoadOptions
    }
    /// Data source options to perform load more operation
    open var dataSourceLoadMoreOptions: DataSourceLoadOption
    {
        return [.loadNext]
    }
    
    //! MARK: - Overriden properties
    public override var dataSource: DataSource!
    {
        didSet
        {
            hideRefreshControlIfNeeded()
            hideAndUpdateLoadMoreFooterAvailability()
        }
    }
    
    //! MARK: - Init & Deinit
    open override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        updateRefreshControlAvailability()
        updateLoadMoreFooterAvailability()
    }
    
    //! MARK: - UIViewController overrides
    
    open override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        hideRefreshControlIfNeeded()
        hideLoadMoreFooterIfNeeded()
    }
    
    open override func didFinishLoadData()
    {
        super.didFinishLoadData()
        hideRefreshControlIfNeeded()
        hideAndUpdateLoadMoreFooterAvailability()
    }
    
    //! MARK: - BaseStatesViewController overrides
    open override func addNoDataView(_ view: UIView)
    {
        addStateViewToScrollView(view)
    }
    
    open override func addErrorView(_ view: UIView)
    {
        addStateViewToScrollView(view)
    }
    
    //! MARK: - Public
    public func performLoadPage()
    {
        performLoadData(dataSourceLoadMoreOptions)
    }
    
    public func performReloadPages()
    {
        performLoadData(dataSourceReloadOptions)
    }
    
    open func createLoadMoreFooter() -> LoadMoreFooter
    {
        return LoadMoreFooter.instantiate(style: loadMoreFooterStyle)
    }
    
    //! MARK: - Actions
    @objc private func refresh(_ sender: Any)
    {
        performReloadPages()
    }
    
    //! MARK: - UIScrollViewDelegate
    open func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        loadMoreFooter?.scrollViewDidScroll(scrollView)
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView,
        willDecelerate decelerate: Bool)
    {
        loadMoreFooter?.scrollViewDidEndDragging(scrollView, willDecelerate:
            decelerate)
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        loadMoreFooter?.scrollViewDidEndDecelerating(scrollView)
    }
    
    //! MARK: - LoadMoreFooterViewDelegate
    public func loadMoreFooterView(_ sender: LoadMoreFooter, shouldChange
        state: LoadMoreFooter.State) -> Bool
    {
        return true
    }
    
    public func loadMoreFooterView(_ sender: LoadMoreFooter, didChange state:
        LoadMoreFooter.State)
    {
        guard state == .opened else { return }
        performLoadPage()
    }
    
    //! MARK: - Private
    private func updateRefreshControlAvailability()
    {
        if hasRefreshControl, nil == refreshControl
        {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(refresh), for:
                .valueChanged)
            scrollView.refreshControl = refreshControl
            self.refreshControl = refreshControl
        }
        else if !hasRefreshControl, nil != refreshControl
        {
            scrollView.refreshControl = nil
            refreshControl = nil
        }
    }
    
    private func hideRefreshControlIfNeeded()
    {
        if let refreshControl = refreshControl, refreshControl.isRefreshing
        {
            refreshControl.endRefreshing()
        }
    }
    
    private func updateLoadMoreFooterAvailability()
    {
        if hasLoadMoreFooter, nil == loadMoreFooter
        {
            let loadMoreFooter = createLoadMoreFooter()
            loadMoreFooter.delegate = self
            self.loadMoreFooter = loadMoreFooter
            loadMoreFooter.frame.size.width = scrollView.bounds.width
            scrollView.addSubview(loadMoreFooter)
        }
        else if !hasLoadMoreFooter, nil != loadMoreFooter
        {
            loadMoreFooter?.removeFromSuperview()
            loadMoreFooter = nil
        }
    }
    
    private func hideAndUpdateLoadMoreFooterAvailability()
    {
        if let loadMoreFooter = loadMoreFooter, loadMoreFooter.state == .opened
        {
            loadMoreFooter.hide(in: scrollView, animated: true)
            { _ in
                self.updateLoadMoreFooterAvailability()
            }
        }
        else
        {
            updateLoadMoreFooterAvailability()
        }
    }
    
    private func hideLoadMoreFooterIfNeeded()
    {
        loadMoreFooter?.hide(in: scrollView, animated: true, completion: nil)
    }
    
    private func addStateViewToScrollView(_ view: UIView)
    {
        scrollView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo:
            view.leadingAnchor).isActive = true
        self.view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo:
            view.trailingAnchor).isActive = true
        self.view.safeAreaLayoutGuide.topAnchor.constraint(equalTo:
            view.topAnchor).isActive = true
        self.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo:
            view.bottomAnchor).isActive = true
    }
}
