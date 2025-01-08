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




struct WaveInfoSwiftUIView: View {
    
    @StateObject  var formData: FormData
   
    //Wave size select
    @State private var isSizeSelect: Bool = false
    
    
    //Wave condition select
    @State private var isConditionSelect: Bool = false
    
    //Swell
    @State private var isSwellSelected: Bool = false
   
    
    //Winds
    @State private var isWindSelected: Bool = false
    
    
    //Tide
    @State private var tide: String = ""
    @State private var selectedTide: String = ""
    @State private var isTideSelected: Bool = false
    @State private var tides: [(key: String, value: String)] = [
        ("", ""), ("Spring Tide", "Spring Tide"), ("Moderate Tide", "Moderate Tide"), ("Neap Tide", "Neap Tide"), ("Long Tide", "Long Tide"), ("Young Tide", "Young Tide")
    ]
    @State private var tideValue: Double = 0.0
    
    //Breaks and water depth
    @State private var breakType: String = ""
    @State private var selectedBreaks: String = ""
    @State private var isBreaksSelected: Bool = false
    @State private var breakTipes: [(key: String, value: String)] = [((""), ("")), ("ShoreBreak", "Shorebreak"), ("Beachbreak", "Beachbreak"), ("Poindbreak", "Pointbreak"), ("Sandbar", "Sandbar"), ("Reef", "Reef")]
    @State private var waterDepthValue: Double = 0.0
    
    //Wax
    @State private var wax: String = ""
    @State private var selectedWax: String = ""
    @State private var isWaxSeleted = false
    @State private var waterTemperaturevalue: Double = 0.0
    @State private var waxes: [(key: String, value: String)] = [("", ""), ("Cold", "Cold"), ("Cool", "Cool"), ("Warm", "Warm"), ("Tropical", "Tropical")]
    
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
    @State private var captuteImage: UIImage?
    private let cameraManager = CameraManager()
    
    var coordinate: CLLocationCoordinate2D
    var timestamp: Date
    @State var selectedImage: UIImage?
    @State var selectedVideoURL: URL?
    
    var body: some View {
        NavigationView {
           
                GeometryReader { geometry in
                    VStack{
                        
                        //Image select button
                        Button(action: {
                            Task {
                                cameraAutorized  = await cameraManager.requestCameraAccess()
                                if cameraAutorized {
                                    isPickerVisable.toggle()
                                }
                            }
                        }) {
                            if let image = captuteImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: geometry.size.width * 1.0, height: geometry.size.height * 0.4)
                                    .modifier(MediaFrameModifier())
                                    
                            } else if let videoURL = selectedVideoURL {
                                VideoPlayer(player: AVPlayer(url: videoURL))
                                    .modifier(MediaFrameModifier())
                            } else {
                                Image("Logo")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: geometry.size.width * 1.0, height: geometry.size.height * 0.4)
                                    .modifier(MediaFrameModifier())
                            }
                        }
                        .fullScreenCover(isPresented: $isPickerVisable) {
                            CameraPreviewView(captureImage: $captuteImage, isCameraPresented: $isPickerVisable)
                        }
                        /*.sheet(isPresented: $isPickerVisable) {
                            MediaPicker(selectedImage: $selectedImage, selectedVideoURL: $selectedVideoURL)
                                .presentationDetents([.fraction(0.25)])
                                .presentationDragIndicator(.visible)
                        */
                            

                        
                        //info form
                        
                            FormViewModel(isSizeSelect: $isSizeSelect, isConditionSelect: $isConditionSelect, isSwellSelect: $isSwellSelected, isWindSelect: $isWindSelected)
                                .environmentObject(formData)
                        
                        //.cornerRadius(20)
                        //.shadow(color: .black.opacity(0.2), radius: 9, x: 3, y: 6)
                        
                        //locations
                        VStack {
                            
                            HStack {
                                
                                
                                Spacer()
                                VStack {
                                    
                                    Text("latitude: \(coordinate.latitude)")
                                    
                                    Text("longitude:\(coordinate.longitude)")
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
                                        formData.submitForm()
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
                                    Button("Yes") {
                                        print("Yes")
                                        print("You are optimistic person from now!!")
                                    }
                                    Button("Yes") {
                                        print("Yes")
                                        print("You are optimistic person from now!!")
                                        
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
                    
                }
                .frame(maxHeight: .infinity)
                .ignoresSafeArea()
                
             
          
    
        }
        
    }
    
}

#Preview {
    
    let mockCoordinate = CLLocationCoordinate2D(latitude: 35.6895, longitude: 139.6917)
    let mockTimestamp = Date()
    let formdata = FormData()
    WaveInfoSwiftUIView(formData: formdata, coordinate: mockCoordinate, timestamp: mockTimestamp)
}
