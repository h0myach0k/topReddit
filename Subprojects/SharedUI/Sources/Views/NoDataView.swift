////////////////////////////////////////////////////////////////////////////////
//
//  NoDataView.swift
//  SharedUI
//
//  Created by Iurii Khomiak on 8/26/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
/// Base class for no data view, responsible for displatying no data condition
public class NoDataView : UIView
{
    /// Style enumeration
    public enum Style { case `default`}
    
    /// No data message
    public var message: String?
    
    /// MARK: - Init & Deinit
    public override init(frame: CGRect)
    {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    /// MARK: - Factory method
    static public func instantiate(style: Style) -> NoDataView
    {
        switch style
        {
            case .default:
                return DefaultNoDataView.instantiate()
        }
    }
}
