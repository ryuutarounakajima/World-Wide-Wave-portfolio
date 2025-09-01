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
                
            })

        }
           
            
            
        
     
    }
}

#Preview {
    VideoPreview(player: AVPlayer(url: URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")!))
}
