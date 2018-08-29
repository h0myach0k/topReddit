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
        case listing
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
    
    func instantiateListingViewController() -> ListingViewController
    {
        return self.instantiateViewController(withIdentifier: Identifier
            .listing.rawValue) as! ListingViewController
    }
}
