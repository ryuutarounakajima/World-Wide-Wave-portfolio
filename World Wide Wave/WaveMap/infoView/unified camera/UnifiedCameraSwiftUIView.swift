//
//  UnifiedCameraSwiftUIView.swift
//  World Wide Wave
//
//  Created by Ryutarou Nakajima on 2025/09/09.
//

import SwiftUI

struct UnifiedCameraSwiftUIView: View {
    
    @State private var mode: captureMode = .photo
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                UnifiedCameraView(mode: $mode)
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
                
                Button(action: {
                    print("tapped")
                    NotificationCenter().post(name: .captureButtonTapped, object: nil)
                }) {
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
              
            }
        }
       
    }
}
extension Notification.Name {
    static let captureButtonTapped = Notification.Name("captureButtontapped")
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
                    
            }
        }
    } else {
        UnifiedCameraSwiftUIView()
    }
}

