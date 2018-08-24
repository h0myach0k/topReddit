////////////////////////////////////////////////////////////////////////////////
//
//  ImageDownloaderItem.swift
//  ImageDownloader
//
//  Created by Iurii Khomiak on 8/24/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation
import URLAccess

////////////////////////////////////////////////////////////////////////////////
/// Image downloader item representation
class ImageDownloaderItem
{
    //! MARK: - Properties
    /// Image URL
    let url: URL
    /// Target assotiated with item or nil
    let target: AnyObject?
    /// Identifier assotiated with item or nil
    let identifier: String?
    /// Data Task assotiated with item or nil
    var task: DataTask?
    private var _isCancelled = false
    private let lock = NSRecursiveLock()
    /// Containing value that indicates if item was cancelled.
    var isCancelled: Bool
    {
        get
        {
            lock.lock()
            defer { lock.unlock() }
            return _isCancelled
        }
        set
        {
            lock.lock()
            defer { lock.unlock() }
            _isCancelled = newValue
        }
    }
    
    //! MARK: - Init & Deinit
    init(url: URL, target: AnyObject?, identifier: String?)
    {
        self.url = url
        self.target = target
        self.identifier = identifier
    }
}

////////////////////////////////////////////////////////////////////////////////
//! MARK: - As Equatable
extension ImageDownloaderItem : Equatable
{
    static public func ==(lhs: ImageDownloaderItem, rhs: ImageDownloaderItem) -> Bool
    {
        return lhs.url == rhs.url && lhs.task == rhs.task
    }
}
