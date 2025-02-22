//
//  CameraSwiftUIPreview.swift
//  World Wide Wave
//
//  Created by Ryutarou Nakajima on 2025/01/15.
//

import SwiftUI

struct CameraSwiftUIPreview: View {
    
    private let micManaget = MicManager()
  //  @EnvironmentObject var formData : FormData
    @Binding var isCameraPresented: Bool
    @Binding var captureImage: UIImage?
    //@State private var cameraController: CameraPreviewController?
    @State private var isSwiped = false
    @State private var showHint: Bool = true
    @State private var opacity: Double = 1.0
    @State private var scale: Double = 1.0
    
    
    
    var body: some View {
        NavigationStack {
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
                    
                    if showHint {
                        
                        HStack(spacing: 5)  {
                            
                            Image(systemName: "chevron.left.chevron.left.dotted")
                                .font(.title)
                                .foregroundColor(.black)
                                .opacity(opacity)
                                .scaleEffect(scale)
                                .onAppear {
                                    withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                                        opacity = 0.4
                                        scale = 1.2
                                    }
                                }
                            Text("Video")
                                .font(.title2)
                                .foregroundColor(.black)
                        }
                            .background(Color.green.opacity(0.6).cornerRadius(10))
                            .padding()
                            .position(x: screenWidth / 8, y: screenHeight / 2)
                            .opacity(showHint ? 1 : 0)
                            .animation(.easeOut(duration: 1), value: showHint)
                    }
                }
                .onAppear {
                    // ⏳
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        showHint = false
                    }
                      
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture()
                        .onEnded {
                            value in
                            if value.translation.width < -100 {
                                Task {
                                    if await micManaget.requestMicAccess() {
                                        isSwiped = true
                                    } else {
                                        print("mic access denied")
                                    }
                                }
                                
                            }
                        }
                )

            }
            .ignoresSafeArea(.all)
            .navigationDestination(isPresented: $isSwiped) {
                VideoSwiftUIPreview()
            }
        }
      
    }
       
}


#Preview {
    let image = UIImage(systemName: "star.fill")
    CameraSwiftUIPreview(isCameraPresented: .constant(false), captureImage: .constant(image))
}
