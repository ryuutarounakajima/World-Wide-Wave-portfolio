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
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    let image = UIImage(systemName: "photo")!
    PhotoSheetView(image: image)
}
