////////////////////////////////////////////////////////////////////////////////
//
//  TopListingViewController.swift
//  TopReddit
//
//  Created by Iurii Khomiak on 8/26/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation
import RedditAccess

////////////////////////////////////////////////////////////////////////////////
private let queryCount = 20

////////////////////////////////////////////////////////////////////////////////
class TopListingViewController : ListingViewController
{
    private static let query: ListingQuery = ListingQuery(listing: .top(.all),
        count: queryCount)
    
    init(redditAccess: RedditAccess = RedditAccessFactory.sharedRedditAccess)
    {
        super.init(query: type(of: self).query, redditAccess: redditAccess)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        configureFromStoryboard(query: type(of: self).query)
    }
}
