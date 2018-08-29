////////////////////////////////////////////////////////////////////////////////
//
//  UIImageExtensions.swift
//  TopReddit
//
//  Created by Iurii Khomiak on 8/27/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import UIKit
import RedditAccess

////////////////////////////////////////////////////////////////////////////////
/// Codable wrapper around UIImage
struct ResolvedImageInfo
{
    enum ErrorCode : Error
    {
        case brokenImage
    }
    
    var image: UIImage
    var info: ImageInfo
    
    enum CodingKeys : CodingKey
    {
        case image
        case info
    }
}

////////////////////////////////////////////////////////////////////////////////
//! MARK: - As Codable
extension ResolvedImageInfo : Codable
{
    init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let image = UIImage(data: try container.decode(Data.self,
            forKey: .image)) else { throw ErrorCode.brokenImage }
        self.image = image
        info = try container.decode(ImageInfo.self, forKey: .info)
    }
    
    func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(image.data, forKey: .image)
        try container.encode(info, forKey: .info)
    }
}
