//
//  VideoSwiftUIPreview.swift
//  World Wide Wave
//
//  Created by Ryutarou Nakajima on 2025/02/16.
//

import SwiftUI
import AVFoundation

struct VideoSwiftUIPreview: View {
    
    private let captureSession = AVCaptureSession()
    @Binding var captureVideoURL: URL?
    
    var body: some View {
        VideoPreviewView(captureVideoURL: $captureVideoURL)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                
            }
    }
}

#Preview {
    let dummyURL = Bundle.main.url(forResource: "SampleVideo", withExtension: "mov")
        ?? URL(fileURLWithPath: "/tmp/dummy.mov")
    let formData = FormData()
    
    return VideoSwiftUIPreview(
        captureVideoURL: .constant(dummyURL)
    ).environmentObject(formData)
}
