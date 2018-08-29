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
class ListingViewController: CollectionDataSourceViewController<ListingDataSource>,
    UICollectionViewDelegate, UICollectionViewDataSource,
    UICollectionViewDataSourcePrefetching, ListingItemCellDelegate,
    UIDataSourceModelAssociation, UICollectionViewDelegateFlowLayout
{
    /// Image downloader
    private var imageDownloader: ImageDownloader!
    /// Container
    private var container: DependencyContainer!
    
    /// Loaded listing items
    var listingItems: [ListingItem] { return value ?? [] }
    /// Map for loaded images
    private var thumbnails: [ListingItem : UIImage] = [:]
    /// Returns collection view layout
    private var layout: UICollectionViewFlowLayout { return collectionView
        .collectionViewLayout as! UICollectionViewFlowLayout }
    
    //! MARK: Configure from storyboard
    /// Configures view controller with essential data after load from storyboard
    ///
    /// - Parameters:
    ///   - query: Listing query assotiated with the controller
    ///   - container: Dependency container
    func configureFromStoryboard(query: ListingQuery, container:
        DependencyContainer)
    {
        self.container = container
        self.imageDownloader = try! container.resolve(ImageDownloader.self)
        dataSource = ListingDataSource(query: query, container: container)
        navigationItem.title = query.listing.title
    }
        
    //! MARK: - UIViewController overrides
    override func viewDidLoad()
    {
        super.viewDidLoad()
        collectionView.register(ListingItemCell.nib(),
            forCellWithReuseIdentifier: ListingItemCell.reuseIdentifier)
    }
    
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
                let controller: ImageViewController = segue.destination()
                controller.configureFromStoryboard(imageInfo: sender,
                    container: container)                
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with
        coordinator: UIViewControllerTransitionCoordinator)
    {
        super.willTransition(to: newCollection, with: coordinator)
        guard isViewLoaded else { return }
        collectionView.collectionViewLayout.invalidateLayout()
        coordinator.animate(alongsideTransition: { (context) in
            self.collectionView.layoutIfNeeded()
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
    
    override func reloadData(changeRequest: DataSourceChangeRequest<
        [ListingItem]>, completion: @escaping () -> Void)
    {
        let map = {(index: Int) -> IndexPath in return IndexPath(item: index,
            section: 0)}
        let insertedIndexPaths = changeRequest.insertedIndexes.map(map)
        let deletedIndexPaths = changeRequest.deletedIndexes.map(map)
        let updatedIndexPaths = changeRequest.updatedIndexes.map(map)

        guard !insertedIndexPaths.isEmpty || !deletedIndexPaths.isEmpty ||
            updatedIndexPaths.isEmpty else
        {
            super.reloadData(changeRequest: changeRequest, completion: completion)
            return
        }

        collectionView.performBatchUpdates(
        {
            collectionView.insertItems(at: insertedIndexPaths)
            collectionView.deleteItems(at: deletedIndexPaths)
            collectionView.reloadItems(at: updatedIndexPaths)
        },
        completion:
        { _ in
            completion()
        })
    }
    
    //! MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection
        section: Int) -> Int
    {
        return listingItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt
        indexPath: IndexPath) -> UICollectionViewCell
    {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:
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
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath:
        IndexPath) -> CGSize
    {
        let listingItem = listingItems[indexPath.row]
        let width = collectionView.frame.width - layout.sectionInset.left -
            layout.sectionInset.right

        let height = ListingItemCell.height(with: listingItem, width: width,
            layoutMargins: collectionView.layoutMargins)
        return CGSize(width: width, height: height)
    }
    
    //! MARK: - UITableViewDataSourcePrefetching
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt
        indexPaths: [IndexPath])
    {
        loadThumbnails(for: indexPaths)
    }

    func collectionView(_ collectionView: UICollectionView,
        cancelPrefetchingForItemsAt indexPaths: [IndexPath])
    {
        cancelLoadThumbnails(for: indexPaths)
    }
    
    //! MARK: - ListingItemCellDelegate
    func listingItemCellRequestToShowImage(_ sender: ListingItemCell)
    {
        guard let indexPath = collectionView.indexPath(for: sender) else { return }
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
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        guard let index = listingItems.index(of: item) else { return }
        let indexPath = IndexPath(item: index, section: 0)
        guard visibleIndexPaths.contains(indexPath) else { return }
        guard let cell = collectionView.cellForItem(at: IndexPath(item: index,
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
