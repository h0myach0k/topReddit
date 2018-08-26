////////////////////////////////////////////////////////////////////////////////
//
//  URLBuilder.swift
//  RedditAccess
//
//  Created by Iurii Khomiak on 8/25/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
enum URLBuilderError : Error
{
    case failedConvertUrlToUrlComponents
    case failedConvertUrlComponentsToUrl
}

////////////////////////////////////////////////////////////////////////////////
class URLBuilder
{
    fileprivate enum QueryKey : String
    {
        case t
        case count
        case after
        case before
    }
    
    /// Listing query
    let query: ListingQuery
    let parameters: RedditAccessParameters
    
    /// Listing query
    init(query: ListingQuery, parameters: RedditAccessParameters)
    {
        self.query = query
        self.parameters = parameters
    }
    
    /// Constructs an URL
    func build() throws -> URL
    {
        guard var components = URLComponents(url: parameters.baseUrl,
            resolvingAgainstBaseURL: false) else
        {
            throw URLBuilderError.failedConvertUrlToUrlComponents
        }
        components.path = (components.path as NSString).appendingPathComponent(
            query.relativePath)
        components.queryItems = query.queryItems
        
        guard let result = components.url else
        {
            throw URLBuilderError.failedConvertUrlComponentsToUrl
        }
        return result
    }
}

////////////////////////////////////////////////////////////////////////////////
fileprivate extension ListingQuery
{
    var relativePath: String
    {
        switch listing
        {
            case .top:
                return "/top.json"
            case .random:
                return "/random.json"
            case .new:
                return "/new.json"
        }
    }
    
    var queryItems: [URLQueryItem]?
    {
        var result: [URLQueryItem] = []
        
        //! Add listing type specific queries
        switch listing
        {
            case let .top(duration):
                result.append(.init(queryKey: .t, value: duration.rawValue))
            default:
                break
        }
        
        result.append(.init(queryKey: .count, value: String(count)))
        
        if let (order, token) = offset
        {
            switch order
            {
                case .next:
                    result.append(.init(queryKey: .after, value: token))
                case .previous:
                    result.append(.init(queryKey: .before, value: token))
            }
        }
        
        return result.isEmpty ? nil : result
    }
}

////////////////////////////////////////////////////////////////////////////////
//! MARK: - URLQueryItem extension
fileprivate extension URLQueryItem
{
    init(queryKey: URLBuilder.QueryKey, value: String)
    {
        self.init(name: queryKey.rawValue, value: value)
    }
}
