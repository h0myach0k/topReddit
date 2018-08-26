////////////////////////////////////////////////////////////////////////////////
//
//  RedditAccessFactory.swift
//  RedditAccess
//
//  Created by Iurii Khomiak on 8/25/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation
import URLAccess
import Core

////////////////////////////////////////////////////////////////////////////////
/// Creates Reddit Access instances by given url access.
/// Optionaly, provide way to get shared instance
public class RedditAccessFactory
{
    //! MARK: - Properties
    /// Parameters to be used during shared instance creation.
    /// Parameters must be set before sharedRedditAccess method is called,
    /// otherwise no effect will be.
    static public var sharedRedditAccessParameters: RedditAccessParameters = .default    
    /// Returns shared reddit provider
    static public let sharedRedditAccess: RedditAccess = RedditAccessImp(
        urlAccess: .shared, parameters: sharedRedditAccessParameters)
    
    //! MARK: - Init & Deinit
    public init() {}
    
    //! MARK: - Methods
    /// Creates newly initialized reddit provider with given url access
    public func createRedditAccess(urlAccess: URLAccess, parameters:
        RedditAccessParameters) -> RedditAccess
    {
        return RedditAccessImp(urlAccess: urlAccess, parameters: parameters)
    }
    
    /// Creates data source for given query
    public func createDataSource(for query: ListingQuery, in redditAccess:
        RedditAccess) -> DataSource<[ListingItem]>
    {
        return ListingQueryDataSource(query: query, redditAccess: redditAccess)
    }
}

