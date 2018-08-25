////////////////////////////////////////////////////////////////////////////////
//
//  ListingQuery.swift
//  RedditAccess
//
//  Created by Iurii Khomiak on 8/25/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
fileprivate let defaultCount = 50

////////////////////////////////////////////////////////////////////////////////
/// Data structure for listing query
public struct ListingQuery
{
    /// Defines requested listing order
    public enum Order
    {
        case next
        case previous
    }
    
    /// Assotiated listing type
    public var listing: Listing = .top(.all)
    /// Response items limit count
    public var count: Int = defaultCount
    
    /// Offset information
    var offset: (order: Order, token: ListingToken)?
    
    /// Initializes new query
    public init(listing: Listing = .top(.all), count: Int)
    {
        self.listing = listing
        self.count = count
    }
}
