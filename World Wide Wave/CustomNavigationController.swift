//
//  CustomNavigationController.swift
//  World Wide Wave
//
//  Created by Ryutarou Nakajima on 2025/08/07.
//

import Foundation
import UIKit

class CustomNavigationController: UINavigationController {
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
       
        return topViewController?.supportedInterfaceOrientations ?? .all
    }
    
   override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        
       return topViewController?.preferredInterfaceOrientationForPresentation ?? .portrait
    }
}
