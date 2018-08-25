////////////////////////////////////////////////////////////////////////////////
//
//  RedditListingChild.swift
//  RedditAccess
//
//  Created by Iurii Khomiak on 8/25/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
struct RedditListingChild : Codable
{
    var kind: String
    var data: RedditListingChildData
}

////////////////////////////////////////////////////////////////////////////////
extension RedditListingChild : ListingItem
{
    var title: String
    {
        return data.title
    }
    
    var author: String
    {
        return data.author
    }
    
    var createdDate: Date
    {
        return data.created
    }
    
    var thumbnailInfo: ImageInfo?
    {
        guard let url = data.thumbnail else { return nil }
        guard let width = data.thumbnail_width else { return nil }
        guard let height = data.thumbnail_height else { return nil }
        
        return ImageInfoImp(url: url, size: CGSize(width: width, height:
            height))
    }
    
    var numberOfComments: Int
    {
        return data.num_comments
    }
}
