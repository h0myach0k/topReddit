////////////////////////////////////////////////////////////////////////////////
//
//  BundleExtensions.swift
//  SharedUI
//
//  Created by Iurii Khomiak on 8/26/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
extension Bundle
{
    static var sharedUI = Bundle(for: LoadingView.self)
}
