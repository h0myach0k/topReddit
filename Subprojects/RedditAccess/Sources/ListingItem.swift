////////////////////////////////////////////////////////////////////////////////
//
//  ListingItem.swift
//  RedditAccess
//
//  Created by Iurii Khomiak on 8/25/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
/// Describes listing item
public struct ListingItem
{
    public let id: String
    public let title: String
    public let author: String
    public let createdDate: Date
    public let thumbnailInfo: ImageInfo?
    public let numberOfComments: Int
    public let imageInfos: [ImageInfo]
}

////////////////////////////////////////////////////////////////////////////////
extension ListingItem
{
    init(redditListingChild child: RedditListingChild)
    {
        id = child.data.id
        title = child.data.title
        author = child.data.author
        createdDate = child.data.created
        if let url = child.data.thumbnail,
            let width = child.data.thumbnail_width,
            let height = child.data.thumbnail_height
        {
            thumbnailInfo = ImageInfo(url: url, size: CGSize(width: width,
                height: height))
        }
        else
        {
            thumbnailInfo = nil
        }
        numberOfComments = child.data.num_comments
        imageInfos = child.data.preview?.images?.map { ImageInfo(url:
            $0.source.url, size: CGSize(width: $0.source.width, height:
            $0.source.height))} ?? []
    }
}


////////////////////////////////////////////////////////////////////////////////
extension ListingItem : Equatable
{
    public static func ==(lhs: ListingItem, rhs: ListingItem) -> Bool
    {
        return lhs.id == rhs.id
    }
}

////////////////////////////////////////////////////////////////////////////////
extension ListingItem : Hashable
{
    public var hashValue: Int
    {
        return id.hashValue
    }
}
