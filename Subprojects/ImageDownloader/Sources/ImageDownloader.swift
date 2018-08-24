////////////////////////////////////////////////////////////////////////////////
//
//  ImageDownloader.swift
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
import Core

////////////////////////////////////////////////////////////////////////////////
fileprivate let storeQueueName = "com.h0myach0k.imageDownloader.queue"

////////////////////////////////////////////////////////////////////////////////
/// Class responsible to load and store images
public class ImageDownloader
{
    //! MARK: - Forward Declarations
    public typealias Completion = (Result<UIImage>) -> Void
    private typealias Item = ImageDownloaderItem
    private enum InternalError : Error { case notFound }
    
    //! MARK: - Properties
    /// URL access responsible for request management
    public let urlAccess: URLAccess
    /// Data store responsible for image storing
    public let storage: DataStore?
    /// Contains items which images were requested to download
    private var items: [ImageDownloaderItem] = []
    /// Contains items lock
    private let lock = NSRecursiveLock()
    /// Contains store queue for storage operations
    private let storeQueue = DispatchQueue(label: storeQueueName, attributes:
        .concurrent)
    
    //! MARK: - Init & Deinit
    init(urlAccess: URLAccess, storage: DataStore?)
    {
        self.urlAccess = urlAccess
        self.storage = storage
    }
    
    //! MARK: - Public actions
    func loadImage(with url: URL, target: AnyObject? = nil,
        identifier: String? = nil, queue: DispatchQueue? = nil,
        handler: @escaping Completion)
    {
        LogInfo("Requested to load image at \(url)")
        
        let queue = queue ?? .main
        let item = Item(url: url, target: target, identifier: identifier)
        addItem(item)
       
        let completionHandler =
        { [weak self] (result: Result<UIImage>) in
            guard let `self` = self else { return }
            if case let .failure(error) = result, let urlError = error as?
                URLError, urlError.code == .cancelled
            {
                //! Do nothing, this request was cancelled
            }
            else
            {
                LogInfo("Returning result for \(url)")
                handler(result)
            }
            self.removeItem(item)
        }
       
        loadCachedImage(for: item)
        { [weak self] result in
            guard let `self` = self else { return }
            guard !item.isCancelled else { return }
            if let _ = result.error
            {
                LogInfo("Started loading image from \(url)")
                self.loadImage(for: item, queue: queue, result:
                    completionHandler)
            }
            else
            {
                LogInfo("Returned image from cache for \(url)")
                queue.async { completionHandler(result) }
            }
        }
    }
    
    func cancelLoadingImages(for url: URL)
    {
        lock.lock()
        let items = self.items.filter {$0.url == url}
        lock.unlock()
        cancelLoading(items: items)
    }
    
    func cancelLoadingImages(with identifier: String)
    {
        lock.lock()
        let items = self.items.filter {$0.identifier == identifier}
        lock.unlock()
        cancelLoading(items: items)
    }
    
    func cancelLoadingImages(with target: AnyObject)
    {
        lock.lock()
        let items = self.items.filter {$0.target === target}
        lock.unlock()
        cancelLoading(items: items)
    }
    
    //! MARK: - Get Image methods
    private func loadCachedImage(for item: Item, result: @escaping Completion)
    {
        /// If storage is not available, fail immediately
        guard let storage = storage else
        {
            result(.failure(InternalError.notFound))
            return
        }
        
        /// Start storage search operation in storeQueue
        let storageKey = self.storageKey(from: item.url)
        storeQueue.async
        {
            if let image: UIImage = storage.object(for: storageKey)
            {
                result(.success(image))
            }
            else
            {
                result(.failure(InternalError.notFound))
            }
        }
    }
    
    private func loadImage(for image: Item, queue: DispatchQueue,
        result: @escaping Completion)
    {
        let storeProperties = self.storeProperties(from: image.url)
        let storageKey = self.storageKey(from: image.url)
        let urlRequest = self.urlRequest(from: image.url)
        
        let serializer = ImageDownloadTaskSerializer(storage: storage, key:
            storageKey, queue: storeQueue, properties: storeProperties)
        image.task = urlAccess.peform(request: urlRequest)
            .response(with: serializer, queue: queue, handler:
            { dataResponse in
                result(dataResponse.result)
            })
    }
    
    //! MARK: - Cancellation
    private func cancelLoading(items: [Item])
    {
        items.compactMap {$0.task}.forEach {$0.cancel()}
    }
    
    //! MARK: - Items
    private func addItem(_ item: Item)
    {
        lock.lock()
        defer { lock.unlock() }
        items.append(item)
    }
    
    private func removeItem(_ item: Item)
    {
        lock.lock()
        defer { lock.unlock() }
        if let index = items.index(of: item)
        {
            items.remove(at: index)
        }
    }
    
    //! MARK: - Utilities
    private func urlRequest(from url: URL) -> URLRequest
    {
        return URLRequest(url: url)
    }
    
    private func storageKey(from url: URL) -> String
    {
        return url.absoluteString
    }
    
    private func storeProperties(from url: URL) -> StoreProperties
    {
        return .init()
    }
}
