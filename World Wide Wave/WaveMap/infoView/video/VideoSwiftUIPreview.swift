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
        GeometryReader { geometry in
            let screenWidth =
            geometry.size.width
            let sreenHeight = geometry.size.height
            let buttonSize: CGFloat = 70
            let xPosition: CGFloat = screenWidth / 2
            let yPosition: CGFloat = sreenHeight - 40 - (buttonSize / 2)
            
            ZStack {
                VideoPreviewView(captureVideoURL: $captureVideoURL, isVideoCaptured: $isVideoPresented, formData: formData).overlay(
                    Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color.blue.opacity(1.0), Color.pink.opacity(0.9)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 6
                    )
                    .frame(width: buttonSize, height: buttonSize)
                    .position(x: xPosition, y: yPosition)

                    .allowsHitTesting(false)
                )
                    .edgesIgnoringSafeArea(.all)
                    .onAppear {
                        
                    }
            }
            .contentShape(Rectangle())
            
        }
        .ignoresSafeArea(.all)
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
