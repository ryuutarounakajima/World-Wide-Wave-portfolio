//
//  WaveInfoSwiftUI.swift
//  World Wide Wave
//
//  Created by Ryuutarou Nakajima on 2024/12/02.
//

import SwiftUI
import MapKit
import CoreLocation
import AVKit
import SwiftData
import UIKit


/*extension UIImage {
    func fixedOrientation() -> UIImage {
        
        guard self.imageOrientation != .up else {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        self.draw(in: CGRect(origin: .zero, size: size))
        let nomalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return nomalizedImage ?? self
    }
}*/

struct WaveInfoSwiftUIView: View {
    
    @EnvironmentObject  var formData: FormData
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    //Wave size select
    @State private var isSizeSelect: Bool = false
    //Wave condition select
    @State private var isConditionSelect: Bool = false
    //Swell
    @State private var isSwellSelected: Bool = false
    //break
    @State private var isBreakSelected: Bool = false
    //Winds
    @State private var isWindSelected: Bool = false
    //Tide
    @State private var isTideSelected: Bool = false
    //Wax
    @State private var isWaxSeleted: Bool = false
    
    
    
    
    
    //Record button
    @State private var isRecordedButton = false
    @State private var showAlert: Bool = false
    @State private var isBlinking = false
    
    
    @State private var overviewText: String = ""
    @State private var overviewTextHeight: CGFloat = 40
   
    @State private var journal: String = ""
    @State private var journalTextHeight: CGFloat = 40
                                    
    
    //camera actiive properties
    private let cameraManager = CameraManager()
    private let micManager = MicManager()
    @State private var cameraAutorized: Bool = false
    @State private var micAutorized: Bool = false
    @State private var mode: captureMode = .photo
    @State private var isCameraVsiable: Bool = false
    
    //formData properties
    var coordinate: CLLocationCoordinate2D
    var timestamp: Date
    @State private var selectedImage: UIImage?
    @State private var selectedVideoURL: URL?
    
    @State var cameraButtonColoring = false
    
