////////////////////////////////////////////////////////////////////////////////
//
//  LoadingView.swift
//  SharedUI
//
//  Created by Iurii Khomiak on 8/26/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import UIKit

////////////////////////////////////////////////////////////////////////////////
/// Base class for loading view, responsible for display loading state.
public class LoadingView : UIView
{
    /// Style enumeration
    public enum Style { case `default`}
    
    /// Loading title
    public var title: String?
    /// Loading message
    public var message: String?
    /// Preferred elements color
    public var color: UIColor?
    
    //! MARK: - Init & Deinit
    public override init(frame: CGRect)
    {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    //! MARK: - Factory method
    static public func instantiate(style: Style) -> LoadingView
    {
        switch style
        {
            case .default:
                return DefaultLoadingView.instantiate()
        }
    }
}
