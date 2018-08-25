////////////////////////////////////////////////////////////////////////////////
//
//  DataSourceProtocol.swift
//  Core
//
//  Created by Iurii Khomiak on 8/25/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
public typealias DataSourceLoadDataCompletion<Value> = (_ changeRequest:
    DataSourceChangeRequest<Value>?, _ error: Error?) -> Void

////////////////////////////////////////////////////////////////////////////////
/// Interface that describes data source properties and methods
public protocol DataSourceProtocol: class
{
    //! MARK: - Forward Declarations
    /// Assotiated type
    associatedtype Value
    
    //! MARK: - Properties
    /// Data source delegate object
    var delegate: DataSourceDelegate? {get set}
    /// Returns last updated date (success or failure)
    var lastUpdateDate: Date? {get}
    /// Returns last error or nil if previous operation was successfull
    var lastError: Error? {get}
    /// Returns data source value or nil
    var value: Value? {get}
    /// Returns true if data source doen't dontain value
    var isEmpty: Bool {get}
    /// Returns true if data source is currently loading data, false otherwise
    var isLoading: Bool {get}
    /// Returns metadata options
    var metadata: DataSourceMetadata {get}
    
    //! MARK: - Operations
    /// Starts load data with given options and notifies when operation will be
    ///    finished.
    ///
    /// - Parameters:
    ///   - options: Load options, that describes what operation should be loaded
    ///       by data source
    ///   - completion: Completion handler containing change request on success
    ///       or error on failure
    func loadData(options: DataSourceLoadOptions, completion:
        DataSourceLoadDataCompletion<Value>?)
    
    /// Cancels currently active load operation
    func cancel()
    
    /// Cleans data source
    func clean()
    
    //! MARK: - Change Request methods
    /// Creates change request to clean value
    func changeRequestToCleanValue() -> DataSourceChangeRequest<Value>
    /// Creates change request to replace value with given value
    func changeRequest(toReplaceValue value: Value?) -> DataSourceChangeRequest<Value>
    /// Starts given change request
    func performChangeRequest(_ changeRequest: DataSourceChangeRequest<Value>)
}
