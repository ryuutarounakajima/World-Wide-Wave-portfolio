//
//  WaveInfoViewController.swift
//  World Wide Wave
//
//  Created by Ryutarou Nakajima on 2024/12/01.
//

import Foundation
import UIKit
import CoreLocation
import SwiftUI

class WaveInfoViewContrroler: UIViewController {
    
    var coordinate: CLLocationCoordinate2D?
    var timestamp: Date?
    var formData: FormData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let coordinate = coordinate, let timestamp = timestamp else {return}
        
        let swiftUIView = WaveInfoSwiftUIView( coordinate: coordinate, timestamp: timestamp).environmentObject(formData!)
        let hostingController = UIHostingController(rootView: swiftUIView)
        
        addChild(hostingController)
        hostingController.view.frame = view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
    }
    
    override var shouldAutorotate: Bool{
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .landscapeLeft, .landscapeRight]
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
}
