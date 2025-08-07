//
//  WaveViewController.swift
//  World Wide Wave

//  Created by Ryutarou Nakajima on 2024/11/21.
//


import UIKit
import MapKit
import SwiftUI

class WaveMapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{
    
    var mkMapView: MKMapView!
    var locationManager: CLLocationManager!
    var selectedLocation: CLLocationCoordinate2D?
    var isTransiting = false
    var formData = FormData()
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        mkMapView = MKMapView(frame: self.view.bounds)
        mkMapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(mkMapView)
        
        mkMapView.showsUserLocation = true
        mkMapView.userTrackingMode = .follow
        //location manager setup
        let longPressGesuture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        mkMapView.addGestureRecognizer(longPressGesuture)
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        backToCurrentPositon()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mkMapView.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setNeedsUpdateOfSupportedInterfaceOrientations()
        
        isTransiting = false
        
        if let mapView = self.mkMapView {
            
            for annotation in mapView.annotations {
                mapView.deselectAnnotation(annotation, animated: true)
            }
        }
        
        if let annotaionView = self.view.viewWithTag(100) {
            
            addInfiniteAnimation(to: annotaionView)
        }
        
        
    }
    
    // segue for another page when annotain is tapped
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard let annotation = view.annotation, !(annotation is MKUserLocation) else {return}
        
        if isTransiting {return}
        isTransiting = true
        
        selectedLocation = annotation.coordinate
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            
            navigateToWaveInfoViewController()
            isTransiting = false
        }
        
        
    }
    
    // Add this function to set custom image for annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseIdentifier = "CustomAnnotation"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView?.canShowCallout = true
        }
        
        // Set custom image for annotation
        if let customImage = UIImage(named: "Logo") {
            // Resize image to fit the annotation view
            let resizedImage = resizeImage(image: customImage, to: CGSize(width: 30, height: 30))
            annotationView?.image = resizedImage
            annotationView?.tag = 100
            if let cirlceAnimation = annotationView {
                
                addInfiniteAnimation(to: cirlceAnimation)
            }
            
        }
        
        return annotationView
    }
    
    
    func addInfiniteAnimation(to view: UIView) {
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.toValue = Double.pi * 2
        rotationAnimation.duration = 2.4
        rotationAnimation.repeatCount = .infinity
        view.layer.add(rotationAnimation, forKey: "rotationAnimation")
        
        let blinkAnimation = CABasicAnimation(keyPath: "opacity")
        blinkAnimation.fromValue = 1.0
        blinkAnimation.toValue = 0.0
        blinkAnimation.duration = 1.2
        blinkAnimation.autoreverses = true
        blinkAnimation.repeatCount = .infinity
        view.layer.add(blinkAnimation, forKey: "blinkAnimation")
    }
    
       func resizeImage(image: UIImage, to size: CGSize) -> UIImage {
           
           let rect = CGRect(origin: .zero, size: size)
           
           UIGraphicsBeginImageContextWithOptions(size, false, 2.0)
         
           
           image.draw(in: rect)
           
           var resizedImage = UIGraphicsGetImageFromCurrentImageContext()
          
           if let img = resizedImage {
               
               let diameter = min(size.width, size.height)
               let radius = diameter / 2
               let circleRect = CGRect(x: (size.width - diameter) / 2, y: (size.height - diameter) / 2, width: diameter, height: diameter)
               
               UIGraphicsBeginImageContextWithOptions(size, false, 2.0)
               let path = UIBezierPath(roundedRect: circleRect, cornerRadius: radius)
               path.addClip()
               
               img.draw(in: circleRect)
               
               resizedImage = UIGraphicsGetImageFromCurrentImageContext()
               UIGraphicsEndImageContext()
               
           }
           return resizedImage ?? image
       }
    
       func navigateToWaveInfoViewController() {
        
        let waveInfoVC = WaveInfoViewContrroler()
        waveInfoVC.coordinate = selectedLocation!
           waveInfoVC.timestamp = Date()
           
           waveInfoVC.formData = self.formData
           waveInfoVC.formData?.coordinate = selectedLocation!
           waveInfoVC.formData?.timestamp = Date()
           waveInfoVC.hidesBottomBarWhenPushed = true
           
        navigationController?.pushViewController(waveInfoVC, animated: true)
       
    }
    
       func backToCurrentPositon() {
        
        let resetButton = UIButton(frame: CGRect(x: self.view.bounds.width - 60, y: view.bounds.height - 110, width: 50, height: 50))
        resetButton.backgroundColor = UIColor.orange.withAlphaComponent(0.5)
        resetButton.layer.cornerRadius = 25
        resetButton.clipsToBounds = true
        resetButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
           resetButton.tintColor = UIColor.secondarySystemBackground
        resetButton.addTarget(self, action: #selector(resetToUserLocation), for: .touchUpInside)
               
                self.view.addSubview(resetButton)
    }
      
       func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
         
        print("failed to get location: \(error.localizedDescription)")
        
    }

    @objc func resetToUserLocation() {
          // shouldCenterOnUserLocation = true
           if let location = locationManager.location {
               let coordinate = location.coordinate
               let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
               mkMapView.setRegion(region, animated: true)
           }
       }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        
        if gestureRecognizer.state == .began {
            
            let touchPoint = gestureRecognizer.location(in: mkMapView)
                    let coordinate = mkMapView.convert(touchPoint, toCoordinateFrom: mkMapView)

                    
                    mkMapView.removeAnnotations(mkMapView.annotations)

                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    mkMapView.addAnnotation(annotation)

                    selectedLocation = coordinate
            
                    
            let newFormData = FormData()
            newFormData.coordinate = coordinate
            newFormData.timestamp = Date()
            self.formData = newFormData
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.navigateToWaveInfoViewController()
                    }
                
            
        }
    }
    
    
    
    
   
}


