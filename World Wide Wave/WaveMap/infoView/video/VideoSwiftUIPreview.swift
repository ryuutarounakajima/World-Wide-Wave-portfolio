//
//  VideoSwiftUIPreview.swift
//  World Wide Wave
//
//  Created by Ryutarou Nakajima on 2025/02/16.
//

import SwiftUI
import AVFoundation

struct VideoSwiftUIPreview: View {
    @State private var isPresented: Bool = false
    @State private var videoURL: URL?
    
    private let captureSession = AVCaptureSession()
    
    var body: some View {
        VideoPreviewView(captureSession: captureSession)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                
            }
    }
}

#Preview {
    VideoSwiftUIPreview()
}
