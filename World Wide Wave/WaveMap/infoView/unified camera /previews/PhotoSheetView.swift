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
    @Binding var isCameraPresented: Bool
    
    var body: some View {
        NavigationStack {
            GeometryReader {
                geo in
                ZStack {
                    Color.white.ignoresSafeArea()
                    
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                    
                    
                    
                    
                }
            }
           
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        formData.capturedImage = image
                        dismiss()
                        isCameraPresented = false
                    }
                    .font(.headline)
                    .bold()
                    .foregroundStyle(.brown)
                }
            }
                    }
       
    }
    
}
#Preview {
    let image = UIImage(systemName: "photo")!
    PhotoSheetView(image: image, isCameraPresented: .constant(true))
}
