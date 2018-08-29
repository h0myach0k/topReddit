////////////////////////////////////////////////////////////////////////////////
//
//  ImageViewController.swift
//  TopReddit
//
//  Created by Iurii Khomiak on 8/27/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation
import RedditAccess
import SharedUI
import Core

////////////////////////////////////////////////////////////////////////////////
/// View controller responsible for presenting image
class ImageViewController : DataSourceViewController<ImageDataSource>
{
    //! MARK: - Properties
    /// Image info assotiated with the controller
    private var imageInfo: ImageInfo? { return dataSource?.imageInfo }
    /// Dependency container
    private var container: DependencyContainer!
    /// Image loaded by controller
    var image: UIImage? { return value?.image }
    
    //! MARK: - IBOutlet connections
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var shareBarButtonItem: UIBarButtonItem!
    
    //! MARK: - Overriden properties
    override var prefersStatusBarHidden: Bool { return true }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation
    {
        return .slide
    }
    override var loadingTitle: String? { return nil }
    override var loadingMessage: String? { return nil }
    
    //! MARK: - Configure from storyboard
    /// Configures controller with required information. View controller must
    /// be configured before view is loaded.
    ///
    /// - Parameters:
    ///   - imageInfo: Image inforamation to load
    ///   - container: Dependencies container
    func configureFromStoryboard(imageInfo: ImageInfo, container:
        DependencyContainer)
    {
        self.container = container
        self.dataSource = ImageDataSource(imageInfo: imageInfo, container:
            container)
    }
    
    //! MARK: - UIViewController overrides
    override func viewDidLoad()
    {
        super.viewDidLoad()
        updateShareButtonAvailability()
        imageView.image = image
    }
    
    //! MARK: - Override Codable Methods
    override func decodeRestorableState(with coder: NSCoder)
    {
        super.decodeRestorableState(with: coder)
        container = AppDependencies.shared.container
    }
    
    //! MARK: - DataSourceViewController overrides
    override func reloadData(changeRequest: DataSourceChangeRequest<
        ResolvedImageInfo>, completion: @escaping () -> Void)
    {
        imageView.image = changeRequest.value?.image
    }
    
    override func dataSourceDecoder() -> Decoder
    {
        //! Since our data source intializes with dependency container,
        //! default decoder is overriden with injection of dependency container
        let result = super.dataSourceDecoder()
        result.dependencyContainer = AppDependencies.shared.container
        return result
    }
        
    override func didFinishLoadData()
    {
        super.didFinishLoadData()
        updateShareButtonAvailability()
    }
    
    //! MARK: - Actions
    @IBAction func share(_ sender: Any)
    {
        guard let image = image else { return }
        let shareComposer = UIActivityViewController(activityItems: [image],
            applicationActivities: nil)
        shareComposer.completionWithItemsHandler =
        { [unowned self]  _, _, _, error in
            self.didCompletedShare(with: error)
        }
        present(shareComposer, animated: true, completion: nil)
    }
    
    //! MARK: - Private
    private func didCompletedShare(with error: Error?)
    {
        guard let error = error else { return }
        let alert = UIAlertController(title: "Failed to share".localized,
            message: error.localizedDescription, preferredStyle: .alert)
        present(alert, animated: true)
    }
    
    private func updateShareButtonAvailability()
    {
        let items: [UIBarButtonItem] = nil == image ? [] : [shareBarButtonItem]
        setToolbarItems(items, animated: true)
    }
}
