////////////////////////////////////////////////////////////////////////////////
//
//  ImageView.swift
//  TopReddit
//
//  Created by Iurii Khomiak on 8/26/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import UIKit
import ImageDownloader

////////////////////////////////////////////////////////////////////////////////
open class ImageView : UIImageView
{
    // MARK: - Forward Declarations
    public typealias Completion = (Bool) -> Void
    
    // MARK: - Properties
    public let downloader: ImageDownloader
    
    // MARK: - Init & Deinit
    public init(downloader: ImageDownloader = ImageDownloaderFactory
        .sharedDownloader, frame: CGRect)
    {
        self.downloader = downloader
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        self.downloader = ImageDownloaderFactory.sharedDownloader
        super.init(coder: aDecoder)
    }
    
    deinit
    {
        cancel()
    }
    
    // MARK: - Public
    public func setImage(withUrl url: URL?, placeholder: UIImage? = nil,
        completion: @escaping Completion = {_ in })
    {
        cancel()
        image = placeholder
        guard let url = url else { return }
        downloader.loadImage(with: url, target: self)
        { result in
            if let image = result.value
            {
                UIView.transition(with: self,
                    duration: 0.3, options: .transitionCrossDissolve,
                    animations:
                    {
                        self.image = image
                    }, completion: nil)
            }
            completion(nil == result.error)
        }
    }
    
    public func cancel()
    {
        downloader.cancelLoadingImages(with: self)
    }
}
