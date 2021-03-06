////////////////////////////////////////////////////////////////////////////////
//
//  RedditListingData.swift
//  RedditAccess
//
//  Created by Iurii Khomiak on 8/25/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
struct RedditListingData : Codable
{
    let modhash: String
    let dist: Int
    let children: [RedditListingChild]
    let after: String?
    let before: String?
}
