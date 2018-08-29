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
class ListingItemCell : UITableViewCell
{
    //! MARK: - Properties
    static var reuseIdentifier = "ListingItemCell"
    
    /// Delegate
    weak var delegate: ListingItemCellDelegate?
    
    //! MARK: - UI Connections
    @IBOutlet private var stackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private var stackViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var authorNameLabel: UILabel!
    @IBOutlet private var thumbnailContainerView: UIView!
    @IBOutlet private var thumbnailImageView: UIImageView!
    @IBOutlet private var commentsLabel: UILabel!
    @IBOutlet private var relativeDateLabel: UILabel!
    
    //! MARK: - NSObject overrides
    override func awakeFromNib()
    {
        super.awakeFromNib()
        backgroundView = createBackgroundView()
        backgroundColor = .clear
        thumbnailImageView.layer.borderColor = UIColor.lightGray.cgColor
        thumbnailImageView.layer.borderWidth = 0.5
    }
    
    //! MARK: - UIView overrides
    override func layoutSubviews()
    {
        super.layoutSubviews()
        thumbnailImageView.layer.cornerRadius = thumbnailImageView.frame.width / 2
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection:
        UITraitCollection?)
    {
        super.traitCollectionDidChange(previousTraitCollection)
        layoutIfNeeded()
    }
    
    //! MARK: - Update methods
    func update(listingItem: ListingItem, thumbnail: UIImage?)
    {
        titleLabel.text = listingItem.title
        authorNameLabel.text = listingItem.author
        
        let imageInfo = listingItem.thumbnailInfo
        thumbnailImageView.image = thumbnail ?? #imageLiteral(resourceName: "ico_placeholder")
        thumbnailContainerView.isHidden = nil == imageInfo?.url
        commentsLabel.text = listingItem.numberOfComments.abbreviated
        
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
        let contentView = UIView()
        contentView.backgroundColor = .white
        result.addSubview(contentView)
        contentView.frame = result.bounds.insetBy(dx: 0, dy:
            stackViewTopConstraint.constant / 2)
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return result
    }
}
