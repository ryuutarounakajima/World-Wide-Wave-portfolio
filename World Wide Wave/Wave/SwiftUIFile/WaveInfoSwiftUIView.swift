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
    @State private var waveSize: String = ""
    @State private var selectedSize: String = ""
    @State private var isSizeSelect: Bool = false
    @State private var waveSizes: [(key: String, value: String)] = [ ("" , ""), ("Small" , "Small"), ("Chest-high" , "Chest-high"), ("Head-high", "Head-high"), ("Overhead", "Overhead"), ("Double", "Double"), ("Triple over", "Triple over")
    ]
    
    //Wave condition select
    @State private var waveCondition: String = ""
    @State private var selectedCondition: String = ""
    @State private var isConditionSelect: Bool = false
    @State private var waveConditions: [(key: String, value: String)] = [("", ""), ("Go home", "Go home"), ("Choppy", "Choppy"), ("Mushy", "Mushy"), ("Windy", "windy"), ("Clean", "Clean"), ("Glass", "Glass"), ("Rippable", "Rippable"), ("Barrels", "Barrels"), ("Peaky", "Peaky"), ("Gnarly", "Gnarly"), ("Close out", "Close out") ]
    
    //Swell
    @State private var swell: String = ""
    @State private var selectedSwell: String = ""
    @State private var isSwellSelected: Bool = false
    @State private var swells: [(key: String, value: String)] = [("", ""), ("N", "N"), ("NNE", "NNE"), ("NE", "NE"), ("ENE", "ENE"), ("E", "E"), ("ESE", "ESE"), ("SE", "SE"), ("SSE", "SSE"), ("S", "S"), ("SSW", "SSW"), ("SW", "SW"), ("WSW", "WSW"), ("W", "W"), ("WNW", "WNW"), ("NW", "NW"), ("NNW", "NNW")]
    
    //Winds
    @State private var wind: String = ""
    @State private var selectedWind: String = ""
    @State private var isWindSelected: Bool = false
    @State private var winds: [(key: String, value: String)] = [("Offshore", "Offshore"), ("Onshore" , "Onshore"), ("Side off", "Side off"), ("Side on", "Side on"), ("ClossShore", "ClossShore")]
    @State private var windStrengthValue: Double = 0.0
    
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
                        Form {
                            
                            //wave size section
                            Section(header: Button(action: {
                                isSizeSelect.toggle()
                            }){
                                Text("Size")
                                    .headerProminence(.increased)
                                    .modifier(SectionButtonModifier(isSelected: $isSizeSelect))
                                
                                
                            })
                            {
                                if isSizeSelect {
                                    Picker("", selection: $formData.selectedSize){
                                        ForEach(waveSizes, id: \.key) { size in
                                            Text(size.value).tag(size.key)
                                        }
                                    }
                                    .pickerStyle(.wheel)
                                    .labelsHidden()
                                    .onChange( of: formData.selectedSize) {
                                        waveSize = formData.selectedSize
                                        withAnimation{
                                            isSizeSelect = false
                                        }
                                    }
                                }
                                //Logged wave size
                                Text(formData.selectedSize)
                                    .font(.custom("AvenirNext-Bold", size: 14))
                                    .scaleEffect(1.2)
                                        .shadow(radius: 2)
                            }
                            
                            //wave condition section
                            Section(header:
                                        Button(action: {
                                isConditionSelect.toggle()
                            }){
                                Text("Conditon")
                                    .headerProminence(.increased)
                                    .modifier(SectionButtonModifier(isSelected: $isConditionSelect))
                            })
                            {
                                if isConditionSelect {
                                    Picker("", selection: $selectedCondition) {
                                        ForEach (waveConditions, id: \.key) { condition in
                                            Text(condition.value).tag(condition.key)
                                        }
                                    }.pickerStyle(.wheel)
                                        .labelsHidden()
                                        .onChange(of: selectedCondition) {
                                            waveCondition = selectedCondition
                                            
                                            withAnimation{
                                                isConditionSelect = false
                                            }
                                        }
                                }
                                
                                Text(waveCondition)
                                    .font(.custom("AvenirNext-Bold", size: 14))
                                    .scaleEffect(1.2)
                                        .shadow(radius: 2)
                            }
                            
                            //swell
                            Section(header:
                                        Button(action: {
                                            isSwellSelected.toggle()
                            }){
                                Text("swell")
                                    .headerProminence(.increased)
                                    .modifier(SectionButtonModifier(isSelected: $isSwellSelected))
                            })
                            {
                                if isSwellSelected {
                                    Picker("", selection: $selectedSwell) {
                                        ForEach(swells, id: \.key) { swell in
                                            Text(swell.value).tag(swell.key)
                                        }
                                    }
                                    .pickerStyle(.wheel)
                                    .labelsHidden()
                                    .onChange(of: selectedSwell) {
                                        swell = selectedSwell
                                        withAnimation {
                                            isSwellSelected = false
                                        }
                                    }
                                }
                                //Logged swell
                                Text(swell)
                                    .font(.custom("AvenirNext-Bold", size: 14))
                                    .scaleEffect(1.2)
                                        .shadow(radius: 2)
                            }
                            
                            //wind direction
                            Section(header:
                                        Button(action: {
                                isWindSelected.toggle()
                            }){
                                Text("Wind")
                                    .headerProminence(.increased)
                                    .modifier(SectionButtonModifier(isSelected: $isWindSelected))
                            })
                            {
                                if isWindSelected {
                                    Picker("", selection: $selectedWind) {
                                        ForEach(winds, id: \.key) {
                                            wind in
                                            Text(wind.value)
                                                .tag(wind.key)
                                        }
                                    }
                                    .pickerStyle(.wheel)
                                    .labelsHidden()
                                    .frame(maxWidth: .infinity)
                                    .onChange(of: selectedWind) {
                                        wind = selectedWind
                                        withAnimation{
                                            isWindSelected = false
                                        }
                                    }
                                }
                                    VStack {
                                        
                                        Text(wind)
                                            .font(.custom("AvenirNext-Bold", size: 14))
                                            .scaleEffect(1.2)
                                            .shadow(radius: 2)
                                        
                                        HStack {
                                            
                                            Text("Strength")
                                                .font(.custom("AvenirNext-Bold", size: 14))
                                                    .scaleEffect(0.8)
                                                    .shadow(radius: 2)
                                            
                                            Spacer()
                                            
                                            SliderModifier(value: $windStrengthValue, range: 0...100, gradient:  Gradient(colors: [.blue, .red]))
                                                
                                            
                                        }
                                        
                                        
                                    }
                            }
                            
                            //tide
                            Section(header: Button(action: {
                                isTideSelected.toggle()
                            }){
                                Text("Tide")
                                    .headerProminence(.increased)
                                    .modifier(SectionButtonModifier(isSelected: $isTideSelected))
                            })
                            {
                                if isTideSelected {
                                    Picker("", selection: $selectedTide) {
                                        ForEach(tides, id: \.key) {
                                            tide in
                                            Text(tide.value).tag(tide.key)
                                        }
                                    }
                                    .pickerStyle(.wheel)
                                    .labelsHidden()
                                    .frame(maxWidth: .infinity)
                                    .onChange(of: selectedTide) {
                                        tide = selectedTide
                                        withAnimation {
                                            isTideSelected = false
                                        }
                                    }
                                }
                                VStack {
                                    
                                    Text(tide)
                                        .font(.custom("AvenirNext-Bold", size: 14))
                                        .scaleEffect(1.2)
                                            .shadow(radius: 2)
                                    
                                    HStack {
                                        
                                        Text("Low tide")
                                            .font(.custom("AvenirNext-Bold", size: 14))
                                                .scaleEffect(0.8)
                                                .shadow(radius: 2)
                                        
                                        SliderModifier(value: $tideValue, range: 0...100, gradient: Gradient(colors:[.cyan, .yellow]))
                                        
                                        Text("High tide")
                                            .font(.custom("AvenirNext-Bold", size: 14))
                                                .scaleEffect(0.8)
                                                .shadow(radius: 2)
                                    }
                                    
                                }
                            }
                            
                            //Breaks and water depth
                            Section(header: Button(action: {
                                isBreaksSelected.toggle()
                            }){
                                Text("Break")
                                    .headerProminence(.increased)
                                    .modifier(SectionButtonModifier(isSelected: $isBreaksSelected))
                            })
                            {
                                if isBreaksSelected {
                                    Picker("", selection: $selectedBreaks) {
                                        ForEach(breakTipes, id: \.key) {
                                            breakTipe in
                                            Text(breakTipe.value)
                                                .tag(breakTipe.key)
                                        }
                                    }
                                    .pickerStyle(.wheel)
                                    .labelsHidden()
                                    .frame(maxWidth: .infinity)
                                    .onChange(of: selectedBreaks) {
                                        breakType = selectedBreaks
                                        withAnimation {
                                            isBreaksSelected = false
                                        }
                                    }
                                }
                                VStack {
                                    
                                    Text(breakType)
                                        .font(.custom("AvenirNext-Bold", size: 14))
                                        .scaleEffect(1.2)
                                            .shadow(radius: 2)
                                    
                                    HStack {
                                        
                                        Text("Depth")
                                            .font(.custom("AvenirNext-Bold", size: 14))
                                                .scaleEffect(0.8)
                                                .shadow(radius: 2)
                                        SliderModifier(value: $waterDepthValue, range: 0...100, gradient: Gradient(colors: [.brown, .cyan, .blue, .black]))
                                            
                                    }
                                    
                                }
                            }
                            
                            //Wax
                            Section(header:  Button(action: {
                                isWaxSeleted.toggle()
                            }){
                                Text("Wax")
                                    .headerProminence(.increased)
                                    .modifier(SectionButtonModifier(isSelected: $isWaxSeleted))
                            }) {
                                if isWaxSeleted {
                                    Picker("", selection: $selectedWax) {
                                        ForEach(waxes, id: \.key) {
                                            wax in Text(wax.value).tag(wax.key)
                                        }
                                    }.pickerStyle(.wheel)
                                        .labelsHidden()
                                        .onChange(of: selectedWax) {
                                            wax = selectedWax
                                            withAnimation {
                                                isWaxSeleted = false
                                            }
                                        }
                                }
                                VStack {
                                    Text(wax)
                                        .font(.custom("AvenirNext-Bold", size: 14))
                                        .scaleEffect(1.2)
                                            .shadow(radius: 2)
                                    
                                    HStack {
                                        
                                       Text("Water")
                                            .font(.custom("AvenirNext-Bold", size: 14))
                                            .scaleEffect(0.8)
                                            .shadow(radius: 2)
                                        
                                        SliderModifier(value: $waterTemperaturevalue, range: 0...100, gradient: Gradient(colors: [.white, .blue, .red]))
                                        
                                            
                                    }
                                }
                            }
                                //OverView and Forecast
                            Section(header: Text("Overview and Forcast")) {
                                ZStack(alignment: .topLeading) {
                                    if overviewText.isEmpty {
                                        Text("How the surf? It's your prediction!")
                                            .foregroundStyle(.gray)
                                            .padding(.top, 8)
                                            .padding(.leading, 4)
                                    }
                                    TextEditor(text: $overviewText)
                                }
                                }
                                //Your own surfing journal
                            Section(header: Text("Your own surfing journal")) {
                                ZStack(alignment: .topLeading) {
                                    if journal.isEmpty {
                                        Text("This journal will not be shared publicly on social media.")
                                            .foregroundStyle(.gray)
                                            .padding(.top, 8)
                                            .padding(.leading, 4)
                                    }
                                    TextEditor(text: $journal)
                                        
                                }
                                }
                            
                           
                                
                                
                        }
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.2), radius: 9, x: 3, y: 6)
                        
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
