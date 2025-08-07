//
//  tabBarController.swift
//  World Wide Wave
//
//  Created by Ryutarou Nakajima on 2025/08/07.
//

import Foundation
import UIKit

class CustomTabBarController: UITabBarController {
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return selectedViewController?.supportedInterfaceOrientations ?? .all
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return selectedViewController?.preferredInterfaceOrientationForPresentation ?? .portrait
    }
   
}


