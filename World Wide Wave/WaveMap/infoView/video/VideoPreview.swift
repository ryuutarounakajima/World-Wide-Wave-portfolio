//
//  VideoPreview.swift
//  World Wide Wave
//
//  Created by Ryutarou Nakajima on 2025/02/25.
//

import SwiftUI
import AVKit
import CoreLocation

struct VideoPreview: View {
    
    let player: AVPlayer
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var formData: FormData
    @State private var navigateToInfo = false
    var body: some View {
        
        NavigationStack {
            VStack {
                
                VideoPlayer(player: player)
                    .edgesIgnoringSafeArea(.all)
                    .onAppear(
                        perform: player.play
                    )
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("back") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save video") {
                        
                        if let currentItem = player.currentItem,
                           let asset = currentItem.asset as? AVURLAsset {
                            formData.capturedVideoURL = asset.url
                            navigateToInfo = true
                            
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToInfo) {
                WaveInfoSwiftUIView(
                    coordinate: formData.coordinate ?? .init(latitude: 0, longitude: 0),
                    timestamp: formData.timestamp ?? Date()
                )
                .environmentObject(formData)
                
                
                
                
                
            }
            
        }
    }
}
#Preview {
    VideoPreview(player: AVPlayer(url: URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")!)).environmentObject(FormData())
    
}
