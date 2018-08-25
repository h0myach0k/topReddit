////////////////////////////////////////////////////////////////////////////////
//
//  DataSourceLoadOptions.swift
//  Core
//
//  Created by Iurii Khomiak on 8/25/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
/// Describes extensible struct for data source load options
public struct DataSourceLoadOptions : OptionSet
{
    /// MARK: - As OptionsSet
    public let rawValue: Int
    public init(rawValue: Int)
    {
        self.rawValue = rawValue
    }
    
    /// Initial load option
    public static let initialLoad = DataSourceLoadOptions(rawValue: 1 << 0)
    /// Load next chunk of data option
    public static let loadNext = DataSourceLoadOptions(rawValue: 1 << 1)
    /// Load previous chunk of data option
    public static let loadPrevious = DataSourceLoadOptions(rawValue: 1 << 2)
}
