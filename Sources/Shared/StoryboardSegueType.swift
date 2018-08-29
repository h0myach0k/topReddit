////////////////////////////////////////////////////////////////////////////////
//
//  StoryboardSegueType.swift
//  TopReddit
//
//  Created by Iurii Khomiak on 8/27/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import UIKit

////////////////////////////////////////////////////////////////////////////////
protocol StoryboardSegueType
{
    associatedtype SegueType : RawRepresentable
}

////////////////////////////////////////////////////////////////////////////////
extension StoryboardSegueType where Self : UIViewController,
    SegueType.RawValue == String
{
    func performSegue(with type: SegueType, sender: Any?)
    {
        performSegue(withIdentifier: type.rawValue, sender: sender)
    }
    
    func segueType(from identifier: String?) -> SegueType?
    {
        guard let identifier = identifier else { return nil }
        return SegueType(rawValue: identifier)
    }
}
