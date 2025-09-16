//
//  UnifiedCameraSwiftUIView.swift
//  World Wide Wave
//
//  Created by Ryutarou Nakajima on 2025/09/09.
//

import SwiftUI
import AVKit

struct UnifiedCameraSwiftUIView: View {
    @EnvironmentObject var formData: FormData
    @Binding var isCameraPresented: Bool
    
    @State private var mode: captureMode = .photo
    
    @State private var captureImage: UIImage?
    @State private var captureVideoURL: URL?
    
    @State private var isRecording = false
    
    @State private var showPhotoSheet = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                UnifiedCameraView(mode: $mode, captureImage: $captureImage, capterVideoURL: $captureVideoURL)
                    .ignoresSafeArea()
                    .gesture(
                        DragGesture()
                            .onEnded {
                                value in
                                if value.translation.width  < -50 {
                                    mode = .video
                                } else if value.translation.width  > 50 {
                                    mode = .photo
                                }
                            }
                    )
                
                //capture button
                Button(action: {
                    
                    if mode == .photo {
                        print("tapped")
                        NotificationCenter.default.post(name: .captureButtonTapped, object: nil)
                        
                    } else if mode == .video {
                      
                        if isRecording {
                            print("Video capture started")
                            NotificationCenter.default.post(name: .startVideoCapture, object: nil)
                        } else {
                            print("Video capture stopped")
                            NotificationCenter.default.post(name: .stopVideoCapture, object: nil)
                        }
                    }
                   
                    
                    
                })
                {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 50, height: 50)
                       
                }
                .overlay(Circle().stroke(
                    mode == .photo ? LinearGradient(
                        colors: [Color.red.opacity(1.0), Color.blue.opacity(0.9)],
                        startPoint: .top,
                        endPoint: .bottom
                      )
                    : LinearGradient(
                        colors: [Color.blue.opacity(1.0), Color.red.opacity(0.9)],
                        startPoint: .top,
                        endPoint: .bottom
                      ),
                    lineWidth: 6
                )
                    .padding(-10)
                )
                .position(x: geo.size.width / 2, y: geo.size.height - 50 - 25)
              
                
                //capture preview
                Group{
                    if mode == .photo {
                        if let image = captureImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                            
                            
                                
                        } else {
                            Color.black
                        }
                    } else {
                        if let videoURL = captureVideoURL {
                            VideoPlayer(player: AVPlayer(url: videoURL))
                                .scaledToFill()
                        } else {
                            Color.black
                        }
                    }
                   
                }
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                                   RoundedRectangle(cornerRadius: 8)
                                       .stroke(Color.black, lineWidth: 2)
                               )
                    .position(
                                x: geo.size.width - 60/2 - 10, // UIKit の xPosition 相当
                                y: geo.size.height - 60/2 - 40 // UIKit の yPosition 相当
                            )
                    .onTapGesture(perform: {
                        if mode == .photo {
                            showPhotoSheet = true
                        } else {
                            
                        }
                    })
                 
                
                   
              
            }
            .sheet(isPresented: $showPhotoSheet) {
                if let image = captureImage {
                    PhotoSheetView(image: image, isCameraPresented: $isCameraPresented)
                        .environmentObject(formData)
                        .presentationDetents([.fraction(1.0)])
                    
                }
            }
        }
       
    }
}
extension Notification.Name {
    static let captureButtonTapped = Notification.Name("captureButtonTapped")
    static let startVideoCapture = Notification.Name("startVideoCapture")
    static let stopVideoCapture = Notification.Name("stopVideoCapture")
}

#Preview {
    
    if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
        // カメラ代わりのダミー背景
        GeometryReader { geo in
            ZStack {
                
                Color.gray.ignoresSafeArea()
                
                Text("📸 Camera Preview not available")
                    .foregroundColor(.black)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
               
                Circle()
                    .fill(Color.white)
                    .frame(width: 60, height: 60)
                    .overlay( // 枠線を追加したいときは overlay が便利
                            Circle().stroke(
                                LinearGradient(
                                    colors: [Color.red.opacity(1.0), Color.blue.opacity(0.9)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 6
                            )
                            .padding(-12)
                        )
                    .position(x: geo.size.width / 2, y: geo.size.height - 50 - 25)
                    
                
                Image(systemName: "camera")
                    .resizable()
                    .foregroundStyle(.white)
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                                   RoundedRectangle(cornerRadius: 8)
                                       .stroke(Color.black, lineWidth: 2)
                               )
                               .position(
                                   x: geo.size.width - 60/2 - 10, // UIKit の xPosition 相当
                                   y: geo.size.height - 60/2 - 40 // UIKit の yPosition 相当
                               )
            }
        }
    } else {
        UnifiedCameraSwiftUIView( isCameraPresented: .constant(true))
    }
}

