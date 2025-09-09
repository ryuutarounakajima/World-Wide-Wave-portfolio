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
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                HStack {
                    Button("Photo") {
                        mode = .photo
                    }
                    .padding()
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(8)
                    
                    Button("Photo") {
                        mode = .photo
                    }
                    .padding()
                    .background(Color.white.opacity(0.7))
                    .cornerRadius(8)
                }
                .padding()
            }
        }
    }
}

#Preview {
    
    UnifiedCameraSwiftUIView()
}
