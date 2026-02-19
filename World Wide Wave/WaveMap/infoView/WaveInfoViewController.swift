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
        
        // ✅ 子VC登録
              addChild(hostingController)
              view.addSubview(hostingController.view)
              
              // ✅ AutoLayout使用
              hostingController.view.translatesAutoresizingMaskIntoConstraints = false
              
              NSLayoutConstraint.activate([
                  hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
                  hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                  hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                  hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
              ])
              
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
