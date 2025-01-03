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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        guard let coordinate = coordinate, let timestamp = timestamp else {return}
        
        let swiftUIView = WaveInfoSwiftUIView(formData: FormData(), coordinate: coordinate, timestamp: timestamp)
        let hostingController = UIHostingController(rootView: swiftUIView)
        
        addChild(hostingController)
        hostingController.view.frame = view.bounds
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
    }
    
   
}
