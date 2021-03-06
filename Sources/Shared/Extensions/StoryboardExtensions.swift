////////////////////////////////////////////////////////////////////////////////
//
//  StoryboardExtensions.swift
//  TopReddit
//
//  Created by Iurii Khomiak on 8/26/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import UIKit

////////////////////////////////////////////////////////////////////////////////
protocol MainStoryboard
{
    func instantiateTopListingViewController() -> ListingViewController
    func instantiateMainViewController() -> UINavigationController
    func instantiateImageNavigationController() -> UINavigationController
    func instantiateImageViewController() -> ImageViewController
}

////////////////////////////////////////////////////////////////////////////////
extension UIStoryboard
{
    static var main: MainStoryboard & UIStoryboard
    {
        return MainStoryboardImp()
    }
}
