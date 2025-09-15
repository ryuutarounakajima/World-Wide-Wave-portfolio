//
//  PhotoSheetView.swift
//  World Wide Wave
//
//  Created by Ryuutarou Nakajima on 2025/09/14.
//

import SwiftUI

struct PhotoSheetView: View {
    
    var image: UIImage
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var formData: FormData
    
    var body: some View {
        
        ZStack {
            Color.black.ignoresSafeArea()
            
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
    }
}

#Preview {
    let image = UIImage(systemName: "photo")!
    PhotoSheetView(image: image)
}
