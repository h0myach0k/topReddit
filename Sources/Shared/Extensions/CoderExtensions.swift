////////////////////////////////////////////////////////////////////////////////
//
//  CoderExtensions.swift
//  TopReddit
//
//  Created by Iurii Khomiak on 8/28/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation
import Core

////////////////////////////////////////////////////////////////////////////////
extension CodingUserInfoKey
{
    static var dependencyContainer = CodingUserInfoKey(rawValue:
        "dependencyContainerKey")!
}

////////////////////////////////////////////////////////////////////////////////
extension Decoder
{
    var dependencyContainer: DependencyContainer?
    {
        get { return userInfo[.dependencyContainer] as? DependencyContainer }
    }
}

////////////////////////////////////////////////////////////////////////////////
extension JSONDecoder
{
    var dependencyContainer: DependencyContainer?
    {
        get { return userInfo[.dependencyContainer] as? DependencyContainer }
        set { userInfo[.dependencyContainer] = newValue }
    }
}

////////////////////////////////////////////////////////////////////////////////
extension PropertyListDecoder
{
    var dependencyContainer: DependencyContainer?
    {
        get { return userInfo[.dependencyContainer] as? DependencyContainer }
        set { userInfo[.dependencyContainer] = newValue }
    }
}
