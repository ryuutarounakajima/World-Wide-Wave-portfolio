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

class waveInfoViewController: UIViewController {
    
    var coordinate: CLLocationCoordinate2D?
    var timestamp: Date?
    var formData: FormData?
    
    override var shouldAutorotate: Bool{
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .landscapeRight, .landscapeLeft]
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //test
        let safeCoordinate  =  coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let safeTimeStamp = timestamp ?? Date()
        let formDataToUse = formData ?? FormData()
        
        //production
       /* guard let coordinate = coordinate, let timestamp = timestamp else {return}
        */
        
        let swiftUIView = WaveInfoSwiftUIView( coordinate: safeCoordinate, timestamp: safeTimeStamp)
            .environmentObject(formDataToUse)
            .modelContainer(ModelContainerProvider.shared)
        let hostingController = UIHostingController(rootView: swiftUIView)
        
        addChild(hostingController)
        hostingController.view.frame = view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // navigation bar を非表示にする
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 元の画面に戻るときは再表示
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
}
