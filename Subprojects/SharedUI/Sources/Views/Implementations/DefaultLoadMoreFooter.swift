////////////////////////////////////////////////////////////////////////////////
//
//  DefaultLoadMoreFooter.swift
//  SharedUI
//
//  Created by Iurii Khomiak on 8/26/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
class DefaultLoadMoreFooter : LoadMoreFooter
{
    //! MARK: Properties
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    //! MARK: Overriden properties
    override var state: LoadMoreFooter.State
    {
        didSet
        {
            switch state
            {
                case .opened:
                    startAnimating()
                case .hidden:
                    stopAnimating()
            }
        }
    }
    
    //! MARK: - Private
    private func startAnimating()
    {
        activityIndicator.startAnimating()
    }
    
    private func stopAnimating()
    {
        activityIndicator.stopAnimating()
    }

    //! MARK: Instantiate
    static func instantiate() -> DefaultLoadMoreFooter
    {
        let nib = UINib(nibName: String(describing: DefaultLoadMoreFooter.self),
            bundle: .sharedUI)
        return nib.instantiate(withOwner: self, options: nil).first as!
            DefaultLoadMoreFooter
    }
}
