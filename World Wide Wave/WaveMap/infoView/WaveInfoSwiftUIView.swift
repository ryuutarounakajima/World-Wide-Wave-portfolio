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
    
    @State private var overviewText: String = ""
    @State private var overviewTextHeight: CGFloat = 40
   
    @State private var journal: String = ""
    @State private var journalTextHeight: CGFloat = 40
                                    
    
    //Photo picker visible
    @State private var isPickerVisable: Bool = false
    @State private var cameraAutorized: Bool = false
   // @State private var captuteImage: UIImage?
    private let cameraManager = CameraManager()
    
    var coordinate: CLLocationCoordinate2D
    var timestamp: Date
    @State var selectedImage: UIImage?
    @State var selectedVideoURL: URL?
    
    @State var isCameraButtonRotating = false
    
    var body: some View {
        NavigationStack {
           
                GeometryReader { geometry in
                    VStack{
                        
                        let mediaHeight = geometry.size.height * 0.4
                        let mediaWidth =
                        geometry.size.width
                        
                        ScrollView(.horizontal, showsIndicators: true) {
                            HStack(spacing: 0) {
                                Image("Logo")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: mediaWidth, height: mediaHeight)
                                    .modifier(MediaFrameModifier())
                            }
                        }.frame(width: mediaWidth,height: mediaHeight)
                        /*
                        //Image select button
                        Button(action: {
                            Task {
                                cameraAutorized  = await cameraManager.requestCameraAccess()
                                if cameraAutorized {
                                    isPickerVisable.toggle()
                                }
                            }
                        }) {
                            if let image = formData.capturedImage{
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: geometry.size.width, height: geometry.size.height * 0.4)
                                    .clipped()
                                    
                                   // .modifier(MediaFrameModifier())
                                    
                            } else if let videoURL = formData.capturedVideoURL {
                                VideoPlayer(player: AVPlayer(url: videoURL))
                                    .scaledToFill()
                                    .frame(width: geometry.size.width, height: geometry.size.height * 0.4)
                                    .clipped()
                                   // .modifier(MediaFrameModifier())
                            } else {
                                Image("Logo")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: geometry.size.width, height: geometry.size.height * 0.4)
                                    
                                    .modifier(MediaFrameModifier())
                            }
                        }
                        .fullScreenCover(isPresented: $isPickerVisable) {
                            CameraSwiftUIPreview(isCameraPresented: $isPickerVisable, captureImage: $formData.capturedImage).environmentObject(formData)
                        }
                    */
                        
                        
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
                                    withAnimation(.easeInOut(duration: 0.2)){
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
                                                                       .stroke(Color.white, lineWidth: 2)
                                                               )
                                                               .shadow(color: .gray.opacity(0.6), radius: 5, x: 5, y: 5)
                                                               .scaleEffect(isRecordedButton ? 0.9 : 1.0) // ボタン押下時のアニメーション
                                                               .animation(.spring(response: 0.3, dampingFraction: 0.5, blendDuration: 0.5), value: isRecordedButton)
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
                                        
                                    }
                                } message:{
                                    Text("This will determine your future")
                                }
                                
                                Spacer()
                               
                            }
                            
                            
                            
                            
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        //.padding(.trailing)
                        //The time
                        //Text("\(timestamp)")
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
                                        
                                     isCameraButtonRotating.toggle()
                                    }
                                    cameraAutorized = await cameraManager.requestCameraAccess()
                                    
                                    if cameraAutorized {
                                        isPickerVisable.toggle()
                                    }
                                }
                            }) {
                                Image(systemName: "camera")
                                    .bold()
                                    .foregroundStyle(.cyan)
                                    .rotationEffect(.degrees(isCameraButtonRotating ? 360 : 0))
                            }
                        }
                    }
                    .fullScreenCover(isPresented: $isPickerVisable) {
                        CameraSwiftUIPreview(isCameraPresented: $isPickerVisable, captureImage: $formData.capturedImage).environmentObject(formData)
                    }
                    
            
               // .ignoresSafeArea()
                
             
          
    
        }
        
    }
    
}

#Preview {
    
    let mockCoordinate = CLLocationCoordinate2D(latitude: 35.6895, longitude: 139.6917)
    let mockTimestamp = Date()
    let formdata = FormData()
    WaveInfoSwiftUIView(coordinate: mockCoordinate, timestamp: mockTimestamp).environmentObject(formdata)
}
