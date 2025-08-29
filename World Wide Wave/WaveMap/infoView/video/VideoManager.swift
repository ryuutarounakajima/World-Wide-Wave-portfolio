//
//  VideoManager.swift
//  World Wide Wave
//
//  Created by Ryutarou Nakajima on 2025/02/16.
//

import UIKit
import SwiftUI
import AVFoundation

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

class VideoPreviewViewController: UIViewController {
    

            
    
    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var videoDataOutoput: AVCaptureVideoDataOutput?
    private var videoFileOutput: AVCaptureFileOutput?
    private var captureButton: UIButton!
    private var isRecording = false
    private var progressLayer: CAShapeLayer?
    private var maxRecordingDuration: TimeInterval = 31
    private var gradientLayer: CAGradientLayer?
    private var animationStartTime: CFTimeInterval = 0
    private var pausedTime: CGFloat = 0
    private var isPaused: Bool = false
    private var ringBackground : CAGradientLayer?
    private var progressLayer2 : CAShapeLayer?
    private var videoPlayerLayer : AVPlayerLayer?
    
    var onVideoCaptured: ((URL) -> Void)?
    var onFinishRecording: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black.withAlphaComponent(0.7)
        
        setupCamera()
        setupPreviewLayer()
        setupCaptureBuuton()
        setupVideoPreviewLayer()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOenrationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications( )
      
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
           
    previewLayer?.frame = view.bounds
    upDateButtonPosition()
    updateVideoPreviewPosition()
        
    }
    
   
   
    
}

extension VideoPreviewViewController {
    private func setupVideoPreviewLayer() {
        let previewSize: CGFloat = 60
        let xPosition = (view.bounds.width - previewSize) - 10
        let yPosition = (view.bounds.height - previewSize) - 40
        
        videoPlayerLayer = AVPlayerLayer()
        videoPlayerLayer?.backgroundColor = UIColor.black.withAlphaComponent(0.6).cgColor
        videoPlayerLayer?.frame = CGRect(x: xPosition, y: yPosition, width: previewSize, height: previewSize)
        videoPlayerLayer?.cornerRadius = 10
        videoPlayerLayer?.masksToBounds = true
        videoPlayerLayer?.videoGravity = .resizeAspectFill
        
        view.layer.addSublayer(videoPlayerLayer!)
        
    }
    
    private func updateVideoPreviewPosition() {
        let previewSize: CGFloat = 60
        let xPosition = (view.bounds.width - previewSize) - 10
        let yPosition = (view.bounds.height - previewSize) - 40
        
        videoPlayerLayer?.frame = CGRect(x: xPosition, y: yPosition, width: previewSize, height: previewSize)
    }
}
extension VideoPreviewViewController: AVCaptureFileOutputRecordingDelegate, CAAnimationDelegate {
    
    
    private func setupCamera() {
        
        AVCaptureDevice.requestAccess(for: .video) { granted in
           if granted {
                DispatchQueue.main.async {
                    self.configureSession()
               }
           } else {
               print("Camera access denied")
           }
        }
    }
    
