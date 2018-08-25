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
    let response: RedditListingResponse
    
    init(query: ListingQuery, response: RedditListingResponse)
    {
        self.query = query
        self.response = response
    }
}

////////////////////////////////////////////////////////////////////////////////
extension ListingResultImp : ListingResult
{
    var items: [ListingItem]
    {
        return response.data.children
    }
    
    func query(for order: ListingQuery.Order) -> ListingQuery?
    {
        let token: String?
        switch order
        {
            case .next:
                token = response.data.after
            case .previous:
                token = response.data.before
        }
        
        guard let unwrappedToken = token else { return nil }
        var result = query
        result.offset = (order, unwrappedToken)
        return result
    }
}