    var body: some View {
        NavigationStack {
                GeometryReader { geometry in
                    VStack{
                        
                        let mediaHeight = geometry.size.height * 0.4
                        let mediaWidth =
                        geometry.size.width
                        
                        ScrollView(.horizontal, showsIndicators: true) {
                            HStack(spacing: 0) {
                                if formData.capturedImage == nil && formData.capturedVideoURL == nil {
                                    
                                    Image("Logo")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: mediaWidth, height: mediaHeight)
                                        .modifier(MediaFrameModifier())
                                    
                                }
                                
                                if let image = formData.capturedImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: mediaWidth, height: mediaHeight)
                                        .clipped()
                                        
                                }
                                
                                if let videoURL = formData.capturedVideoURL {
                                    VideoPlayer(player: AVPlayer(url: videoURL))
                                        .scaledToFill()
                                        .frame(width: mediaWidth, height: mediaHeight)
                                        .clipped()
                                        
                                }
                                
                            }
                        }.frame(width: mediaWidth,height: mediaHeight)
                    
                        /*.sheet(isPresented: $isPickerVisable) {
                            MediaPicker(selectedImage: $selectedImage, selectedVideoURL: $selectedVideoURL)
                                .presentationDetents([.fraction(0.25)])
                                .presentationDragIndicator(.visible)
                        */
                        //info form
                        FormViewModel(isSizeSelect: $isSizeSelect, isConditionSelect: $isConditionSelect, isSwellSelect: $isSwellSelected, isBreakSelect: $isBreakSelected, isWindSelect: $isWindSelected, isTideSelect: $isTideSelected, isWaxSelect: $isWaxSeleted)
                                .environmentObject(formData)
                        
                        
                        //.cornerRadius(20)
                        //.shadow(color: .black.opacity(0.2), radius: 9, x: 3, y: 6)
                        
                        //locations
                        VStack {
                            
                            HStack {
                                
                                Spacer()
                                
                                VStack {
                                    
                                    Text("latitude: \(formData.coordinate? .latitude ?? 0.0)")
                                    Text("longitude:\(formData.coordinate? .longitude ?? 0.0)")
                                }
                                
                                Spacer()
                                //Recorded button
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 1.2)){
                                        isRecordedButton.toggle()
                                       
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        withAnimation(.easeInOut(duration: 0.2)){
                                            isRecordedButton.toggle()
                                        }
                                        showAlert = true
                                    } 
                                }) {
                                    Image("Logo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: geometry.size.width * 0.1, height: geometry.size.height * 0.1)
                                        .background(.cyan.opacity(0.3))
                                        .clipShape(Circle())
                                        .shadow(radius: 3, x: 5, y: 5)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: 2))
                                        .shadow(color: .gray.opacity(0.6), radius: 5, x: 5, y: 5)
                                        .scaleEffect(isRecordedButton ? 1.5 : 1.0)
                                        .opacity(isBlinking ? 0.2 : 1.0)
                                    
                                }
                                .onReceive(formData.$capturedImage) {_ in updateBlinking()}
                                .onReceive(formData.$capturedVideoURL) {_ in updateBlinking()}
                                .onAppear {
                                    updateBlinking()
                                }
                                .alert("Are you an optimistionist?", isPresented: $showAlert) {
                                    Button("Yes,but not goona save my data") {
                                        print("Yes")
                                        print("You are optimistic person from now!!")
                                    }
                                    Button("Yes") {
                                        
                                        print("Yes")
                                        print("You are optimistic person from now!!")
                                        
                                        formData.submitForm()
                                        
                                        let success = formData.saveToSwifData(context: modelContext)
                                        
                                        if success {
                                            formData.resetFormData()
                                            switchToFirstTab()
                                            dismiss()
                                        }
                                        
                                    }
                                } message:{
                                    Text("This will determine your future")
                                }
                                Spacer()
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding([.leading, .trailing, .bottom])
                    }
                    .frame(maxHeight: .infinity)
                    }
                    .ignoresSafeArea()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                Task {
                                    
                                    print("camera open")
                                   
                                    withAnimation(.spring()) {
                                        
                                     //isCameraButtonRotating.toggle()
                                    }
                                    
                                    cameraAutorized = await cameraManager.requestCameraAccess()
                                    
                                    micAutorized = await
                                    micManager.requestMicAccess()
                                    
                                    if cameraAutorized && micAutorized {
                                       // isPickerVisable.toggle()
                                       
                                        isCameraVsiable = true
                                        
                                    } else {
                                        print("permission denied")
                                    }
                                }
                            }) {
                                Image(systemName: "camera.circle")
                                    .bold()
                                    .font(.system(size: 36))
                                    .foregroundStyle(cameraButtonColoring ? .cyan : .indigo)
                                    .rotationEffect(.degrees(cameraButtonColoring ? 360 : 0))
                                    .onAppear {
                                        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)){
                                            cameraButtonColoring.toggle()
                                        }
                                    }
                            }
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                dismiss()
                            }) {
                                HStack {
                                    Image(systemName: "chevron.left")
                                    Text("Back")
                                }
                                
                            }
                        }
                    }
                    .navigationDestination(isPresented: $isCameraVsiable) {
                        UnifiedCameraSwiftUIView( isCameraPresented: $isCameraVsiable)
                            .environmentObject(formData)
                    }
        }
    }
    
    private func updateBlinking() {
        
        if formData.capturedImage != nil || formData.capturedVideoURL != nil {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isBlinking = true
            }
        } else {
            withAnimation(.easeInOut(duration: 0.2)) {
                isBlinking = false
            }
        }
    }
    
    private func switchToFirstTab() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first,
              let tabBar = window.rootViewController as? UITabBarController else {
            return
        }
        tabBar.selectedIndex = 0
    }
}

#Preview {
    
    let mockCoordinate = CLLocationCoordinate2D(latitude: 35.6895, longitude: 139.6917)
    let mockTimestamp = Date()
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let modelContainer = try! ModelContainer(for: SurfLog2.self, configurations: config)
    let formdata = FormData()
    
    WaveInfoSwiftUIView(coordinate: mockCoordinate, timestamp: mockTimestamp)
        .environmentObject(formdata)
        .modelContainer(modelContainer)
}
