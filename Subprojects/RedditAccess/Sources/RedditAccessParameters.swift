////////////////////////////////////////////////////////////////////////////////
//
//  RedditAccessParameters.swift
//  RedditAccess
//
//  Created by Iurii Khomiak on 8/25/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
fileprivate var defaultPropertyList = "RedditAccessParameters"

////////////////////////////////////////////////////////////////////////////////
/// Describing parameters like connection, etc
public struct RedditAccessParameters : Codable
{
    public let baseUrl: URL
    public init(baseUrl: URL)
    {
        self.baseUrl = baseUrl
    }
}

////////////////////////////////////////////////////////////////////////////////
extension RedditAccessParameters
{
    init?(propertyListName: String)
    {
        guard let url = Bundle(for: RedditAccessFactory.self).url(forResource:
            propertyListName, withExtension: "plist") else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        
        let propertyListDecoder = PropertyListDecoder()
        guard let result = try? propertyListDecoder.decode(
            RedditAccessParameters.self, from: data) else { return nil }
        self = result
    }
    
    static var `default`: RedditAccessParameters
    {
        return RedditAccessParameters(propertyListName: defaultPropertyList)!
    }
}

