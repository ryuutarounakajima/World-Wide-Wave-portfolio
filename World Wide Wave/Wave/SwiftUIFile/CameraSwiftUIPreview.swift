//
//  CameraSwiftUIPreview.swift
//  World Wide Wave
//
//  Created by Ryutarou Nakajima on 2025/01/15.
//

import SwiftUI

struct CameraSwiftUIPreview: View {
  //  @EnvironmentObject var formData : FormData
    @Binding var isCameraPresented: Bool
    @Binding var captureImage: UIImage?
    @State private var cameraController: CameraPreviewController?
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let buttonSize: CGFloat = 70
            
            let xPosition: CGFloat = screenWidth / 2
            let yPosition: CGFloat = screenHeight - 40 - (buttonSize / 2)
            
            ZStack {
                
                Color.black.opacity(0.6)
                    .ignoresSafeArea(.all)
                
                
                   
                
                CameraPreviewView(captureImage: $captureImage, isCameraPresented: $isCameraPresented)
                  //  .ignoresSafeArea(.all)
                    .overlay(
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
                    /*.overlay (
                        Circle()
                            
                        .fill(Color.blue.opacity(0.4))
                        .frame(width: buttonSize, height: buttonSize)
                        .position(x: xPosition, y: yPosition)
                        .allowsHitTesting(false)
                        
                    )*/
              }
        }.ignoresSafeArea(.all)
    }
       
}


#Preview {
    let image = UIImage(systemName: "star.fill")
    CameraSwiftUIPreview(isCameraPresented: .constant(false), captureImage: .constant(image))
}
