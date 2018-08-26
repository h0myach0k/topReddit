////////////////////////////////////////////////////////////////////////////////
//
//  ListingItemCell.swift
//  TopReddit
//
//  Created by h0myach0k on 8/26/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import UIKit
import RedditAccess

////////////////////////////////////////////////////////////////////////////////
class ListingItemCell : UITableViewCell
{
    //! MARK: - Properties
    static var reuseIdentifier = "ListingItemCell"
    
    //! MARK: - UI Connections
    @IBOutlet private var stackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private var stackViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var authorNameLabel: UILabel!
    @IBOutlet private var thumbnailContainerView: UIView!
    @IBOutlet private var thumbnailImageView: ImageView!
    @IBOutlet private var commentsLabel: UILabel!
    
    //! MARK: - Init & Deinit
    deinit
    {
        thumbnailImageView.cancel()
    }
    
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
    
    //! MARK: - UITableViewCell overrides
    override func prepareForReuse()
    {
        super.prepareForReuse()
        thumbnailImageView.cancel()
    }
    
    //! MARK: - Update methods
    func update(listingItem: ListingItem)
    {
        titleLabel.text = listingItem.title
        authorNameLabel.text = listingItem.author
        
        let imageInfo = listingItem.thumbnailInfo
        thumbnailImageView.setImage(withUrl: imageInfo?.url, placeholder: #imageLiteral(resourceName: "ico_placeholder"))
        thumbnailContainerView.isHidden = nil == imageInfo?.url
        
        commentsLabel.text = listingItem.numberOfComments.abbreviated
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
