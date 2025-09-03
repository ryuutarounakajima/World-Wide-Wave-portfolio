//
//  VideoPreview.swift
//  World Wide Wave
//
//  Created by Ryutarou Nakajima on 2025/02/25.
//

import SwiftUI
import AVKit

struct VideoPreview: View {
    
    let player: AVPlayer
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var formData: FormData
    @State private var navigateToInfo = false
    var body: some View {
        
        NavigationView {
            VStack {
                
                VideoPlayer(player: player)
                    .edgesIgnoringSafeArea(.all)
                    .onAppear(
                        perform: player.play
                    )
            }
            .navigationBarItems(leading: Button("back") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("save video") {
                
                if let currentItem = player.currentItem, let asset = currentItem.asset as? AVURLAsset {
                    formData.capturedVideoURL = asset.url
                    
                    
                    //Dispatchqueue??
                    
                    //presentationMode.wrappedValue.dismiss()
                    
                    navigateToInfo = true

                } else {
                    print("no url found")
                }
            })
            .navigationDestination(isPresented: $navigateToInfo) {
                    
            
        }
     
        }
           
            
            
        
     
    }
}

#Preview {
    VideoPreview(player: AVPlayer(url: URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")!))
}
