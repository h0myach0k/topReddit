////////////////////////////////////////////////////////////////////////////////
//
//  ListingQueryDataSource.swift
//  RedditAccess
//
//  Created by Iurii Khomiak on 8/25/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation
import Core
import URLAccess

////////////////////////////////////////////////////////////////////////////////
class ListingQueryDataSource : DataSource<[ListingItem]>
{
    let query: ListingQuery
    let redditAccess: RedditAccess
    
    private var nextQuery: ListingQuery?
    private var previousQuery: ListingQuery?
    private var activeTask: Task?
    
    init(query: ListingQuery, redditAccess: RedditAccess)
    {
        self.query = query
        self.redditAccess = redditAccess
        super.init()
    }
    
    override func main(options: LoadOption)
    {
        guard let query = self.query(for: options) else
        {
            finish(error: RedditError.unsupportedOperation)
            return
        }
        
        self.activeTask = redditAccess.run(query: query,
            completionQueue: .main, completion:
        { [weak self] result in
            guard let `self` = self else { return }
            self.process(options: options, result: result)
        })
    }
    
    override func cancel()
    {
        super.cancel()
        activeTask?.cancel()
        activeTask = nil
    }
    
    override func clean()
    {
        super.clean()
        activeTask?.cancel()
        activeTask = nil
        nextQuery = nil
        previousQuery = nil
    }
    
    //! MARK: - Private
    private func query(for options: LoadOption) -> ListingQuery?
    {
        var query: ListingQuery?
        if options.contains(.initialLoad)
        {
            query = self.query
        }
        else if options.contains(.loadNext)
        {
            query = nextQuery
        }
        else if options.contains(.loadPrevious)
        {
            query = previousQuery
        }
        return query
    }
    
    private func process(options: LoadOption, result: Result<ListingResult>)
    {
        if case let .failure(error) = result
        {
            finish(error: error)
            return
        }
        guard let value = result.value else { return }
        
        if options.contains(.initialLoad)
        {
            nextQuery = value.query(for: .next)
            previousQuery = value.query(for: .previous)
        }
        else if options.contains(.loadNext)
        {
            nextQuery = value.query(for: .next)
        }
        else if options.contains(.loadPrevious)
        {
            previousQuery = value.query(for: .previous)
        }
        var metadata = Metadata()
        if nextQuery != nil
        {
            metadata.insert(.hasNext)
        }
        if previousQuery != nil
        {
            metadata.insert(.hasPrevious)
        }
        
        finish(loadOptions: options, items: value.items, metadata: metadata)
    }
}
