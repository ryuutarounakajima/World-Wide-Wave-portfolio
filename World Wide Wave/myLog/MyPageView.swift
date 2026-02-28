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
    @Query private var logs: [SurfLog2]
    @State private var userName = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var isButtonOpen: Bool = false
    @State private var showSaveSuccess: Bool = false
    @State private var showDeleteSuccess: Bool = false
    @State private var showDeleteConfirm: Bool = false
    @FocusState private var isNameFocused: Bool
    
    private func deleteUser() {
        
        for user in userData {
            modelContext.delete(user)
        }
        
        for log in logs {
            modelContext.delete(log)
        }
        
        do {
            try modelContext.save()
            
            print("User data and log deleted")
            showDeleteSuccess = true
        } catch {
            print("Delte user data error: \(error)")
        }
    }
    
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
            .frame(height: UIScreen.main.bounds.height * 0.35)
            .clipped()

            
            
                
            CustomFormSection5(title: "Name", isSelected: $isButtonOpen) {
                
                TextField("name", text: $userName)
                    .textFieldStyle(.automatic)
                    .submitLabel(.done)
                    .focused($isNameFocused)
            }
                
                
            Spacer()
      
            HStack(spacing: 20) {
                // Save button (blue)
                Button(action: {
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
                        showSaveSuccess = true
                        print("User name is \(userInfo.userName ?? "Surfing Ailean")")
                    } catch {
                        print("save error", error)
                    }
                }) {
                    Text("save")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: UIScreen.main.bounds.width * 0.33)
                        .frame(height: 44)
                        .background(Color.blue)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(radius: 3)
                }

                // Delete button (red)
                Button(role: .destructive) {
                   // deleteUser()
                    showDeleteConfirm = true
                } label: {
                    Text("Delete Account")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: UIScreen.main.bounds.width * 0.33)
                        .frame(height: 44)
                        .background(Color.red)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(radius: 3)
                }
            }
            .padding(.horizontal)
            
            
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
        .onAppear {
            // Auto-focus the name field so the keyboard shows immediately
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isNameFocused = true
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
        .alert("Saved successfully", isPresented: $showSaveSuccess) {
            Button("OK", role: .cancel) {}
        }
        .alert("Deleted successfully", isPresented: $showDeleteSuccess) {
            Button("OK", role: .cancel) {}
        }
        .alert("Delete Account?", isPresented: $showDeleteConfirm) {
            
            Button("Cancel", role: .cancel) {
                
            }
            Button("Delete", role: .destructive) {
                deleteUser()
            }
        } message: {
            Text("This will permanently delete your account and all surf logs. This action cannot be undone.")
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

