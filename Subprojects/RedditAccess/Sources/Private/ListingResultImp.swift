////////////////////////////////////////////////////////////////////////////////
//
//  ListingResultImp.swift
//  RedditAccess
//
//  Created by Iurii Khomiak on 8/25/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
struct ListingResultImp
{
    let query: ListingQuery
    let items: [ListingItem]
    let nextQuery: ListingQuery?
    let previousQuery: ListingQuery?
    
    init(query: ListingQuery, response: RedditListingResponse)
    {
        self.query = query
        items = response.data.children.map(ListingItem.init)
        
        if let token = response.data.after
        {
            var query = self.query
            query.offset = (.next, token)
            nextQuery = query
        }
        else
        {
            nextQuery = nil
        }
        
        if let token = response.data.before
        {
            var query = self.query
            query.offset = (.previous, token)
            previousQuery = query
        }
        else
        {
            previousQuery = nil
        }        
    }
}

////////////////////////////////////////////////////////////////////////////////
extension ListingResultImp : ListingResult
{
    func query(for order: ListingQuery.Order) -> ListingQuery?
    {
        switch order
        {
            case .next:
                return nextQuery
            case .previous:
                return previousQuery
        }
    }
}
