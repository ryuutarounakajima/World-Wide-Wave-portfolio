//
//  VideoSheetView.swift
//  World Wide Wave
//
//  Created by Ryuutarou Nakajima on 2025/09/16.
//

import SwiftUI
import AVKit

struct VideoSheetView: View {
    
    var url : URL
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var formData: FormData
    @Binding var isCameraPresented: Bool
    
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    Color.white.ignoresSafeArea()
                    
                    VideoPlayer(player: AVPlayer(url: url))
                                           .frame(width: geometry.size.width,
                                                  height: geometry.size.height)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        formData.capturedVideoURL = url
                        formData.generateThumbnailIfNeeded(from: url)
                        
                        dismiss()
                        isCameraPresented = false
                    }
                    .font(.headline)
                    .bold()
                    .foregroundStyle(.brown)
                }
            }
            .ignoresSafeArea()
            
        }
        
        
        
    }
}

#Preview {
   
    VideoSheetView(url: URL(string: "https://example.com/video.mp4")!, isCameraPresented: .constant(true) )
}
