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
        }
    }
}


#Preview {
    // プレビューではカメラを起動しない
    if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
        Text("📸 Camera Preview not available in Xcode")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.gray)
    } else {
        UnifiedCameraSwiftUIView()
    }
}

