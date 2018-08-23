////////////////////////////////////////////////////////////////////////////////
//
//  TestModels.swift
//  URLAccessTests
//
//  Created by Iurii Khomiak on 8/23/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
struct TestResponse : Decodable, Equatable
{
    var data: TestResponseData
}

struct TestResponseData : Decodable, Equatable
{
    var items: [TestResponseDataItem]
}

struct TestResponseDataItem : Decodable, Equatable
{
    var name: String
}

//! MARK: - Equatable
func ==(lhs: TestResponse, rhs: TestResponse) -> Bool
{
    return lhs.data == rhs.data
}

func ==(lhs: TestResponseData, rhs: TestResponseData) -> Bool
{
    return lhs.items == rhs.items
}

func ==(lhs: TestResponseDataItem, rhs: TestResponseDataItem) -> Bool
{
    return lhs.name == rhs.name
}
