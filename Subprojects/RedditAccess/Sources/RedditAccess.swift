////////////////////////////////////////////////////////////////////////////////
//
//  RedditAccess.swift
//  RedditAccess
//
//  Created by Iurii Khomiak on 8/25/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation
import URLAccess

////////////////////////////////////////////////////////////////////////////////
/// Provides interface for reddit provider
public protocol RedditAccess
{
    /// URL Access responsible for HTTP communication part
    var urlAccess: URLAccess {get}
    
    /// Executes given query and notifies with the result
    ///
    /// - Parameters:
    ///   - query: Query to execute
    ///   - completionQueue: Queue where completion should be invoked
    ///   - completion: Completion handler
    /// - Returns: newly created rask information.
    @discardableResult
    func run(query: ListingQuery, completionQueue: DispatchQueue?,
        completion: @escaping (Result<ListingResult>) -> Void) -> Task
}
