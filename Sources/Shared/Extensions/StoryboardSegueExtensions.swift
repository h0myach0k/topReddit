////////////////////////////////////////////////////////////////////////////////
//
//  StoryboardSegueExtensions.swift
//  TopReddit
//
//  Created by Iurii Khomiak on 8/29/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import UIKit

////////////////////////////////////////////////////////////////////////////////
public extension UIStoryboardSegue
{
    public func destination<T>() -> T
    {
        if let destination = destination as? T
        {
            return destination
        }
        else if let navigation = destination as? UINavigationController,
            let controller = navigation.viewControllers.first as? T
        {
            return controller
        }
        else
        {
            fatalError("Wrong controller for this segue")
        }
    }
}
