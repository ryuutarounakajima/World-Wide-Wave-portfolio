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
                    .frame(width: 50, height: 50)
                    .position(x: geo.size.width / 2, y: geo.size.height - 50 - 25)
                
                
            }
        }
    } else {
        UnifiedCameraSwiftUIView()
    }
}

