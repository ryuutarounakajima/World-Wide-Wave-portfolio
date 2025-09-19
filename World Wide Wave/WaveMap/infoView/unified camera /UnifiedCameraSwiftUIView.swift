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
    @State private var showVideoSheet = false
    
    @State private var blightness: Double = 0.5
    @State private var showBlightness = false
    
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                UnifiedCameraView(mode: $mode, captureImage: $captureImage, capterVideoURL: $captureVideoURL, blightness: $blightness)
                    .ignoresSafeArea()
                    
                
                //capture button
                Button(action: {
                    
                    if mode == .photo {
                        print("tapped")
                        NotificationCenter.default.post(name: .captureButtonTapped, object: nil)
                        
                    } else if mode == .video {
                      
                        if isRecording {
                            print("Video capture stopped")
                            NotificationCenter.default.post(name: .stopVideoCapture, object: nil)
                        } else {
                            print("Video capture started")
                            NotificationCenter.default.post(name: .startVideoCapture, object: nil)
                        }
                        isRecording.toggle()
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
                ZStack {
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
                                .allowsHitTesting(false)
                        } else {
                            Color.black
                        }
                    }
                    
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if mode == .photo {
                                showPhotoSheet = true
                                print("photo preview tapped")
                            } else {
                                if captureVideoURL != nil && !isRecording {
                                    showVideoSheet = true
                                    print("video preview tapped")
                                } else {
                                    print("Video not ready yet")
                                }                            }
                        }
                   
                }
                    .frame(width: 60, height: 60)
                    .overlay(
                                   RoundedRectangle(cornerRadius: 8)
                                       .stroke(Color.black, lineWidth: 2)
                               )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .position(
                                x: geo.size.width - 60/2 - 10, // UIKit の xPosition 相当
                                y: geo.size.height - 60/2 - 40 // UIKit の yPosition 相当
                            )
                   
                if showBlightness {
                    VStack {
                        ZStack {
                            HStack(spacing:0) {
                                ForEach(0..<3) { i in
                                                                       Rectangle()
                                                                           .fill(Color.black.opacity(0.7))
                                                                           .frame(width: 2, height: 20) // 少し長めの縦線
                                                                       if i < 2 { Spacer() }
                                                                   }
                            }
                            .padding(.horizontal, 20)
                            
                            HStack(spacing: 0) {
                                      ForEach(0..<21) { i in // 0〜1 を 0.05 間隔で 21本の線
                                          Rectangle()
                                              .fill(Color.black.opacity(0.6))
                                              .frame(width: 1, height: 10) // 縦線の幅と高さ
                                          if i < 20 { Spacer() }
                                      }
                                  }
                                  .padding(.horizontal, 20)
                            
                            Slider(value: $blightness, in: 0.0...1.0, step: 0.01)
                            .padding(.horizontal, 20)
                        }
                     
                        HStack {
                            Text("0.0")
                            Spacer()
                            Text("0.25")
                            Spacer()
                            Text("0.5")
                            Spacer()
                            Text("0.75")
                            Spacer()
                            Text("1.0")
                        }
                        .padding(.horizontal, 20)
                        .font(.caption2)
                           
                    }
                    .position(x: geo.size.width / 2, y: geo.size.height - 50 - 100)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeInOut, value: showBlightness)
                }
            }
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
            .simultaneousGesture(
                DragGesture(minimumDistance: 30)
                    .onEnded {
                        value in
                        if value.translation.height < -50 {
                            withAnimation {showBlightness = true
                            }
                        } else if  value.translation.height > 50 {
                            withAnimation {
                                showBlightness = false
                            }
                            
                        }
                    }
            )
            
            .sheet(isPresented: $showPhotoSheet) {
                if let image = captureImage {
                    PhotoSheetView(image: image, isCameraPresented: $isCameraPresented)
                        .environmentObject(formData)
                        .presentationDetents([.fraction(1.0)])
                    
                }
            }
            .sheet(isPresented: $showVideoSheet) {
                if let url = captureVideoURL {
                    VideoSheetView(url: url, isCameraPresented: $isCameraPresented)
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
    @Previewable @State var dummyBlightness : Double = 1.0
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
                
                VStack {
                    ZStack {
                        HStack(spacing:0) {
                            ForEach(0..<3) { i in
                                                                   Rectangle()
                                                                       .fill(Color.black.opacity(0.7))
                                                                       .frame(width: 2, height: 20) // 少し長めの縦線
                                                                   if i < 2 { Spacer() }
                                                               }
                        }
                        .padding(.horizontal, 20)
                        
                        HStack(spacing: 0) {
                                  ForEach(0..<21) { i in // 0〜1 を 0.05 間隔で 21本の線
                                      Rectangle()
                                          .fill(Color.black.opacity(0.6))
                                          .frame(width: 1, height: 10) // 縦線の幅と高さ
                                      if i < 20 { Spacer() }
                                  }
                              }
                              .padding(.horizontal, 20)
                        
                        Slider(value: $dummyBlightness, in: 0.0...1.0, step: 0.01)
                        .padding(.horizontal, 20)
                    }
                 
                    HStack {
                        Text("0.0")
                        Spacer()
                        Text("0.25")
                        Spacer()
                        Text("0.5")
                        Spacer()
                        Text("0.75")
                        Spacer()
                        Text("1.0")
                    }
                    .padding(.horizontal, 20)
                    .font(.caption2)
                       
                }
                .position(x: geo.size.width / 2, y: geo.size.height - 50 - 100)
                    
                
            }
        }
    } else {
        UnifiedCameraSwiftUIView( isCameraPresented: .constant(true))
    }
}

