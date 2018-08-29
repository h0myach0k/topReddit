////////////////////////////////////////////////////////////////////////////////
//
//  AppDependencies.swift
//  TopReddit
//
//  Created by Iurii Khomiak on 8/28/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation
import Core
import ImageDownloader
import RedditAccess

////////////////////////////////////////////////////////////////////////////////
/// Defines class containing application dependencies
class AppDependencies
{
    /// Returns shared instance
    static let shared = AppDependencies()
    
    /// Container that contains registered required services for the app
    let container: DependencyContainer
        
    /// Private initializer
    private init()
    {
        let container = DependencyContainer()
        container.register(ImageDownloader.self)
            { _ in ImageDownloaderFactory.sharedDownloader }
        container.register(RedditAccess.self)
            { _ in RedditAccessFactory.sharedRedditAccess }
        self.container = container
    }
}
