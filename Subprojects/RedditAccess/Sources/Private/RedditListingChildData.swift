////////////////////////////////////////////////////////////////////////////////
//
//  RedditListingChildData.swift
//  RedditAccess
//
//  Created by Iurii Khomiak on 8/25/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
struct RedditListingChildData : Codable
{
    var id: String
    var title: String
    var author: String
    var created: Date
    
    var thumbnail: URL?
    var thumbnail_width: CGFloat?
    var thumbnail_height: CGFloat?
    
    var num_comments: Int
    var preview: RedditListingChildPreview?
}
