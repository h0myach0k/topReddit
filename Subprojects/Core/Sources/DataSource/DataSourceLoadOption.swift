////////////////////////////////////////////////////////////////////////////////
//
//  DataSourceLoadOption.swift
//  Core
//
//  Created by Iurii Khomiak on 8/25/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
/// Describes extensible struct for data source load option
public struct DataSourceLoadOption : OptionSet
{
    //! MARK: - As OptionsSet
    public let rawValue: Int
    public init(rawValue: Int)
    {
        self.rawValue = rawValue
    }
    
    /// Initial load option
    public static let initialLoad = DataSourceLoadOption(rawValue: 1 << 0)
    /// Load next chunk of data option
    public static let loadNext = DataSourceLoadOption(rawValue: 1 << 1)
    /// Load previous chunk of data option
    public static let loadPrevious = DataSourceLoadOption(rawValue: 1 << 2)
}
