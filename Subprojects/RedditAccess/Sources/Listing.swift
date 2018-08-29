////////////////////////////////////////////////////////////////////////////////
//
//  Listing.swift
//  RedditAccess
//
//  Created by Iurii Khomiak on 8/25/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
/// Defines duration for top listing type
public enum TopDuration : String, Codable
{
    case hour
    case day
    case week
    case month
    case year
    case all
}

////////////////////////////////////////////////////////////////////////////////
/// Defines listing type
///
/// - top: Top reddits listing
public enum Listing
{
    case top(TopDuration)
    case random
    case new
}

////////////////////////////////////////////////////////////////////////////////
//! MARK: - As Codable
extension Listing : Codable
{
    private enum CodingKeys : CodingKey
    {
        case top
        case random
        case new
    }
    
    public init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let _ = try container.decodeIfPresent(Bool.self, forKey: .new)
        {
            self = .new
        }
        else if let _ = try container.decodeIfPresent(Bool.self, forKey: .random)
        {
            self = .random
        }
        else
        {
            self = .top(try container.decode(TopDuration.self, forKey: .top))
        }
    }
    
    public func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self
        {
            case .new:
                try container.encode(true, forKey: .new)
            case .random:
                try container.encode(true, forKey: .random)
            case .top(let duration):
                try container.encode(duration, forKey: .top)
        }
    }
}
