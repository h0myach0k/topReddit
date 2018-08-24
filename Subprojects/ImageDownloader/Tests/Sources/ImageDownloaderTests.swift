////////////////////////////////////////////////////////////////////////////////
//
//  ImageDownloaderTests.swift
//  ImageDownloaderTests
//
//  Created by Iurii Khomiak on 8/24/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import XCTest
@testable import ImageDownloader
import URLAccess
import Core

////////////////////////////////////////////////////////////////////////////////
class ImageDownloaderTests: XCTestCase
{
    override func setUp()
    {
        super.setUp()
        ImageDownloaderFactory.sharedDownloader.storage?.clear()
        LoggerManager.shared.logLevel = .info
    }
    
    func testDownloadImage()
    {
        let url = testImageUrl()
        
        let downloadExpectation = self.expectation(description: "Download expectation")
        
        let imageDownloader = ImageDownloaderFactory.sharedDownloader
        imageDownloader.loadImage(with: url)
        { result in
            if let _ = result.value
            {
                downloadExpectation.fulfill()
            }
        }
        waitForExpectations(timeout: 5.0, handler: nil)
        sleep(1) //! Wait until cache will be available
        
        let cacheExpectation = self.expectation(description: "Cache expectation")
        imageDownloader.loadImage(with: url)
        { result in
            if let _ = result.value
            {
                cacheExpectation.fulfill()
            }
        }
        waitForExpectations(timeout: 0.1, handler: nil)
        
        let object: UIImage? = imageDownloader.storage?.object(for: url
            .absoluteString)
        XCTAssertNotNil(object)
    }
    
    //! MARK: - Private
    private func testImageUrl() -> URL
    {
        let url = Bundle(for: ImageDownloaderTests.self).url(forResource:
            "testImage", withExtension: "jpeg")!
        return url
    }
}
