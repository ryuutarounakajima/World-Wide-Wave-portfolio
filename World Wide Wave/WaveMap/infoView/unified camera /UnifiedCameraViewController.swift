//
//  UnifiedCameraViewController.swift
//  World Wide Wave
//
//  Created by Ryutarou Nakajima on 2025/09/09.
//

import Foundation
import AVFoundation
import SwiftUI

enum captureMode {
    case photo
    case video
}

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

actor MicManager {
    func requestMicAccess() async -> Bool {
        
        let micStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        
        switch micStatus {
        case .authorized:
            return true
        case .notDetermined:
            return await AVCaptureDevice.requestAccess(for: .audio)
        case .denied:
            print("mic access denied")
            try? await Task.sleep(nanoseconds: 5_000_000)
            
            let newStatus = AVCaptureDevice.authorizationStatus(for: .audio)
           
            if newStatus == .authorized {
                return true
            } else {
                return false
            }
        default:
            return true
        }
    }
}

class UnifiedCameraViewController : UIViewController {
    
    var formData: FormData?
    var onPhotoCaptured: ((UIImage) -> Void)?
    var onVideoCaptured: ((URL) -> Void)?
    //setup
    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    //.photo .video
    private var photoOutput: AVCapturePhotoOutput?
    private var videoOutPut: AVCaptureMovieFileOutput?
    var mode: captureMode = .photo {
        didSet {switchCamera(mode)}
    }
    private var isRecording = false
    
    //rotation angle
    private var currentDeviceAngle: AVCaptureDevice?
    private var previewAngleObserver: NSKeyValueObservation?
    private var rotationCoordinator: AVCaptureDevice.RotationCoordinator?
    
    //ecposure
    var onDefalutExposure: ((Double) -> Void)?
    
    //zoom
    private var currentZoomFactor: CGFloat = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        audioSessionActive()
        setupSession()
        captueButtonNotication()
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        view.addGestureRecognizer(pinch)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        switchCamera(mode)
        startSession()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopSession()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
        
       // upDateButtonPosition()
        //view.bringSubviewToFront(captureButton)
    }
    
    
}

extension UnifiedCameraViewController: AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate {
    
//MARK: - zoom factor
    @objc private func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        if gesture.state == .began {
            currentZoomFactor = device.videoZoomFactor
        }
        
        var newZoomFactor = currentZoomFactor * gesture.scale
        newZoomFactor = max(1.0, min(newZoomFactor, device.activeFormat.videoMaxZoomFactor))
        
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = newZoomFactor
            device.unlockForConfiguration()
        } catch {
            print("Zooming failed: \(error)")
        }
    }

//MARK: - exposure
    func setExposure(_ value: Double) {
        
        guard let device = currentDeviceAngle else { return }
        
        
        do {
            try device.lockForConfiguration()
            let min = device.minExposureTargetBias
            let max = device.maxExposureTargetBias
            let bias = Float(min + (max - min) * Float(value))
            device.setExposureTargetBias(bias) { _ in }
            device.unlockForConfiguration()
            print("Exposure set: \(bias)")
        } catch {
            print("Exposure setting falied: \(error)")
        }
        
    }
    func sendDefaultExposureValue() {
        guard let device = currentDeviceAngle else {
            return
        }
        let min = device.minExposureTargetBias
        let max = device.maxExposureTargetBias
        let current = device.exposureTargetBias
        let nomalized = Double((current - min) / (max - min))
        onDefalutExposure?(nomalized)
    }
  
