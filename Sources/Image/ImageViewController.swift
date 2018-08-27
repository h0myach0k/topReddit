////////////////////////////////////////////////////////////////////////////////
//
//  ImageViewController.swift
//  TopReddit
//
//  Created by h0myach0k on 8/27/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation
import RedditAccess
import SharedUI
import ImageDownloader
import Core

////////////////////////////////////////////////////////////////////////////////
/// View controller responsible for presenting image
class ImageViewController : DataSourceViewController<DataSource<UIImage>>
{
    /// MARK: - Properties
    /// Image info assotiated with the controller
    private var imageInfo: ImageInfo! { didSet { imageInfoDidChange() } }
    /// Image downloader instance responsible for image loading
    private var imageDownloader = ImageDownloaderFactory.sharedDownloader
    /// Image loaded by controller
    var image: UIImage? { return value }
    
    /// MARK: - IBOutlet connections
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var closeButton: UIButton!
    @IBOutlet private var shareButton: UIButton!
    
    /// MARK: - Overriden properties
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    override var loadingTitle: String? { return nil }
    override var loadingMessage: String? { return nil }
    
    /// MARK: - Configure from storyboard
    /// Configures controller with required information. View controller must
    /// be configured before view is loaded.
    ///
    /// - Parameters:
    ///   - imageInfo: Image inforamation to load
    ///   - imageDownloader: Image downloader responsible for image loading
    func configureFromStoryboard(imageInfo: ImageInfo, imageDownloader:
        ImageDownloader = ImageDownloaderFactory.sharedDownloader)
    {
        self.imageDownloader = imageDownloader
        self.imageInfo = imageInfo
    }
    
    /// MARK: - UIViewController overrides
    override func viewDidLoad()
    {
        super.viewDidLoad()
        updateShareButtonAvailability()
    }
    
    /// MARK: - DataSourceViewController overrides
    override func reloadData(changeRequest: DataSourceChangeRequest<UIImage>,
        completion: @escaping () -> Void)
    {
        imageView.image = changeRequest.value
    }
    
    override func didFinishLoadData()
    {
        super.didFinishLoadData()
        updateShareButtonAvailability()
    }
    
    /// MARK: - Actions
    @IBAction private func swipeAction(_ sender: UISwipeGestureRecognizer)
    {
        performSegue(with: .dismissSegue, sender: nil)
    }
    
    @IBAction func share(_ sender: Any)
    {
        guard let image = value else { return }
        let shareComposer = UIActivityViewController(activityItems: [image],
            applicationActivities: nil)
        shareComposer.completionWithItemsHandler =
        { [unowned self]  _, _, _, error in
            self.didCompletedShare(with: error)
        }
        present(shareComposer, animated: true, completion: nil)
    }
    
    //! MARK: - Private
    private func imageInfoDidChange()
    {
        self.dataSource = ImageDataSource(imageInfo: imageInfo,
            imageDownloader: imageDownloader)
    }
    
    private func didCompletedShare(with error: Error?)
    {
        guard let error = error else { return }
        let alert = UIAlertController(title: "Failed to share".localized,
            message: error.localizedDescription, preferredStyle: .alert)
        present(alert, animated: true)
    }
    
    private func updateShareButtonAvailability()
    {
        shareButton.isHidden = nil == value
    }
}

////////////////////////////////////////////////////////////////////////////////
//! MARK: - As StoryboardSegueType
extension ImageViewController : StoryboardSegueType
{
    enum SegueType : String
    {
        case dismissSegue
    }
}