    private func configureSession() {
        
        session.beginConfiguration()
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back), let mic = AVCaptureDevice.default(for: .audio) else {
            
            print("No camera exists")
            session.commitConfiguration()
            return
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: camera)
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
            }
            
            let audioInput = try AVCaptureDeviceInput(device: mic)
            if session.canAddInput(audioInput) {
                session.addInput(audioInput)
            }
            
        } catch {
            print("camera input error: \(error)")
        }
        
        let videoDataOutput = AVCaptureVideoDataOutput()
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
            videoDataOutoput = videoDataOutput
        }
        
        let videoFileOutput = AVCaptureMovieFileOutput()
        if session.canAddOutput(videoFileOutput) {
            session.addOutput(videoFileOutput)
            self.videoFileOutput = videoFileOutput
        }
   
        session.commitConfiguration()
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            self.session.startRunning()
            
            DispatchQueue.main.async {
                self.updateVideoOrientation()
            }
        }
    }
    
    private func setupPreviewLayer() {
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer
        
    }
    
    private func updateVideoOrientation() {
        
        guard let connection  = previewLayer?.connection else { return }
        
        let angle: CGFloat
        
        switch UIDevice.current.orientation {
        case .portrait:
            angle = 90
        case .landscapeLeft:
            angle = 0
        case .landscapeRight:
            angle = 180
        case .portraitUpsideDown:
            angle = 270
        default:
            return
        }
        
        if connection.isVideoRotationAngleSupported(angle) {
            connection.videoRotationAngle = angle
        }
    }
    @objc private func deviceOenrationDidChange() {
        updateVideoOrientation()
    }
    
    private func setupCaptureBuuton() {
        
        captureButton = UIButton(type: .system)
        captureButton.setTitle("", for: .normal)
        captureButton.backgroundColor = UIColor.white.withAlphaComponent(1.0)
        
        let buttonSize: CGFloat = 50
        captureButton.layer.cornerRadius = buttonSize / 2
        captureButton.clipsToBounds = true
        captureButton.addTarget(self, action: #selector(captureButtonTapped), for: .touchUpInside)
        view.addSubview(captureButton)
    }
    private func upDateButtonPosition() {
        
        let buttonSize: CGFloat = 50
        let xPosition = (view.bounds.width - buttonSize) / 2
        let yPosition = (view.bounds.height - buttonSize) - 50
        
        captureButton.frame = CGRect(x: xPosition, y: yPosition, width: buttonSize, height: buttonSize)
    }
    @objc private func captureButtonTapped() {
        guard let videoFileOutput = self.videoFileOutput else { return }
        
        if !isRecording {
            
            let outputPath = NSTemporaryDirectory() + "output.mp4"
            let fileURL = URL(fileURLWithPath: outputPath)
            
            do {
                try FileManager.default.removeItem(at: fileURL)
            } catch {
                print("Error removing existing file: \(error)")
            }
            
            videoFileOutput.startRecording(to: fileURL, recordingDelegate: self)
            isRecording = true
            captureButton.backgroundColor = UIColor.red
            
            startProgressRing()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + maxRecordingDuration) {
                
                if self.isRecording {
                    self.stopRecording()
                   
                }
            }
            
        } else {
          // stopRecording()
            videoFileOutput.stopRecording()
            isRecording = false
            captureButton.backgroundColor = UIColor.white.withAlphaComponent(1.0)
            removeProgressRing()
            //pauseProgressRing()
        }
        
        
    }
    
    /*private func startRecording() {
        let outputPath = NSTemporaryDirectory() + "output.mp4"
        let fileURL = URL(fileURLWithPath: outputPath)
        
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print("Error removing existing file: \(error)")
        }
        
        videoFileOutput?.startRecording(to: fileURL, recordingDelegate: self)
        isRecording = true
        captureButton.backgroundColor = UIColor.red
        startProgressRing()
    }
     private func addCircleAroundButton() {
         let buttonSize: CGFloat = 50
         let margin: CGFloat = 10
         let radius = (buttonSize / 2) + margin
         let center = captureButton.center

         // 円のパス
         let circularPath = UIBezierPath(
             arcCenter: center,
             radius: radius,
             startAngle: -CGFloat.pi / 2,
             endAngle: 1.5 * CGFloat.pi,
             clockwise: true
         )

         // 円のレイヤー
         let circleLayer = CAShapeLayer()
         circleLayer.path = circularPath.cgPath
         circleLayer.strokeColor = UIColor.black.cgColor
         circleLayer.fillColor = UIColor.clear.cgColor
         circleLayer.lineWidth = 6

         // view.layer に追加
         view.layer.addSublayer(circleLayer)
     }*/
    private func stopRecording() {
        videoFileOutput?.stopRecording()
        isRecording = false
        captureButton.backgroundColor = UIColor.white.withAlphaComponent(1.0)
        //pauseProgressRing()
        removeProgressRing()
    }
    private func startProgressRing() {
        let buttonSize: CGFloat = 50
        let margin: CGFloat = 6
        let radius = (buttonSize / 2) + margin
        let center = captureButton.center
        let circularPath = UIBezierPath (arcCenter: center, radius: CGFloat(radius), startAngle: -CGFloat.pi / 2, endAngle: 1.5 * CGFloat.pi, clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 7
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeEnd = isPaused ? pausedTime : 0
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
               UIColor.red.cgColor,
               UIColor.orange.cgColor,
               UIColor.yellow.cgColor,
               UIColor.green.cgColor,
               UIColor.blue.cgColor,
               UIColor.purple.cgColor,
               UIColor.red.cgColor
           ]
        view.layer.addSublayer(shapeLayer)
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)

        gradientLayer.mask = shapeLayer
        
        view.layer.addSublayer(gradientLayer)
        self.progressLayer = shapeLayer
        self.gradientLayer = gradientLayer
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = maxRecordingDuration
        animation.fromValue = isPaused ? pausedTime : 0
        animation.toValue = 1
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        animation.delegate = self
        shapeLayer.add(animation, forKey: "progressAnimation")
        
      
        animationStartTime = CACurrentMediaTime() - (isPaused ? Double(pausedTime) * maxRecordingDuration : 0)
        isPaused = false
    }
    private func pauseProgressRing() {
        guard let progressLayer = progressLayer else { return }
        
        let elapsed = CACurrentMediaTime() - animationStartTime
        pausedTime = CGFloat(elapsed / maxRecordingDuration)
        
        progressLayer.removeAllAnimations()
        gradientLayer?.removeAnimation(forKey: "rotation")
        
        progressLayer.strokeEnd = pausedTime
        isPaused = true
    }
    private func removeProgressRing() {
        gradientLayer?.removeFromSuperlayer()
        progressLayer?.removeFromSuperlayer()
        gradientLayer = nil
        progressLayer = nil
    }
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    if flag, isRecording {
                stopRecording()
            }
}
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: (any Error)?) {
        
        if let error = error {
            print("Recoding error: \(error)")
        } else {
            print("Recording complete: \(outputFileURL)")
            UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, nil, nil, nil)
            onVideoCaptured?(outputFileURL)
           // onFinishRecording?()
        }
    }
}

struct VideoPreviewView: UIViewControllerRepresentable {
    
    
  //  let captureSession: AVCaptureSession
    @Binding var captureVideoURL: URL?
    @Binding var isVideoCaptured: Bool
    
    class Coordinator: NSObject {
        var parent: VideoPreviewView
        
        init(parent: VideoPreviewView) {
            self.parent = parent
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    func makeUIViewController(context: Context) -> VideoPreviewViewController {
       
        let controller = VideoPreviewViewController()
        
        controller.onVideoCaptured = { url in
            DispatchQueue.main.async {
                self.captureVideoURL = url
            }
        }
        
        controller.onFinishRecording = {
            DispatchQueue.main.async {
                self.isVideoCaptured = false
            }
        }
        
        return controller
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

/*class VideoPreviewViewController: UIViewController, AVCaptureFileOutputRecordingDelegate{
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: (any Error)?) {
        
    }
    
    
}
*/