//MARK: - capture button notifications
    private func captueButtonNotication() {
        //photo capture
        NotificationCenter.default.addObserver(self, selector: #selector(captureButtonTapped), name: .captureButtonTapped, object: nil)
        //video capture start
        NotificationCenter.default.addObserver(self, selector: #selector(startVideoCapture), name: .startVideoCapture, object: nil)
        //video capture stop
        NotificationCenter.default.addObserver(self, selector: #selector(stopVideoCapture), name: .stopVideoCapture, object: nil)
    }
    
//MARK: - video capture
    
    func audioSessionActive() {
        
        do {
             let audioSession = AVAudioSession.sharedInstance()
             try audioSession.setCategory(.playAndRecord, mode: .videoRecording, options: [.defaultToSpeaker])
             try audioSession.setActive(true)
             print("AVAudioSession configured")
         } catch {
             print("Failed to configure AVAudioSession: \(error)")
         }
        
    }
    func newVideoURL() -> URL {
        let fm = FileManager.default
        let tempDir = fm.temporaryDirectory
        let fileName = "output-\(UUID().uuidString).mov"
        return  tempDir.appendingPathComponent(fileName)
        
    }
    @objc func startVideoCapture() {
        guard let videoOut = videoOutPut else {return}
        
        if let audioInput = videoOut.connection(with: .audio) {
            print("✅ Audio connection found: \(audioInput)")
        } else {
            print("❌ audio connection missing")
        }
        
        let outputURL = newVideoURL()
        
        videoOut.startRecording(to: outputURL, recordingDelegate: self)
        print("Video Recording Started: \(outputURL)")
    }
    @objc func stopVideoCapture() {
        guard let videoOut = videoOutPut, videoOut.isRecording else {return}
        videoOut.stopRecording()
        print("Video Recording Stopped")
    }
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: (any Error)?) {
        
        if let error = error {
            print("Video capture failed: \(error)")
            return
        }
        
        print("Video save: \(outputFileURL)")
        print("🎥 tmp exists:", FileManager.default.fileExists(atPath: outputFileURL.path))
      //formData?.capturedVideoURL = outputFileURL
        
        
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let newURL = documentsURL.appendingPathComponent(UUID().uuidString + ".mov")
        
        do {
            
            // 🔥 tmp → Documents にコピー
                    try fileManager.moveItem(at: outputFileURL, to: newURL)
                    
                    print("✅ Saved to Documents:", newURL.path)
                    print("✅ Exists after copy:",
                          fileManager.fileExists(atPath: newURL.path))
                    
                    // 🔥 ここが超重要
                    onVideoCaptured?(newURL)
        } catch {
            print("❌ Copy failed:", error)
        }
        
       // onVideoCaptured?(outputFileURL)
        
    }
    
//MARK: - photo capture
    private func takePhoto() {
        guard let photoOutput = photoOutput else {
            print("Photo output is nil")
            return
        }
        print("take photo called ")
        let setting = AVCapturePhotoSettings()
        setting.flashMode = .auto
        
        photoOutput.capturePhoto(with: setting, delegate: self)
    }
    @objc func captureButtonTapped() {
       // print("captureButtonTapped received!")
        takePhoto()
    }
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
        
        print("delegaet called")
        if let error = error {
            print("Photo capture failed: \(error)")
            return
        }
        
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data)
        else { return }
        
        
       print("photo captured")
        print("image:\(image)")
        
        formData?.capturedImage = image
        onPhotoCaptured?(image) // <- send image to swiftui
        
        
    }
    
//MARK: - setup
    private func setupSession() {
        session.beginConfiguration()
        session.sessionPreset = .high
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else {
            session.commitConfiguration()
            return
        }
        session.addInput(input)
        self.currentDeviceAngle = device
        
        if let mic = AVCaptureDevice.default(for: .audio),
           let micInput = try? AVCaptureDeviceInput(device:mic),
           session.canAddInput(micInput)  {
            session.addInput(micInput)
        }
        
        
        let photoOut = AVCapturePhotoOutput()
        if session.canAddOutput(photoOut) {
            session.addOutput(photoOut)
            self.photoOutput = photoOut
        }
        
        let videoOut = AVCaptureMovieFileOutput()
        if session.canAddOutput(videoOut) {
            session.addOutput(videoOut)
            self.videoOutPut = videoOut
           // session.removeOutput(videoOut)
        }
        
        session.commitConfiguration()
    
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            previewLayer?.removeFromSuperlayer()
            let layer = AVCaptureVideoPreviewLayer(session: self.session)
            layer.frame = self.view.bounds
            layer.videoGravity = .resizeAspectFill
            self.view.layer.addSublayer(layer)
            self.previewLayer = layer
            
            self.sendDefaultExposureValue()
            
           // self.view.bringSubviewToFront(self.captureButton)
        }
       
        
    }
    private func startSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            [weak self] in guard let self = self else { return }
            
            if !self.session.isRunning {
                self.session.startRunning()
                print("Session started in mode: \(self.mode)")
                DispatchQueue.main.async {
                    self.setupRotationCoordinator()
                }
               
            }
        }
    }
    private func stopSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            [weak self] in guard let self = self else { return }
            if self.session.isRunning {
                self.session.stopRunning()
                print("Session stopped in mode: \(self.mode)")
            }
        }
    }
    func switchCamera(_ mode: captureMode) {
        session.beginConfiguration()
        
        if mode == .photo {
            if let videoOut = videoOutPut, session.outputs.contains(videoOut) {
                session.removeOutput(videoOut)
            }
            if let photoOutput = photoOutput, !session.outputs.contains(photoOutput) {
                session.addOutput(photoOutput)
            }
            print("photo mode open")
        } else {
            if let photoOutput = photoOutput, session.outputs.contains(photoOutput) {
                session.removeOutput(photoOutput)
            }
            if let videoOutPut = videoOutPut, !session.outputs.contains(videoOutPut) {
                session.addOutput(videoOutPut)
            }
            print("video mode open")
        }
        
        session.commitConfiguration()
            //updateRoationCoordinator()
    }
    
    
    
