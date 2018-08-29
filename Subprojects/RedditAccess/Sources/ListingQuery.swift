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
public struct ListingQuery : Codable
{
    /// Defines requested listing order
    public enum Order : String, Codable
    {
        case next
        case previous
    }
    
    /// Assotiated listing type
    public var listing: Listing = .top(.all)
    /// Response items limit count
    public var count: Int = defaultCount
    
    /// Offset information
    private var order: Order?
    private var token: ListingToken?
    var offset: (order: Order, token: ListingToken)?
    {
        get
        {
            if let order = order, let token = token
            {
                return (order, token)
            }
            return nil
        }
        set
        {
            order = newValue?.order
            token = newValue?.token
        }
    }
    
    /// Initializes new query
    public init(listing: Listing = .top(.all), count: Int)
    {
        self.listing = listing
        self.count = count
    }
}
