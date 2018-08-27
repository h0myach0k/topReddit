////////////////////////////////////////////////////////////////////////////////
//
//  ImageDataSource.swift
//  TopReddit
//
//  Created by h0myach0k on 8/27/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation
import Core
import RedditAccess
import ImageDownloader

////////////////////////////////////////////////////////////////////////////////
/// Data source implementation for image view controller.
class ImageDataSource : DataSource<UIImage>
{
    /// MARK: - Properties
    let imageInfo: ImageInfo
    let imageDownloader: ImageDownloader
    
    /// MARK: - Init & Deinit
    init(imageInfo: ImageInfo, imageDownloader: ImageDownloader)
    {
        self.imageInfo = imageInfo
        self.imageDownloader = imageDownloader
        super.init()
    }
    
    /// MARK: - As DataSource
    override func main(options: LoadOption)
    {
        imageDownloader.loadImage(with: imageInfo.url, target: self)
        { [weak self] result in
            guard let `self` = self else { return }
            if let image = result.value
            {
                self.finish(value: image, metadata: [])
            }
            else if let error = result.error
            {
                self.finish(error: error)
            }
        }
    }
    
    override func cancel()
    {
        super.cancel()
        imageDownloader.cancelLoadingImages(with: self)
    }
}
