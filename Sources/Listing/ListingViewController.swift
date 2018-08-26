////////////////////////////////////////////////////////////////////////////////
//
//  ListingViewController.swift
//  TopReddit
//
//  Created by h0myach0k on 8/26/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import UIKit
import SharedUI
import RedditAccess
import Core

////////////////////////////////////////////////////////////////////////////////
/// View Controller responsible for loading/displaying listing items from
/// given query.
class ListingViewController: TableDataSourceViewController<DataSource<[ListingItem]>>,
    UITableViewDelegate, UITableViewDataSource
{
    /// Listing query assotiated with the controller
    private var query: ListingQuery! { didSet { queryDidChange() } }
    /// Reddit access provider
    private var redditAccess: RedditAccess = RedditAccessFactory.sharedRedditAccess
    
    /// Loaded listing items
    var listingItems: [ListingItem] { return value ?? [] }
    
    //! MARK: - Init & Deinit
    /// Initializes new controller with query and access provider
    ///
    /// - Parameters:
    ///   - query: Listing query assotiated with the controller
    ///   - redditAccess: Reddit access provider
    init(query: ListingQuery, redditAccess: RedditAccess)
    {
        self.query = query
        self.redditAccess = redditAccess
        super.init(dataSource: type(of: self).dataSource(from: query,
            redditAccess: redditAccess))
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    /// Configures view controller with essential data after load from storyboard
    ///
    /// - Parameters:
    ///   - query: Listing query assotiated with the controller
    ///   - redditAccess: Reddit access provider. Defaults to shared
    func configureFromStoryboard(query: ListingQuery, redditAccess:
        RedditAccess = RedditAccessFactory.sharedRedditAccess)
    {
        self.redditAccess = redditAccess
        self.query = query
    }    
    
    //! MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section:
        Int) -> Int
    {
        return listingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath:
        IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier:
            ListingItemCell.reuseIdentifier, for: indexPath)
            as? ListingItemCell else
        {
            fatalError("Unexpected cell, expectected instance of ListingItemCell")
        }
        let listingItem = listingItems[indexPath.item]
        cell.update(listingItem: listingItem)
        return cell
    }
    
    //! MARK: - Private
    private static func dataSource(from query: ListingQuery, redditAccess:
        RedditAccess) -> DataSource<[ListingItem]>
    {
        return RedditAccessFactory().createDataSource(for: query,
            in: redditAccess)
    }
    
    private func queryDidChange()
    {
        dataSource = type(of: self).dataSource(from: query, redditAccess:
            redditAccess)
        navigationItem.title = query.listing.title
    }
}
