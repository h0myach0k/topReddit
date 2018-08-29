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
import Core

////////////////////////////////////////////////////////////////////////////////
private let queryCount = 20

////////////////////////////////////////////////////////////////////////////////
/// View controller extending ListingViewController with concrete query
class TopListingViewController : ListingViewController
{
    private static let query: ListingQuery = ListingQuery(listing: .top(.all),
        count: queryCount)
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        configureFromStoryboard(
            query: type(of: self).query,
            container: AppDependencies.shared.container)
    }
}
