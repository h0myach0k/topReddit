////////////////////////////////////////////////////////////////////////////////
//
//  ImageDownloaderFactory.swift
//  ImageDownloader
//
//  Created by Iurii Khomiak on 8/24/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation
import URLAccess
import DataStore

////////////////////////////////////////////////////////////////////////////////
fileprivate let defaultDataStoreIdentifier = "ImageDownloader"

////////////////////////////////////////////////////////////////////////////////
/// Image downloader provider factory class
public class ImageDownloaderFactory
{
    /// Returns shared image downloader
    public static let sharedDownloader: ImageDownloader = getSharedImageDownloader()
    
    /// Initializes new image downloader instance
    ///
    /// - Parameters:
    ///   - urlAccess: url access
    ///   - dataStore: data store
    /// - Returns: Newly initialized instance of ImageDownloader
    public func createImageDownloader(urlAccess: URLAccess, dataStore:
        DataStore?) -> ImageDownloader
    {
        return ImageDownloader(urlAccess: urlAccess, storage: dataStore)
    }
    
    //! MARK: - Private
    private static func getSharedImageDownloader() -> ImageDownloader
    {
        let urlAccess = URLAccess(configuration: .default)
        let dataStore = try? DataStoreFactory().createDataStore(identifier:
            defaultDataStoreIdentifier, type: .fileSystem(directory:
            .cachesDirectory, domainMask: .userDomainMask))
        return ImageDownloader(urlAccess: urlAccess, storage: dataStore)
    }
}
