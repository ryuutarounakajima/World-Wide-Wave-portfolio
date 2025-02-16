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
        default:
            return false
        }
    }
}

class VideoPreViewController: UIViewController {
    
    private let session = AVCaptureSession()
    private let videoOutput = AVCaptureMovieFileOutput()
    
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var isRecording: Bool = false
}
