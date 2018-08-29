////////////////////////////////////////////////////////////////////////////////
//
//  MainStoryboardImp.swift
//  TopReddit
//
//  Created by Iurii Khomiak on 8/26/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import UIKit

////////////////////////////////////////////////////////////////////////////////
class MainStoryboardImp : UIStoryboard, MainStoryboard
{
    private static var name = "Main"
    private let storyboard: UIStoryboard
    
    enum Identifier : String
    {
        case rootNavigation
        case topListing
        case imageNavigation
        case image
    }
    
    override public init()
    {
        storyboard = UIStoryboard(name: type(of: self).name, bundle: nil)
        super.init()
    }
    
    override func instantiateInitialViewController() -> UIViewController?
    {
        return storyboard.instantiateInitialViewController()
    }
    
    override func instantiateViewController(withIdentifier identifier: String)
        -> UIViewController
    {
        return storyboard.instantiateViewController(withIdentifier: identifier)
    }
    
    func instantiateTopListingViewController() -> ListingViewController
    {
        return instantiateViewController(withIdentifier: .topListing)
    }
    
    func instantiateMainViewController() -> UINavigationController
    {
        return instantiateViewController(withIdentifier: .rootNavigation)
    }
    
    func instantiateImageNavigationController() -> UINavigationController
    {
        return instantiateViewController(withIdentifier: .imageNavigation)
    }
    
    func instantiateImageViewController() -> ImageViewController
    {
        return instantiateViewController(withIdentifier: .image)
    }
    
    //! MARK: - Private
    private func instantiateViewController<T>(withIdentifier identifier:
        Identifier) -> T
    {
        return self.instantiateViewController(withIdentifier: identifier
            .rawValue) as! T
    }
}
