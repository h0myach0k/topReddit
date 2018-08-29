////////////////////////////////////////////////////////////////////////////////
//
//  DataSourceMetadata.swift
//  Core
//
//  Created by Iurii Khomiak on 8/25/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
/// Describes extensible struct for data source metadata options
public struct DataSourceMetadata : OptionSet, Codable
{
    //! MARK: - As OptionsSet
    public let rawValue: Int
    public init(rawValue: Int)
    {
        self.rawValue = rawValue
    }
    
    /// Option indicating that data source can load next data
    public static let hasNext = DataSourceMetadata(rawValue: 1 << 0)
    /// Option indicating that data source can load previous data
    public static let hasPrevious = DataSourceMetadata(rawValue: 1 << 1)
}
