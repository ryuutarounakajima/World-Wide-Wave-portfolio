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
    @State private var isButtonOpen: Bool = false
    
    var body: some View {
        
        VStack(spacing: 12) {
           
                
       
            GeometryReader { geo in
                PhotosPicker(selection: $selectedItem, matching: .images) {

                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(.systemGray6))

                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(
                                    width: min(geo.size.width, geo.size.height) * 0.5,
                                    height: min(geo.size.width, geo.size.height) * 0.5
                                )
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: geo.size.height * 0.35))
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(height: UIScreen.main.bounds.height * 0.35) // ← ここで固定
            .clipped()

            
            Form {
                
                CustomFormSection5(title: "Name", isSelected: $isButtonOpen) {
                    
                    TextField("name", text: $userName)
                        .textFieldStyle(.automatic)
                }
                
                
            }
      
            Button("save") {
                let userInfo = userData.first ?? UserData()
                
                userInfo.userName = userName
                
                if let image = selectedImage {
                    userInfo.imageData = image.jpegData(compressionQuality: 0.75)
                }
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
            
            Spacer()
        }
        .onAppear {
           
            if let existing = userData.first {
                userName = existing.userName ?? ""
            
                if let data = existing.imageData,
                   let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                }
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: UserData.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    let context = container.mainContext

    let mockUser = UserData(
        userName: "Preview User",
        imageData: UIImage(systemName: "person.crop.circle")?
            .jpegData(compressionQuality: 1.0)
    )

    context.insert(mockUser)

    return MyPageView()
        .modelContainer(container)
}
