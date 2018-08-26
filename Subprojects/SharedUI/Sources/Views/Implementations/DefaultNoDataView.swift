////////////////////////////////////////////////////////////////////////////////
//
//  DefaultNoDataView.swift
//  SharedUI
//
//  Created by Iurii Khomiak on 8/26/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
class DefaultNoDataView : NoDataView
{
    //! MARK: Properties
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var messageLabel: UILabel!
    
    //! MARK: Overriden properties
    override var message: String?
    {
        didSet
        {
            messageLabel.text = message
        }
    }
    
    //! MARK: Instantiate
    static func instantiate() -> DefaultNoDataView
    {
        let nib = UINib(nibName: String(describing: DefaultNoDataView.self),
            bundle: .sharedUI)
        return nib.instantiate(withOwner: self, options: nil).first as!
            DefaultNoDataView
    }
}
