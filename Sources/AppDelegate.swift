////////////////////////////////////////////////////////////////////////////////
//
//  AppDelegate.swift
//  TopReddit
//
//  Created by Iurii Khomiak on 8/22/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import UIKit
import Core

////////////////////////////////////////////////////////////////////////////////
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions
    	launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        LoggerManager.shared.logLevel = .info
        return true
    }
    
    func application(_ application: UIApplication, shouldSaveApplicationState
        coder: NSCoder) -> Bool
    {
        return true
    }
    
    func application(_ application: UIApplication, shouldRestoreApplicationState
        coder: NSCoder) -> Bool
    {
        return true
    }
}
