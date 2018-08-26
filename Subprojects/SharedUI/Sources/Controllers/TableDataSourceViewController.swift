////////////////////////////////////////////////////////////////////////////////
//
//  TableDataSourceViewController.swift
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
open class TableDataSourceViewController<DataSource> :
    ScrollDataSourceViewController<DataSource>
    where DataSource : DataSourceProtocol, DataSource.Value : Collection
{
    /// UI connection to collection view
    @IBOutlet public var tableView: UITableView!
    {
        get { return scrollView as! UITableView }
        set { scrollView = newValue }
    }
    
    /// Overriden reload data method
    open override func reloadData(changeRequest: DataSourceChangeRequest<
        DataSource.Value>, completion: @escaping () -> Void)
    {
        tableView.reloadData()
        completion()
    }
}
