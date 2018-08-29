////////////////////////////////////////////////////////////////////////////////
//
//  ImageDataSource.swift
//  TopReddit
//
//  Created by Iurii Khomiak on 8/27/18.
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
/// Responsible for resolving ImageInfo instance
class ImageDataSource : DataSource<ResolvedImageInfo>
{
    //! MARK: - Forward Declarations
    private enum CodingKeys : CodingKey
    {
        case imageInfo
    }
    
    //! MARK: - Properties
    let imageInfo: ImageInfo
    let imageDownloader: ImageDownloader
    
    //! MARK: - Init & Deinit
    init(imageInfo: ImageInfo, container: DependencyContainer)
    {
        self.imageInfo = imageInfo
        self.imageDownloader = try! container.resolve(ImageDownloader.self)
        super.init()
    }
    
    //! MARK: - As Coding
    required init(from decoder: Decoder) throws
    {
        guard let dependencyContainer = decoder.dependencyContainer else
            { throw DecodingError.noDependencyContainer }
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        imageInfo = try container.decode(ImageInfo.self, forKey: .imageInfo)
        
        imageDownloader = try dependencyContainer.resolve(ImageDownloader.self)
        
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws
    {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(imageInfo, forKey: .imageInfo)
    }
    
    //! MARK: - As DataSource
    override func main(options: LoadOption)
    {
        imageDownloader.loadImage(with: imageInfo.url, target: self)
        { [weak self] result in
            guard let `self` = self else { return }
            if let image = result.value
            {
                let result = ResolvedImageInfo(image: image, info: self.imageInfo)
                self.finish(value: result, metadata: [])
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
