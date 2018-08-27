////////////////////////////////////////////////////////////////////////////////
//
//  ListingViewController.swift
//  TopReddit
//
//  Created by h0myach0k on 8/26/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import UIKit
import SharedUI
import RedditAccess
import Core
import ImageDownloader

////////////////////////////////////////////////////////////////////////////////
/// View Controller responsible for loading/displaying listing items from
/// given query.
class ListingViewController: TableDataSourceViewController<DataSource<[ListingItem]>>,
    UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching,
    ListingItemCellDelegate
{
    /// Listing query assotiated with the controller
    private var query: ListingQuery! { didSet { queryDidChange() } }
    /// Reddit access provider
    private var redditAccess = RedditAccessFactory.sharedRedditAccess
    /// Image downloader
    private var imageDownloader = ImageDownloaderFactory.sharedDownloader
    
    /// Loaded listing items
    var listingItems: [ListingItem] { return value ?? [] }
    private var thumbnails: [ListingItem : UIImage] = [:]
    
    //! MARK: - Init & Deinit
    /// Initializes new controller with query and access provider
    ///
    /// - Parameters:
    ///   - query: Listing query assotiated with the controller
    ///   - redditAccess: Reddit access provider
    init(query: ListingQuery, redditAccess: RedditAccess)
    {
        self.query = query
        self.redditAccess = redditAccess
        super.init(dataSource: type(of: self).dataSource(from: query,
            redditAccess: redditAccess))
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    /// Configures view controller with essential data after load from storyboard
    ///
    /// - Parameters:
    ///   - query: Listing query assotiated with the controller
    ///   - redditAccess: Reddit access provider. Defaults to shared
    func configureFromStoryboard(query: ListingQuery, redditAccess:
        RedditAccess = RedditAccessFactory.sharedRedditAccess)
    {
        self.redditAccess = redditAccess
        self.query = query
    }
    
    //! MARK: - UIViewController overrides
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        thumbnails = [:]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        guard let type = segueType(from: segue.identifier) else
        {
            super.prepare(for: segue, sender: sender)
            return
        }
        
        switch type
        {
            case .showImage:
                guard let sender = sender as? ImageInfo else
                {
                    fatalError("Segue sender is expected to be ImageInfo")
                }
                guard let controller = segue.destination as? ImageViewController
                    else
                {
                    fatalError("Segue destination controller is expected to be ImageViewController")
                }
                controller.configureFromStoryboard(imageInfo: sender)
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with
        coordinator: UIViewControllerTransitionCoordinator)
    {
        super.willTransition(to: newCollection, with: coordinator)
        coordinator.animate(alongsideTransition:
        { (context) in
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }, completion: nil)
    }
    
    //! MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section:
        Int) -> Int
    {
        return listingItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath:
        IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier:
            ListingItemCell.reuseIdentifier, for: indexPath)
            as? ListingItemCell else
        {
            fatalError("Unexpected cell, expectected instance of ListingItemCell")
        }
        let listingItem = listingItems[indexPath.item]
        cell.update(listingItem: listingItem, thumbnail: thumbnails[listingItem])
        cell.delegate = self
        loadThumbnails(for: [indexPath])
        
        return cell
    }
    
    //! MARK: - UITableViewDataSourcePrefetching
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths:
        [IndexPath])
    {
        loadThumbnails(for: indexPaths)
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt
        indexPaths: [IndexPath])
    {
        cancelLoadThumbnails(for: indexPaths)
    }
    
    //! MARK: - ListingItemCellDelegate
    func listingItemCellRequestToShowImage(_ sender: ListingItemCell)
    {
        guard let indexPath = tableView.indexPath(for: sender) else { return }
        let listingItem = listingItems[indexPath.row]
        guard let imageInfo = listingItem.imageInfos.first else
        {
            return
        }
        performSegue(with: .showImage, sender: imageInfo)
    }
    
    //! MARK: - Actions
    @IBAction func unwindBack(_ segue: UIStoryboardSegue)
    {     
    }
    
    //! MARK: - Private
    private static func dataSource(from query: ListingQuery, redditAccess:
        RedditAccess) -> DataSource<[ListingItem]>
    {
        return RedditAccessFactory().createDataSource(for: query,
            in: redditAccess)
    }
    
    private func queryDidChange()
    {
        dataSource = type(of: self).dataSource(from: query, redditAccess:
            redditAccess)
        navigationItem.title = query.listing.title
    }
    
    //! MARK: - Image Downloading
    private func loadThumbnails(for indexPaths: [IndexPath])
    {
        let items = indexPaths.map {listingItems[$0.row]}
            .filter {nil == thumbnails[$0] } //! We do not have image already
        for item in items where nil != item.thumbnailInfo
        {
            LogInfo("Start preloading item \(item.id)")
            let url = item.thumbnailInfo!.url
            imageDownloader.loadImage(with: url, identifier: item.id)
            { [weak self] result in
                guard let `self` = self else { return }
                if let image = result.value
                {
                    LogInfo("Finish successfully preloading item \(item.id)")
                    self.thumbnails[item] = image
                    self.didLoadImage(image, for: item)
                }
            }
        }
    }
    
    private func cancelLoadThumbnails(for indexPaths: [IndexPath])
    {
        let items = indexPaths.map {listingItems[$0.row]}
        items.forEach
        { item in
            LogInfo("Cancel preloading item \(item.id)")
            imageDownloader.cancelLoadingImages(with: item.id)
        }
    }
    
    private func didLoadImage(_ image: UIImage, for item: ListingItem)
    {
        guard let visibleIndexPaths = tableView.indexPathsForVisibleRows else
            { return }
        let visibleItems = visibleIndexPaths.map {listingItems[$0.row]}
        guard let index = visibleItems.index(of: item) else { return }
        guard let cell = tableView.cellForRow(at: IndexPath(item: index,
            section: 0)) as? ListingItemCell else { return }
        cell.update(thumbnail: image)
    }
}

////////////////////////////////////////////////////////////////////////////////
extension ListingViewController : StoryboardSegueType
{
    enum SegueType : String
    {
        case showImage //! Sender is ImageInfo
    }
}
