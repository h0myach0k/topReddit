////////////////////////////////////////////////////////////////////////////////
//
//  ListingViewController.swift
//  TopReddit
//
//  Created by Iurii Khomiak on 8/26/18.
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
class ListingViewController: TableDataSourceViewController<ListingDataSource>,
    UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching,
    ListingItemCellDelegate, UIDataSourceModelAssociation
{
    /// Listing query assotiated with the controller
    private var query: ListingQuery!
    /// Image downloader
    private var imageDownloader: ImageDownloader!
    /// Container
    private var container: DependencyContainer!
    
    /// Loaded listing items
    var listingItems: [ListingItem] { return value ?? [] }
    private var thumbnails: [ListingItem : UIImage] = [:]
    
    //! MARK: Configure from storyboard
    /// Configures view controller with essential data after load from storyboard
    ///
    /// - Parameters:
    ///   - query: Listing query assotiated with the controller
    ///   - container: Dependency container
    func configureFromStoryboard(query: ListingQuery, container:
        DependencyContainer)
    {
        self.query = query
        self.container = container
        self.imageDownloader = try! container.resolve(ImageDownloader.self)
        commonInit()
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
                controller.configureFromStoryboard(imageInfo: sender,
                    container: container)
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with
        coordinator: UIViewControllerTransitionCoordinator)
    {
        super.willTransition(to: newCollection, with: coordinator)
        guard isViewLoaded else { return }
        coordinator.animate(alongsideTransition:
        { (context) in
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }, completion: nil)
    }
    
    //! MARK: DataSourceViewController overrides
    override func dataSourceDecoder() -> Decoder
    {
        //! Since our data source intializes with dependency container,
        //! default decoder is overriden with injection of dependency container
        let result = super.dataSourceDecoder()
        result.dependencyContainer = AppDependencies.shared.container
        return result
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
    
    //! MARK: - UIDataSourceModelAssotiation
    func modelIdentifierForElement(at idx: IndexPath, in view: UIView) -> String?
    {
        return listingItems[idx.row].id
    }
    
    func indexPathForElement(withModelIdentifier identifier: String, in
        view: UIView) -> IndexPath?
    {
        guard let (index, _) = listingItems.enumerated()
            .filter({$0.element.id == identifier}).first else { return nil }
        return IndexPath(row: index, section: 0)
    }
    
    //! MARK: - Actions
    @IBAction func unwindBack(_ segue: UIStoryboardSegue)
    {     
    }
    
    //! MARK: - Private
    private func commonInit()
    {
        dataSource = ListingDataSource(query: query, container: container)
        navigationItem.title = query.listing.title
    }
    
    //! MARK: - Image Downloading
    private func loadThumbnails(for indexPaths: [IndexPath])
    {
        LogInfo("Requested to preloading items for indexPaths \(indexPaths)")
        let items = indexPaths.map {listingItems[$0.row]}
            .filter {nil == thumbnails[$0] } //! We do not have image already
        for item in items where nil != item.thumbnailInfo
        {
            LogInfo("Start preloading item \(item.id) indexPath \(indexPaths)")
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
        guard let index = listingItems.index(of: item) else { return }
        let indexPath = IndexPath(item: index, section: 0)
        guard visibleIndexPaths.contains(indexPath) else { return }
        guard let cell = tableView.cellForRow(at: IndexPath(item: index,
            section: 0)) as? ListingItemCell else { return }
        cell.update(thumbnail: image)
    }
}

////////////////////////////////////////////////////////////////////////////////
//! MARK: - As StoryboardSegueType
extension ListingViewController : StoryboardSegueType
{
    enum SegueType : String
    {
        case showImage //! Sender is ImageInfo
    }
}
