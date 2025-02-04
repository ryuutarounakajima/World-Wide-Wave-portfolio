//
//  CameraManager.swift
//  World Wide Wave
//
//  Created by Ryutarou Nakajima on 2024/12/30.
//

import SwiftUI
import AVFoundation

actor CameraManager {
    func requestCameraAccess() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .video)
        default:
            return false
        }
    }
}

/*actor PhotoCaptureManager {
    private(set) var captureImage: UIImage? = nil
    
    func savePhoto(_ image: UIImage)  {
        self.captureImage = image
    }
}*/

struct CameraPreviewView: UIViewControllerRepresentable {
  
    @Binding var captureImage: UIImage?
    @Binding var isCameraPresented: Bool
    
    class Coordinator: NSObject , AVCapturePhotoCaptureDelegate {
        var parent: CameraPreviewView
        
        init(parent: CameraPreviewView) {
            self.parent = parent
        }
        
        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
            
            guard let photoData = photo.fileDataRepresentation(), let image = UIImage(data: photoData) else {
                print("Failed to convert photo")
                return }
            
            DispatchQueue.main.async {
                self.parent.captureImage = image
            }
            
            DispatchQueue.main.async {
                self.parent.isCameraPresented = false
            }
            
            
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = CameraPreviewController()
    
        
        controller.onPhotoCaptured = { image in
            DispatchQueue.main.async {
                self.captureImage = image
            }
        }
        
        controller.onCameraDismissed = {
            DispatchQueue.main.async {
                self.isCameraPresented = false
            }
        }
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    /*
     func dismantleUIViewController(_ uiViewController: CameraPreviewController, context: Context) {
        DispatchQueue.global(qos: .background).async {
            if uiViewController.session.isRunning {
                uiViewController.session.stopRunning()
                print("seesion stopped")
            }
            
        }
    }
     */
}

class CameraPreviewController: UIViewController, AVCapturePhotoCaptureDelegate {
    public let session = AVCaptureSession()
    private let videoPreviewLayer = AVCaptureVideoPreviewLayer()
    private let photoOutPut = AVCapturePhotoOutput()
    //private var photoCaptureManager: PhotoCaptureManager?
    var onPhotoCaptured: ((UIImage) -> Void)?
    var onCameraDismissed: (() -> Void)?
    
    private var currentZoomFactor: CGFloat = 1.0
    private let minZoomFactor: CGFloat = 1.0
    private var maxZoomFactor: CGFloat = 1.0
    
    private var captureButton: UIButton!
    private var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCameraSession()
        setupPreviewLayer()
        setupCaptureButton()
        setupZoomGesture()
        configureRotationHandling()
        setupBackButton()
    }
    
    private func setupCameraSession() {
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else {
            print("failed to load camera")
            return
        }
        maxZoomFactor = device.activeFormat.videoMaxZoomFactor
        session.addInput(input)
        
        if session.canAddOutput(photoOutPut){
            session.addOutput(photoOutPut)
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }
    
    private func setupPreviewLayer() {
        videoPreviewLayer.session = session
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.frame = view.bounds
        view.layer.addSublayer(videoPreviewLayer)
    }
  

}

extension CameraPreviewController {
    
    //Photo capture
     private func setupCaptureButton() {
         captureButton = UIButton(type: .system)
         captureButton.setTitle("", for: .normal)
         captureButton.backgroundColor = UIColor.white.withAlphaComponent(0.9)
         
         let buttonSize: CGFloat = 50
        // let screenWidth = UIScreen.main.bounds.width
        // let screenHeight = UIScreen.main.bounds.height
        // let xPosition: CGFloat = (screenWidth - buttonSize) / 2
        // let yPosition: CGFloat = (screenHeight - buttonSize) - 50
         //captureButton.frame = CGRect(x: xPosition, y: yPosition, width: buttonSize, height: buttonSize)
         captureButton.layer.cornerRadius = buttonSize / 2
         captureButton.clipsToBounds = true
         
         captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
         
         view.addSubview(captureButton)
         
         
     }
     
     //camera capture
     @objc func capturePhoto() {
         let settings = AVCapturePhotoSettings()
         photoOutPut.capturePhoto(with: settings, delegate: self)
     }
     
