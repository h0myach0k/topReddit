////////////////////////////////////////////////////////////////////////////////
//
//  DefaultLoadingView.swift
//  SharedUI
//
//  Created by Iurii Khomiak on 8/26/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
class DefaultLoadingView : LoadingView
{
    //! MARK: Properties
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    
    //! MARK: Overriden properties
    override var message: String?
    {
        didSet
        {
            messageLabel.text = message
        }
    }
    
    override var title: String?
    {
        didSet
        {
            titleLabel.text = title
        }
    }
    
    //! MARK: - NSObject overrides
    public override func awakeFromNib()
    {
        super.awakeFromNib()
        titleLabel.text = title
        messageLabel.text = message
    }
    
    //! MARK: Instantiate
    static func instantiate() -> DefaultLoadingView
    {
        let nib = UINib(nibName: String(describing: DefaultLoadingView.self),
            bundle: .sharedUI)
        return nib.instantiate(withOwner: self, options: nil).first as!
            DefaultLoadingView
    }    
}