//MARK: - rotation coordinate
    private func setupRotationCoordinator() {
        
        guard let device =
                currentDeviceAngle, let previewLayer = previewLayer else { return }
        
        let coordinator =
        AVCaptureDevice.RotationCoordinator(device: device, previewLayer: previewLayer)
        
        self.rotationCoordinator = coordinator
        
        previewAngleObserver = coordinator.observe(\.videoRotationAngleForHorizonLevelPreview, options: [.initial, .new]) { [weak self] coordinator, _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let connection = self.previewLayer?.connection {
                    let previewAngle = coordinator.videoRotationAngleForHorizonLevelPreview
                    if connection.isVideoRotationAngleSupported(previewAngle) {
                        connection.videoRotationAngle = previewAngle
                    }
                }
                
                self.updateRoationCoordinator()
            }
            
        }
       
    }
    private func updateRoationCoordinator() {
        guard let coordinator = rotationCoordinator else { return }
        let captureAngle = coordinator.videoRotationAngleForHorizonLevelCapture
        
        if let connection = photoOutput?.connection(with: .video),
           connection.isVideoRotationAngleSupported(captureAngle) {
            connection.videoRotationAngle = captureAngle
        }
        
        if let connection = videoOutPut?.connection(with: .video), connection.isVideoRotationAngleSupported(captureAngle) {
            connection.videoRotationAngle = captureAngle
        }
    }
    
    
  
    
}

struct UnifiedCameraView: UIViewControllerRepresentable {
    
    @Binding var mode: captureMode
    @Binding var captureImage: UIImage?
    @Binding var capterVideoURL: URL?
    @Binding var blightness: Double
    
    func makeUIViewController(context: Context) -> UnifiedCameraViewController {
        
        let vc = UnifiedCameraViewController()
        vc.mode = mode
        vc.onPhotoCaptured = { image in
            captureImage = image
        }
        vc.onVideoCaptured = { url in
            capterVideoURL = url
        }
        return vc
    }
   
   func updateUIViewController(_ uiViewController: UnifiedCameraViewController, context: Context) {
       
       if uiViewController.mode != mode {
           uiViewController.mode = mode
       }
       
       uiViewController.setExposure(blightness)
   }
}

//set up button
/*
private func setupCaptureButton() {
    
    captureButton = UIButton(type: .system)
    captureButton.setTitle("", for: .normal)
    captureButton.backgroundColor = UIColor.white.withAlphaComponent(1.0)
    
    let buttonSize: CGFloat = 50
    captureButton.layer.cornerRadius = buttonSize / 2
    captureButton.clipsToBounds = true
   
    let xPosition = (view.bounds.width - buttonSize) / 2
    let yPosition = (view.bounds.height - buttonSize) - 50
 
 captureButton.frame = CGRect(x: xPosition, y: yPosition, width: buttonSize, height: buttonSize)
    view.addSubview(captureButton)
 
 
 //captureButton.addTarget(self, action: #selector(captureButtonTapped), for: .touchUpInside)
    upDateButtonPosition()
    //view.bringSubviewToFront(captureButton)
}

private func upDateButtonPosition() {
    
    let buttonSize: CGFloat = 50
    let xPosition = (view.bounds.width - buttonSize) / 2
    let yPosition = (view.bounds.height - buttonSize) - 50
    
    captureButton.frame = CGRect(x: xPosition, y: yPosition, width: buttonSize, height: buttonSize)
}
*/
