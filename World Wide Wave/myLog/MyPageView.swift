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
                                    width: max(geo.size.width, geo.size.height) * 0.6,
                                    height: max(geo.size.width, geo.size.height) * 0.7
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
        .onChange(of: selectedItem) { _, newItem in
              Task {
                  if let data = try? await newItem?.loadTransferable(type: Data.self),
                     let image = UIImage(data: data) {
                      selectedImage = image
                  }
              }
          }
    }
}

#Preview {
    let schema = Schema([UserData.self])
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    
    let container : ModelContainer
    do {
        container = try ModelContainer(for: schema, configurations: [configuration])
    } catch {
        print("Preview ModelContainer init error:", error)
        return Text("Preview failed to create ModelContainer: \(error.localizedDescription)")
            .padding()
    }
    
    
   

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
