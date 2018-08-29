////////////////////////////////////////////////////////////////////////////////
//
//  StubRedditResponseManager.swift
//  RedditAccess
//
//  Created by Iurii Khomiak on 8/25/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation
@testable import RedditAccess

////////////////////////////////////////////////////////////////////////////////
class StubRedditResponseManager
{
    let baseUrl: URL
    
    init(baseUrl: URL)
    {
        self.baseUrl = baseUrl
    }
    
    func registerResponse(data: Data, for query: ListingQuery)
    {
        let filename: String
        switch query.listing
        {
            case .top:
                filename = "top.json"
            case .new:
                filename = "new.json"
        }
        let url = baseUrl.appendingPathComponent(filename)
        try! data.write(to: url)
    }
}
