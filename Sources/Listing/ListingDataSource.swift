////////////////////////////////////////////////////////////////////////////////
//
//  ListingDataSource.swift
//  TopReddit
//
//  Created by Iurii Khomiak on 8/25/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation
import Core
import URLAccess
import RedditAccess
import protocol RedditAccess.Task

////////////////////////////////////////////////////////////////////////////////
///  Data Source class responsible for loading data for given query.
class ListingDataSource : DataSource<[ListingItem]>
{
    //! MARK: - Forward Declarations
    enum Error : Swift.Error
    {
        case unsupportedOperation
    }
    
    private enum CodingKeys : CodingKey
    {
        case query
        case nextQuery
        case previousQuery
    }
    
    //! MARK: - Properties
    let query: ListingQuery
    let redditAccess: RedditAccess
    
    private var nextQuery: ListingQuery?
    private var previousQuery: ListingQuery?
    private var activeTask: Task?
    
    //! MARK: - Init & Deinit
    /// Initializes data source with starting query and dependency container
    init(query: ListingQuery, container: DependencyContainer)
    {
        self.query = query
        self.redditAccess = try! container.resolve(RedditAccess.self)
        super.init()
    }
    
    //! MARK: - As Codable
    required init(from decoder: Decoder) throws
    {
        guard let dependencyContainer = decoder.dependencyContainer else
            { throw DecodingError.noDependencyContainer }
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        query = try container.decode(ListingQuery.self, forKey: .query)
        nextQuery = try container.decodeIfPresent(ListingQuery.self, forKey:
            .nextQuery)
        previousQuery = try container.decodeIfPresent(ListingQuery.self, forKey:
            .previousQuery)        
        redditAccess = try dependencyContainer.resolve(RedditAccess.self)
        
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws
    {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(query, forKey: .query)
        try container.encodeIfPresent(nextQuery, forKey: .nextQuery)
        try container.encodeIfPresent(previousQuery, forKey: .previousQuery)
    }
    
    //! MARK: - Overriden methods
    override func main(options: LoadOption)
    {
        guard let query = self.query(for: options) else
        {
            finish(error: Error.unsupportedOperation)
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
