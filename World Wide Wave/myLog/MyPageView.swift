//
//  myPageView.swift
//  World Wide Wave
//
//  Created by Ryuutarou Nakajima on 2026/01/24.
//

import SwiftUI
import SwiftData
import PhotosUI

struct MyPageView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var userData: [UserData]
    
    @State private var userName = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    
    var body: some View {
        VStack {
            
            PhotosPicker( selection: $selectedItem, matching: .images) {
                
             
            }
            
            TextField("name", text: $userName)
                .textFieldStyle(.automatic)
            
            Button("save") {
                let userInfo = userData.first ?? UserData()
                
                userInfo.userName = userName
                
                if userData.isEmpty {
                    modelContext.insert(userInfo)
                }
                
                do {
                    try modelContext.save()
                    print("User name is \(userInfo.userName ?? "Ailean")")
                } catch {
                    print("save error", error)
                }
                
            }
        }
        .onAppear {
           
            if let existing = userData.first {
                userName = existing.userName ?? ""
            }
        }
    }
}

#Preview {
    MyPageView()
}
