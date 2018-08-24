////////////////////////////////////////////////////////////////////////////////
//
//  ImageDownloadTaskSerializer.swift
//  ImageDownloader
//
//  Created by Iurii Khomiak on 8/24/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation
import DataStore
import URLAccess

////////////////////////////////////////////////////////////////////////////////
/// Image downloder serializer for data response.
/// Converts received data to UIImage and schedules cache image operation
class ImageDownloadTaskSerializer : DataResponseSerialization
{
    //! MARK: - Properties
    let storage: DataStore?
    let storageKey: String
    let storageProperties: StoreProperties
    let storageQueue: DispatchQueue
    
    //! MARK: - Init & Deinit
    init(storage: DataStore?, key: String, queue: DispatchQueue, properties:
        StoreProperties = StoreProperties())
    {
        self.storage = storage
        self.storageKey = key
        self.storageProperties = properties
        self.storageQueue = queue
    }
    
    //! MARK: - As ResponseSerialization
    func serialize(request: URLRequest?, response: HTTPURLResponse?,
        data: Data?) -> Result<UIImage>
    {
        guard let data = data else
        {
            return .failure(URLAccessError.jsonSerializationDataIsEmpty)
        }
        
        guard let image = UIImage(data: data) else
        {
            return .failure(ImageDownloaderError.wrongImage)
        }
        
        storageQueue.async
        { [storage, storageProperties, storageKey] in
            try? storage?.store(object: image, for: storageKey, properties:
                storageProperties)
        }
        return .success(image)
    }
}