     func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
         guard let photoData = photo.fileDataRepresentation(),
               var image = UIImage(data: photoData) else {
             print("Failed to convert photo")
             return }
         
         let rotationAngle2: CGFloat
           switch UIDevice.current.orientation {
           case .portrait:
               rotationAngle2 = 0
           case .landscapeLeft:
               rotationAngle2 = 270
           case .landscapeRight:
               rotationAngle2 = -270
           case .portraitUpsideDown:
               rotationAngle2 = 180
           default:
               rotationAngle2 = 0
           }

         
         image = rotateImage(image, by: rotationAngle2)
         onPhotoCaptured?(image)
         
         onCameraDismissed?()
     }
     
   
    //camera zoom
    private func setupZoomGesture() {
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture))
        view.addGestureRecognizer(pinchGesture)
    }
    
    @objc func handlePinchGesture(gesture: UIPinchGestureRecognizer) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        if gesture.state == .changed {
            let zoomFactor = currentZoomFactor * gesture.scale
            
            currentZoomFactor = max(minZoomFactor, min(zoomFactor, maxZoomFactor))
            
            do {
                try device.lockForConfiguration()
                device.videoZoomFactor = currentZoomFactor
                device.unlockForConfiguration()
            } catch {
                print("Failed to set zoom factor")
            }
            
            gesture.scale = 1.0
        }
    }
    
    
    //back button
    private func setupBackButton() {
            
            let backImage = UIImage(systemName: "chevron.backward")
            
            backButton = UIButton(type: .system)
            backButton.setImage(backImage, for: .normal)
            backButton.setTitle(" Back", for: .normal)
            backButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            backButton.setTitleColor(.systemBlue, for: .normal)
            
            backButton.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            backButton.layer.cornerRadius = 5
            backButton.clipsToBounds = true
        
            
        
            
            backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
            
            
            view.addSubview(backButton)
        }
    @objc private func didTapBackButton() {
        onCameraDismissed?()
        dismiss(animated: true, completion: nil)
    }
    
    //camera  orientation
    private func updatePreviewLayerFrame() {
        videoPreviewLayer.frame = view.bounds
    }
    private func updateButtonPosition() {
        let buttonsize: CGFloat = 50
        let xPosition = (view.bounds.width - buttonsize) / 2
        let yPosition = (view.bounds.height - buttonsize) - 50
        captureButton.frame = CGRect(x: xPosition, y: yPosition, width: buttonsize, height: buttonsize)
    }
    private func updateBackButtonPosition() {
        let buttonWidth: CGFloat = 80
        let buttonHeight: CGFloat = 44
        let safeAreaTop = view.safeAreaInsets.top
        let xPosition: CGFloat = 16
        let yPosition: CGFloat = (safeAreaTop > 0) ? safeAreaTop + 10 : 30

        backButton.frame = CGRect(x: xPosition, y: yPosition, width: buttonWidth, height: buttonHeight)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updatePreviewLayerFrame()
        updateButtonPosition()
        updateBackButtonPosition()
    }
    
    private func configureRotationHandling() {
        
        NotificationCenter.default.addObserver(
            forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { [weak self] _ in guard let self = self else {return}
                self.updatePreviewLayerOrientation()            }
    }
    
    private func updatePreviewLayerOrientation() {
        guard let connection = videoPreviewLayer.connection else { return }
        
        switch UIDevice.current.orientation {
        case .portrait:
            connection.videoRotationAngle = 90
        case .landscapeLeft:
            connection.videoRotationAngle = 0
        case .landscapeRight:
            connection.videoRotationAngle = 180
        case .portraitUpsideDown:
            connection.videoRotationAngle = 270
        default : break
            
        }
    }
    
    func rotateImage(_ image: UIImage, by degrees: CGFloat) -> UIImage {
        let radians = degrees * .pi / 180
        var newSize = CGRect(origin: .zero, size: image.size)
            .applying(CGAffineTransform(rotationAngle: radians)).size
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, image.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        context.rotate(by: radians)
        image.draw(in: CGRect(x: -image.size.width / 2, y: -image.size.height / 2, width: image.size.width, height: image.size.height))
        
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return rotatedImage ?? image
    }
}
