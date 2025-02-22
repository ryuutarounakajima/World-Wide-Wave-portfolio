//
//  VideoSwiftUIPreview.swift
//  World Wide Wave
//
//  Created by Ryutarou Nakajima on 2025/02/16.
//

import SwiftUI

struct VideoSwiftUIPreview: View {
    @State private var isPresented: Bool = false
    @State private var videoURL: URL?
    
    var body: some View {
        ZStack {
            videoPreviewView(isPresented: $isPresented, videoURL: $videoURL)
        }
        .ignoresSafeArea(.all)
    }
}

#Preview {
    VideoSwiftUIPreview()
}
