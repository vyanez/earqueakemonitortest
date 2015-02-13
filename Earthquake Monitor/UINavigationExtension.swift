//
//  UINavigation.swift
//  Earthquake Monitor
//
//  Created by Victor Yanez on 2/13/15.
//  Copyright (c) 2015 scyllas. All rights reserved.
//

import UIKit

extension UINavigationController {
    public override func supportedInterfaceOrientations() -> Int {
        return visibleViewController.supportedInterfaceOrientations()
    }
    public override func shouldAutorotate() -> Bool {
        return visibleViewController.shouldAutorotate()
    }
}

extension UITabBarController {
    public override func supportedInterfaceOrientations() -> Int {
        if let selected = selectedViewController {
            return selected.supportedInterfaceOrientations()
        }
        return super.supportedInterfaceOrientations()
    }
    public override func shouldAutorotate() -> Bool {
        if let selected = selectedViewController {
            return selected.shouldAutorotate()
        }
        return super.shouldAutorotate()
    }
}