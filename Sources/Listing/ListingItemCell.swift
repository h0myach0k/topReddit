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
class ListingItemCell : UICollectionViewCell
{
    //! MARK: - Properties
    static var reuseIdentifier = "ListingItemCell"
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
    
    //! MARK: - NSObject overrides
    override func awakeFromNib()
    {
        super.awakeFromNib()
        backgroundView = createBackgroundView()
        thumbnailImageView.layer.borderColor = UIColor.lightGray.cgColor
        thumbnailImageView.layer.borderWidth = 0.5
        thumbnailImageView.layer.cornerRadius = 3
    }
    
    //! MARK: - Update methods
    func update(listingItem: ListingItem, thumbnail: UIImage?)
    {
        titleLabel.text = listingItem.title
        authorNameLabel.text = listingItem.author
        
        let imageInfo = listingItem.thumbnailInfo
        thumbnailImageView.image = thumbnail ?? #imageLiteral(resourceName: "ico_placeholder")
        thumbnailContainerView.isHidden = nil == imageInfo?.url
        let suffix = String.localizedStringWithFormat(
            "ListingCellCommentSuffix".localized,
            listingItem.numberOfComments)
        commentsLabel.text = listingItem.numberOfComments.abbreviated + " " +
            suffix
        
        let formatter = RelativeTimeFormatter()
        formatter.beforeSuffix = "ago".localized
        relativeDateLabel.text = formatter.string(from: listingItem.createdDate)
    }
    
    func update(thumbnail: UIImage)
    {
        UIView.transition(with: self,
            duration: 0.3, options: .transitionCrossDissolve,
            animations:
            {
                self.thumbnailImageView.image = thumbnail
            }, completion: nil)
    }
    
    //! MARK: - Actions
    @IBAction private func showImage(_ sender: Any)
    {
        delegate?.listingItemCellRequestToShowImage(self)
    }
    
    //! MARK: - Private
    private func createBackgroundView() -> UIView
    {
        let result = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        result.backgroundColor = .white
        return result
    }
    
    static func nib() -> UINib
    {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }
}

////////////////////////////////////////////////////////////////////////////////
//! MARK: - Height Calculation
extension ListingItemCell
{
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
