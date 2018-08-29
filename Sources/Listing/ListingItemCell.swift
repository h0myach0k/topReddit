////////////////////////////////////////////////////////////////////////////////
//
//  ListingItemCell.swift
//  TopReddit
//
//  Created by Iurii Khomiak on 8/26/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import UIKit
import RedditAccess

////////////////////////////////////////////////////////////////////////////////
protocol ListingItemCellDelegate: class
{
    func listingItemCellRequestToShowImage(_ sender: ListingItemCell)
}

////////////////////////////////////////////////////////////////////////////////
/// Cell for displaying ListingItem instances in collection view
class ListingItemCell : UICollectionViewCell
{
    //! MARK: - Properties & Constanst
    static var reuseIdentifier = "ListingItemCell"
    private let thumbnailBorderColor: UIColor = .lightGray
    fileprivate static var sizingParameters: SizingParameters!
    
    /// Delegate
    weak var delegate: ListingItemCellDelegate?
    
    //! MARK: - UI Connections
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var authorNameLabel: UILabel!
    @IBOutlet private var thumbnailContainerView: UIView!
    @IBOutlet private var thumbnailImageView: UIImageView!
    @IBOutlet private var commentsLabel: UILabel!
    @IBOutlet private var relativeDateLabel: UILabel!
    @IBOutlet private var infoContainerStackView: UIStackView!
    @IBOutlet private var contentStackView: UIStackView!
    
    //! MARK: - Nib
    static func nib() -> UINib
    {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }
    
    //! MARK: - NSObject overrides
    override func awakeFromNib()
    {
        super.awakeFromNib()
        backgroundView = createBackgroundView()
        thumbnailImageView.layer.borderColor = thumbnailBorderColor.cgColor
    }
    
    //! MARK: - Update methods
    /// Updates cell with required listing item
    ///
    /// - Parameters:
    ///   - listingItem: Listing Item instance
    ///   - thumbnail: Image instance if available
    func update(listingItem: ListingItem, thumbnail: UIImage?)
    {
        updateTitle(listingItem: listingItem)
        updateAuthor(listingItem: listingItem)
        updateThumbnail(listingItem: listingItem)
        update(thumbnail: thumbnail ?? #imageLiteral(resourceName: "ico_placeholder"), animated: false)
        updateNumberOfComments(listingItem: listingItem)
        updateRelativeDate(listingItem: listingItem)
    }
    
    func update(thumbnail: UIImage, animated: Bool)
    {
        let animations = { self.thumbnailImageView.image = thumbnail }
        if animated
        {
            UIView.transition(with: self,
                duration: 0.3, options: .transitionCrossDissolve,
                animations: animations, completion: nil)
        }
        else
        {
            animations()
        }
    }
    
    //! MARK: - Actions
    @IBAction private func showImage(_ sender: Any)
    {
        delegate?.listingItemCellRequestToShowImage(self)
    }
    
    //! MARK: - Private
    private func updateTitle(listingItem: ListingItem)
    {
        titleLabel.text = listingItem.title
    }
    
    private func updateAuthor(listingItem: ListingItem)
    {
        authorNameLabel.text = listingItem.author
    }
    
    private func updateThumbnail(listingItem: ListingItem)
    {
        let imageInfo = listingItem.imageInfos.first
        thumbnailContainerView.isHidden = nil == imageInfo?.url
    }
    
    private func updateNumberOfComments(listingItem: ListingItem)
    {
        let suffix = String.localizedStringWithFormat(
            "ListingCellCommentSuffix".localized,
            listingItem.numberOfComments)
        commentsLabel.text = listingItem.numberOfComments.abbreviated + " " +
            suffix
    }
    
    private func updateRelativeDate(listingItem: ListingItem)
    {
        let formatter = RelativeTimeFormatter()
        formatter.beforeSuffix = "ago".localized
        relativeDateLabel.text = formatter.string(from: listingItem.createdDate)
    }
    
    private func createBackgroundView() -> UIView
    {
        let result = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        result.backgroundColor = .white
        return result
    }
}

////////////////////////////////////////////////////////////////////////////////
//! MARK: - Height Calculation
extension ListingItemCell
{
    fileprivate struct SizingParameters
    {
        let authorLabelFont: UIFont
        let titleFont: UIFont
        let commentsFont: UIFont
        let relativeDateFont: UIFont
        let titleToInfoContainerSpacing: CGFloat
        let infoContainerSpacing: CGFloat
        let topSpacing: CGFloat
        let bottomSpacing: CGFloat
    }
    
    static func height(with listingItem: ListingItem, width: CGFloat,
        layoutMargins: UIEdgeInsets) -> CGFloat
    {
        configureSizingParametersIfNeeded()
        
        let authorHeight = labelHeight(font: sizingParameters.authorLabelFont,
            text: " ", width: width)
        let commentsHeight = labelHeight(font: sizingParameters.commentsFont,
            text: " ", width: width)
        let relativeHeight = labelHeight(font: sizingParameters.relativeDateFont,
            text: " ", width: width)
        let titleHeight = labelHeight(font: sizingParameters.titleFont,
            text: listingItem.title, width: width - layoutMargins.left -
            layoutMargins.right)
        
        return sizingParameters.topSpacing + authorHeight + relativeHeight +
            commentsHeight + 2 * sizingParameters.infoContainerSpacing +
            sizingParameters.titleToInfoContainerSpacing +
            titleHeight + sizingParameters.bottomSpacing
    }
    
    static private func labelHeight(font: UIFont, text: String, width: CGFloat)
        -> CGFloat
    {
        let boundingSize = CGSize(width: width, height: 0)
        let attributedString = NSAttributedString(string: text,
            attributes: [.font : font])
        let boundingRect = attributedString.boundingRect(with: boundingSize,
            options: .usesLineFragmentOrigin, context: nil)
        return ceil(boundingRect.height)
    }
    
    private static func configureSizingParametersIfNeeded()
    {
        guard nil == sizingParameters else { return }
        let templateCell = nib().instantiate(withOwner: self, options: nil)
            .first as! ListingItemCell
        
        self.sizingParameters = SizingParameters(
            authorLabelFont: templateCell.authorNameLabel.font,
            titleFont: templateCell.titleLabel.font,
            commentsFont: templateCell.commentsLabel.font,
            relativeDateFont: templateCell.relativeDateLabel.font,
            titleToInfoContainerSpacing: templateCell.contentStackView.spacing,
            infoContainerSpacing: templateCell.infoContainerStackView.spacing,
            topSpacing: templateCell.contentStackView.frame.minY,
            bottomSpacing: templateCell.frame.maxY -
                templateCell.contentStackView.frame.maxY)
    }
}
