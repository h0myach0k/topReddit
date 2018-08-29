////////////////////////////////////////////////////////////////////////////////
//
//  ErrorView.swift
//  SharedUI
//
//  Created by Iurii Khomiak on 8/26/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
@objc public protocol ErrorViewDelegate: class
{
    @objc optional func errorViewRequestToRetry(_ sender: UIView)
}

////////////////////////////////////////////////////////////////////////////////
/// Base class for error view, responsible for displatying error conditions
public class ErrorView : UIView
{
    /// Style enumeration
    public enum Style { case `default`}
    
    /// No data message
    public var title: String?
    public var message: String?
    public var action: String?
    public var icon: UIImage?
    public var color: UIColor?
    public weak var delegate: ErrorViewDelegate?
    
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
    static public func instantiate(style: Style) -> ErrorView
    {
        switch style
        {
            case .default:
                return DefaultErrorView.instantiate()
        }
    }
}
