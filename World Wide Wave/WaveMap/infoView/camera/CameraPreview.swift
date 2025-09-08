//
//  ImagePreview.swift
//  World Wide Wave
//
//  Created by Ryuutarou Nakajima on 2025/02/24.
//

import SwiftUI

struct CameraPreview: View {

    var image : UIImage
    var onCameraDismissed: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    
    var body: some View {
        
       
        NavigationStack {
            VStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationBarItems(leading: Button("back") {
                onCameraDismissed()
               // presentationMode.wrappedValue.dismiss()
                
            },
                                trailing: Button ("save photo") {
               
                onCameraDismissed()
            })
        }
    }
}

#Preview {
    CameraPreview(image: UIImage(systemName: "photo") ?? UIImage()) {
        print("Cameradismissed!")
    }
}
