////////////////////////////////////////////////////////////////////////////////
//
//  DefaultErrorView.swift
//  SharedUI
//
//  Created by Iurii Khomiak on 8/26/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
class DefaultErrorView : ErrorView
{
    //! MARK: Properties
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var actionButton: UIButton!
    @IBOutlet private weak var imageView: UIImageView!
    
    //! MARK: Overriden properties
    override var title: String?
    {
        didSet
        {
            titleLabel.text = title
        }
    }
    
    override var message: String?
    {
        didSet
        {
            messageLabel.text = message
        }
    }
    
    override var action: String?
    {
        didSet
        {
            actionButton.setTitle(action, for: .normal)
        }
    }
    
    override var icon: UIImage?
    {
        didSet
        {
            imageView.image = icon
        }
    }
    
    //! MARK: Instantiate
    static func instantiate() -> DefaultErrorView
    {
        let nib = UINib(nibName: String(describing: DefaultErrorView.self),
            bundle: .sharedUI)
        return nib.instantiate(withOwner: self, options: nil).first as!
            DefaultErrorView
    }
    
    //! MARK: Actions
    @IBAction private func retryAction(_ sender: Any)
    {
        delegate?.errorViewRequestToRetry?(self)
    }
}
