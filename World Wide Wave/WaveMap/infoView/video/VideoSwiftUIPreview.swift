//
//  VideoSwiftUIPreview.swift
//  World Wide Wave
//
//  Created by Ryutarou Nakajima on 2025/02/16.
//

import SwiftUI
import AVFoundation

struct VideoSwiftUIPreview: View {
    
    //private let captureSession = AVCaptureSession()
    @EnvironmentObject var formData: FormData
    
    @Binding var captureVideoURL: URL?
    @Binding var isVideoPresented: Bool
    
    
    
    var body: some View {
        VideoPreviewView(captureVideoURL: $captureVideoURL, isVideoCaptured: $isVideoPresented)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                
            }
    }
}

#Preview {
    let dummyURL = Bundle.main.url(forResource: "SampleVideo", withExtension: "mov")
        ?? URL(fileURLWithPath: "/tmp/dummy.mov")
    let formData = FormData()
    
    VideoSwiftUIPreview(
        captureVideoURL: .constant(dummyURL), isVideoPresented: .constant(true)
    ).environmentObject(formData)
}
