//
//  Struct tools.swift
//  World Wide Wave
//
//  Created by Ryuutarou Nakajima on 2024/12/18.
//

import SwiftUI
import CoreLocation
import SwiftData

//Model
@Model
class SurfLog {
    var coordinateLat: Double?
    var coordinateLon: Double?
    var timestamp: Date?
    
    var selectedSize: String
    var selectedSize1: String
    var selectedSize2: String
    
    var selectedCondition: String
    var selectedSwell: String
    var selectedBreaks: String
    var selectedWind: String
    var selectedWindStrengthValue: Double
    var selectedTide: String
    var selectedTideValue: Double
    var selectedWax: String
    var waterTemperatureValue: Double
    
    var imageData: Data?
    var videoPath: String?
    
    init(
        coordinateLat: Double?,
        coordinateLon: Double?,
        timestamp: Date?,
        selectedSize: String = "",
        selectedSize1: String = "",
        selectedSize2: String = "",
        selectedCondition: String = "",
        selectedSwell: String = "",
        selectedBreaks: String = "",
        selectedWind: String = "",
        selectedWindStrengthValue: Double = 0.0,
        selectedTide: String = "",
        selectedTideValue: Double = 0.0,
        selectedWax: String = "",
        waterTemperatureValue: Double = 0.0,
        imageData: Data? = nil,
        videoPath: String? = nil
    ) {
        self.coordinateLat = coordinateLat
        self.coordinateLon = coordinateLon
        self.timestamp = timestamp
        self.selectedSize = selectedSize
        self.selectedSize1 = selectedSize1
        self.selectedSize2 = selectedSize2
        self.selectedCondition = selectedCondition
        self.selectedSwell = selectedSwell
        self.selectedBreaks = selectedBreaks
        self.selectedWind = selectedWind
        self.selectedWindStrengthValue = selectedWindStrengthValue
        self.selectedTide = selectedTide
        self.selectedTideValue = selectedTideValue
        self.selectedWax = selectedWax
        self.waterTemperatureValue = waterTemperatureValue
        self.imageData = imageData
        self.videoPath = videoPath
    }
}
class FormData: ObservableObject {
    
    @Published var coordinate: CLLocationCoordinate2D?
    @Published var timestamp: Date?
    
    @Published var selectedSize: String = ""
    @Published var selectedSize1: String = ""
    @Published var selectedSize2: String = ""
    
    @Published var selectedCondition: String = ""
    @Published var selectedSwell : String = ""
    @Published var selectedBreaks: String = ""
    @Published var selectedWind: String = ""
    @Published var selectedWindStrengthValue: Double = 0.0
    @Published var selectedTide: String = ""
    @Published var selectedTideValue: Double = 0.0
    @Published var selectedWax: String = ""
    @Published var waterTemperatureValue: Double = 0.0
    @Published var capturedImage: UIImage?
    @Published var capturedVideoURL: URL?
    
    func isFormValid() -> Bool {
        return !selectedSize.isEmpty && !selectedCondition.isEmpty && !selectedSwell.isEmpty && !selectedWind.isEmpty
    }
    
    func submitForm() {
        
        print("Form submitted with \(String(describing: coordinate)), \(String(describing: timestamp)),\(selectedSize1),\(selectedSize2), \(selectedCondition), \(selectedSwell),\(selectedBreaks),\(selectedWind), \(String(format: "%.1f", selectedWindStrengthValue)),\(selectedTide), \(String(format: "%.1f", selectedTideValue)), \(selectedWax),\(String(format: "%.1f", waterTemperatureValue))")
        
        if let image = capturedImage {
            print("image captured: \(image)")
        } else {
            print("no image captured")
        }
        
         if let videoURL = capturedVideoURL {
            print("video captured: \(videoURL)")
        } else {
            print("no video captured")
        }
    }
    
    func saveToSwifData(context: ModelContext) {
        
        let log = SurfLog(coordinateLat: coordinate?.latitude, coordinateLon: coordinate?.longitude, timestamp: timestamp,
                          selectedSize: selectedSize,
                          selectedSize1: selectedSize1,
                          selectedSize2: selectedSize2,
                          selectedCondition: selectedCondition,
                          selectedSwell: selectedSwell,
                          selectedBreaks: selectedBreaks,
                          selectedWind: selectedWind,
                          selectedWindStrengthValue: selectedWindStrengthValue,
                          selectedTide: selectedTide,
                          selectedTideValue: selectedTideValue,
                          selectedWax: selectedWax,
                          waterTemperatureValue: waterTemperatureValue,
                          imageData: capturedImage?.jpegData(compressionQuality: 0.8),
                          videoPath: capturedVideoURL?.absoluteString
                        )
        
        context.insert(log)
        
        do {
            try context.save()
            print("Surf log saved scccessfully")
        } catch {
            print("Falied to save: \(error)")
        }
        
        
    }
    
}
//View
struct CustomFormSection<Content: View>: View {
    
    var title: String
    var options: [(key: String, value: String)]
    var content: () -> Content
    
    @Binding var isSelected: Bool
    @Binding var selectedValue: String
    
    @EnvironmentObject var formData: FormData
    
    init(title: String, isSelected: Binding<Bool>, selectedValue: Binding<String>, options: [(key: String, value:String)],@ViewBuilder content: @escaping () -> Content) {
        
        self.title = title
        self._isSelected = isSelected
        self._selectedValue = selectedValue
        self.options = options
        self.content = content
    }
    
    var body: some View {
        Section(header: Button(action: {
            withAnimation{
                isSelected.toggle()
            }
        }) {
            Text(title)
                .headerProminence(.increased)
                .modifier(SectionButtonModifier(isSelected: $isSelected))
        }) {
            if isSelected {
                Picker("", selection: $selectedValue) {
                    ForEach(options, id: \.key) { option in
                        Text(option.value).tag(option.key)
                    }
                }
                .pickerStyle(.wheel)
                .labelsHidden()
                .onChange(of: selectedValue) {
                    upDateFormData()
                    withAnimation {
                        isSelected = false
                    }
                }
               
            }
            content()
        }
    }
    
    private func upDateFormData() {
        switch title {
        case "Size":
            formData.selectedSize = selectedValue
        case "Condition":
            formData.selectedCondition = selectedValue
        case "Swell":
            formData.selectedSwell = selectedValue
        case "Break type":
            formData.selectedBreaks = selectedValue
        case "Wind" :
            formData.selectedWind = selectedValue
        case "Tide":
            formData.selectedTide = selectedValue
        case "Wax":
            formData.selectedWax = selectedValue
        default:
            break
        }
    }
    
}

struct CustomFormSection2<Content: View>: View {
    
       var title: String
       var options: [(key: String, value: String)]
       var content: () -> Content
       
       @Binding var isSelected: Bool
       @Binding var selectedValue1: String
       @Binding var selectedValue2: String
       
       @EnvironmentObject var formData: FormData
       
       init(
           title: String,
           isSelected: Binding<Bool>,
           selectedValue1: Binding<String>,
           selectedValue2: Binding<String>,
           options: [(key: String, value: String)],
           @ViewBuilder content: @escaping () -> Content
       ) {
           self.title = title
           self._isSelected = isSelected
           self._selectedValue1 = selectedValue1
           self._selectedValue2 = selectedValue2
           self.options = options
           self.content = content
       }
    
    var body: some View {
        Section(header: Button(action: {
                   withAnimation {
                       isSelected.toggle()
                   }
               }) {
                   Text(title)
                       .headerProminence(.increased)
                       .modifier(SectionButtonModifier(isSelected: $isSelected))
               }) {
                   if isSelected {
                       HStack {
                           Picker("", selection: $selectedValue1) {
                               ForEach(options, id: \.key) { option in
                                   Text(option.value).tag(option.key)
                               }
                           }
                           .pickerStyle(.wheel)
                           .labelsHidden()
                           .onChange(of: selectedValue1) {
                               upDateFormData()
                           }
                           
                           Picker("", selection: $selectedValue2) {
                               ForEach(options, id: \.key) { option in
                                   Text(option.value).tag(option.key)
                               }
                           }
                           .pickerStyle(.wheel)
                           .labelsHidden()
                           .onChange(of: selectedValue2) {
                               
                               upDateFormData()
                               withAnimation {
                                   isSelected = false
                               }
                           }
                       }
                       .frame(height: 150) // 必要に応じてPicker高さ調整してください
                   }
                   content()
               }
    }
    
    private func upDateFormData() {
        switch title {
              case "Size":
                  formData.selectedSize1 = selectedValue1
                  formData.selectedSize2 = selectedValue2
              default:
                  break
              }    }
    
}
//View model
struct FormViewModel: View {
  
    @EnvironmentObject var formData: FormData
    //wave size select
    @Binding var isSizeSelect: Bool
    @State private var waveSizes: [(key: String, value: String)] = [ ("" , ""), ("go home" , "go home"), ("Waist-high", "Waist-high"), ("belly-high", "belly-high"), ("Chest-high" , "Chest-high"), ("Head-high", "Head-high"), ("Overhead", "Overhead"), ("Double", "Double"), ("Triple over", "Triple over")
    ]
    
    //wave conditon select
    @Binding var isConditionSelect: Bool
    @State private var waveCondtions: [(key: String, value: String)] = [("", ""), ("Go home", "Go home"), ("Choppy", "Choppy"), ("Mushy", "Mushy"), ("Windy", "windy"), ("Clean", "Clean"), ("Glass", "Glass"), ("Rippable", "Rippable"), ("Barrels", "Barrels"), ("Peaky", "Peaky"), ("Gnarly", "Gnarly"), ("Close out", "Close out") ]
    
    //swell
    @Binding var isSwellSelect: Bool
    @State private var swells: [(key: String, value: String)] = [("", ""), ("N", "N"), ("NNE" , "NNE"), ("NE", "NE"), ("ENE", "ENE"), ("E", "E"), ("ESE", "ESE"), ("SE", "SE"), ("SSE", "SSE"), ("S", "S"), ("SSW", "SSW"), ("SW", "SW"), ("WSW", "WSW"), ("W", "W"), ("WNW", "WNW"), ("NW", "NW") , ("NNW", "NNW")
    ]
    
    //breaks
    @Binding var isBreakSelect: Bool
    @State private var breaks: [(key: String, value: String)] = [((""), ("")), ("ShoreBreak", "Shorebreak"), ("Beachbreak", "Beachbreak"), ("Poindbreak", "Pointbreak"), ("Sandbar", "Sandbar"), ("Reef", "Reef")]
    
    //wind
    @Binding var isWindSelect: Bool
    @State private var winds: [(key: String, value: String)] = [("", ""), ("Offshore", "Offshore"), ("Onshore" , "Onshore"), ("Side off", "Side off"), ("Side on", "Side on"), ("ClossShore", "ClossShore")]
    
    //Tide
    @Binding  var isTideSelect: Bool
    @State private var tides: [(key: String, value: String)] = [
        ("", ""), ("Spring Tide", "Spring Tide"), ("Moderate Tide", "Moderate Tide"), ("Neap Tide", "Neap Tide"), ("Long Tide", "Long Tide"), ("Young Tide", "Young Tide")
    ]
    
    //Wax
    @Binding var isWaxSelect: Bool
    @State private var waxes:[(key: String, value: String)] = [("", ""), ("Cold", "Cold"), ("Cool", "Cool"), ("Warm", "Warm"), ("Tropical", "Tropical")]
    
    var body: some View {
        //info form
        Form {
            //wave size section
            CustomFormSection2(title: "Size", isSelected: $isSizeSelect, selectedValue1: $formData.selectedSize1, selectedValue2: $formData.selectedSize2, options: waveSizes) {
                Text("\(formData.selectedSize1) ~ \(formData.selectedSize2)")
                    .modifier(CustomFormTextModifier())
            }
        
            //wave condtion section
            CustomFormSection(title: "Conditon", isSelected: $isConditionSelect, selectedValue: $formData.selectedCondition, options: waveCondtions) {
                Text(formData.selectedCondition)
                    .modifier(CustomFormTextModifier())
            }

            //swell
            CustomFormSection(title: "Swell", isSelected: $isSwellSelect, selectedValue: $formData.selectedSwell, options: swells) {
                Text(formData.selectedSwell)
                    .modifier(CustomFormTextModifier())
            }
            
            //Breaks
            CustomFormSection(title: "Break type", isSelected: $isBreakSelect, selectedValue: $formData.selectedBreaks, options: breaks) {
                Text(formData.selectedBreaks)
                    .modifier(CustomFormTextModifier())
            }

            //wind
            CustomFormSection(title: "Wind", isSelected: $isWindSelect, selectedValue: $formData.selectedWind, options: winds) {
                VStack {
                    Text(formData.selectedWind)
                        .modifier(CustomFormTextModifier())
                    HStack {
                        Text("Strength")
                            .font(.custom("AvenirNext-Bold", size: 14))
                            .scaleEffect(0.8)
                            .shadow(radius: 2)
                        
                        Spacer()
                        
                        SliderModifier(value: $formData.selectedWindStrengthValue, range: 0...20, gradient: Gradient(colors:[.cyan, .red]))
                        
                        
                    }
                }
                
            }
            //tide
            CustomFormSection(title: "Tide", isSelected: $isTideSelect, selectedValue: $formData.selectedTide, options: tides) {
                VStack {
                    Text(formData.selectedTide)
                        .modifier(CustomFormTextModifier())
                    HStack {
                        Text("High & Low")
                            .font(.custom("AvenirNext-Bold",size: 14))
                            .scaleEffect(0.8)
                            .shadow(radius: 2)
                        
                        Spacer()
                        
                        SliderModifier(value: $formData.selectedTideValue, range: 0...3, gradient: Gradient(colors:[.brown,.yellow,.cyan,.blue]))
                    }
                }
            }
            //wax
            CustomFormSection(title: "Wax", isSelected: $isWaxSelect, selectedValue: $formData.selectedWax, options: waxes) {
                VStack {
                    Text(formData.selectedWax)
                        .modifier(CustomFormTextModifier())
                    HStack {
                        Text("Cold water??")
                            .font(.custom("AvenirNext-Bold", size: 14))
                            .scaleEffect(0.8)
                            .shadow(radius: 2)
                        
                        Spacer()
                        
                        SliderModifier(value: $formData.waterTemperatureValue, range: -10...36, gradient: Gradient(colors: [.white, .cyan, .orange]))
                    }
                }
            }
          
        }
    }
}
            
struct CustomFormTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom("AvenirNext-Bold", size: 14))
                        .scaleEffect(1.2)
                        .shadow(radius: 2)
    }
}

struct MediaPicker: View {
    @Binding var selectedImage: UIImage?
    @Binding var selectedVideoURL: URL?
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                HStack{
                    Spacer()
                    Button {
                        
                    } label: {
                        Image(systemName: "book")
                            .symbolRenderingMode(.palette)
                            .font(.system(size: geometry.size.width * 0.1))
                            .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.3)
                            .foregroundStyle(.green, .blue)
                            .background(Color.purple)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .bold()
                            .rotationEffect(.degrees(5))
                            .animation(.spring, value: UUID())
                    }
                    Spacer()

                    Button( action: {
                        
                    }) {
                        Image(systemName: "iphone.rear.camera")
                            .symbolRenderingMode(.palette)
                            .font(.system(size: geometry.size.width * 0.1))
                            .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.3)
                            .foregroundStyle(.brown, .black)
                            .background(Color.yellow)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .bold()
                            .scaleEffect(1.1)
                            .animation(.easeIn(duration: 0.5), value: UUID())
                        
                        
                    }
                    Spacer()
                    
                    
                    
                    Button( action: {
                        
                    }) {
                        Image(systemName: "video")
                            .symbolRenderingMode(.palette)
                            .font(.system(size: geometry.size.width * 0.1))
                            .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.3)
                            .foregroundStyle(.white, .gray)
                            .background(Color.brown)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .bold()
                            .opacity(0.8)
                            .rotationEffect(.degrees(-5))
                            .animation(.easeInOut(duration: 0.8), value: UUID())
                       
                    }
                    Spacer()
                    
                 
                    
                }
                Spacer()
            }
            
        }
       
    }
}

struct MediaFrameModifier: ViewModifier {
    
    var grayscaleAmount: Double = 0.7
    var cornerRadius: CGFloat = 10
    var shadowColor: Color = Color.black.opacity(0.2)
    var shadowRadius: CGFloat = 9
    var shadowOffsetX: CGFloat = 3
    var shadowOffsetY: CGFloat = 6
    
    func body(content: Content) -> some View {
        content
            .scaledToFill()
            .grayscale(grayscaleAmount)
            .cornerRadius(cornerRadius)
            .shadow(color: shadowColor, radius: shadowRadius, x: shadowOffsetX, y: shadowOffsetY)
           
    }
}

struct SectionButtonModifier: ViewModifier {
    
    @Binding var isSelected: Bool
    
    var shadowColor: Color = Color.black.opacity(0.4)
    var shadowRadius: CGFloat = 12
    var shadowOffsetX: CGFloat = 6
    var shadowOffsetY: CGFloat = 9
    
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .padding([.leading,.trailing])
            .background(.primary)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .shadow(color: shadowColor, radius: shadowRadius, x: shadowOffsetX, y: shadowOffsetY)
            .scaleEffect(isSelected ? 1.2 : 1)
            .animation(.easeInOut(duration: 0.3), value: isSelected)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.white, lineWidth: 3)
                    .scaleEffect(isSelected ? 1.2 : 1)
                    .animation(.easeInOut(duration: 0.3), value: isSelected)
            )
            .padding(.bottom, 10)
    }
}

struct SliderModifier: View {
    
    @Binding var  value: Double
    let range: ClosedRange<Double>
    let gradient: Gradient
    
    var body: some View {
        GeometryReader { geometry in
            
            let width = geometry.size.width
            let height = geometry.size.height
            let progress = CGFloat(value - range.lowerBound) / (range.upperBound - range.lowerBound)
            let handlePosition = width * progress
            
            ZStack {
                
                LinearGradient(gradient: gradient, startPoint: .leading, endPoint: .trailing)
                    .frame(height: height / 2 )
                    .cornerRadius(height / 2)
                    .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
                    
                    
                Circle()
                    .fill(Color.black)
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                    .frame(width: height, height: height / 2)
                    .position(x: handlePosition, y: height / 2)
                    .gesture(
                        DragGesture()
                            .onChanged {
                                drag in
                                let newValue = Double(drag.location.x / width) * (range.upperBound - range.lowerBound) + range.lowerBound
                                
                                value = min(max(newValue, range.lowerBound), range.upperBound)
                                
                                print(String(format: "%.1f", value))
                            }
                    )
                    .animation(.easeInOut(duration: 0.2), value: value)
                
            }
            

            
        }
       
        
    }
        
        
}

struct ExposureSlider: UIViewRepresentable {
    
    
    
    @Binding var value: Double
    
    func makeUIView(context: Context) -> UISlider {
        let slider = UISlider(frame: .zero)
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = Float(value)
        slider.minimumTrackTintColor = .orange
        slider.maximumTrackTintColor = .gray
       
        if let sunIcon = UIImage(systemName: "sun.max.fill")
            {
            let resized = sunIcon
                .withConfiguration(UIImage.SymbolConfiguration(pointSize: 25, weight: .regular))
                .withTintColor(.yellow, renderingMode: .alwaysOriginal)
            
            slider.setThumbImage(resized, for: .normal)
        }
        
        slider.addTarget(context.coordinator, action: #selector(Coordinator.valueChanged(_:)), for: .valueChanged)
        
        return slider
        
    }
    
    func updateUIView(_ uiView: UISlider, context: Context) {
        uiView.value = Float(value)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(value: $value)
    }
    
    class Coordinator: NSObject {
        var value: Binding<Double>
        init(value: Binding<Double>) {
            self.value = value }
        
        @objc func valueChanged(_ sender: UISlider) {
            self.value.wrappedValue = Double(sender.value)
        }
    }
}

struct CaptureButtonView: View {
    var mode: captureMode
    var isRecording: Bool
    var progress: CGFloat
    
    var body: some View {
        Circle()
            .fill(mode == .video ? Color.red : Color.white)
            .frame(width: 50, height: 50)
            .overlay(
                Circle().stroke(
                                   mode == .photo
                                       ? LinearGradient(
                                           colors: [Color.red.opacity(1.0), Color.blue.opacity(0.9)],
                                           startPoint: .top, endPoint: .bottom
                                         )
                                       : LinearGradient(
                                           colors: [Color.blue.opacity(1.0), Color.red.opacity(0.9)],
                                           startPoint: .top, endPoint: .bottom
                                         ),
                                   lineWidth: 6
                               )
                               .padding(-10)
            )
            .overlay(
                RecordingProgressRing(progress: progress)
                    .opacity(mode == .video && isRecording ? 1 : 0)
            )
        
    }
}
struct RecordingProgressRing: View {
    
    var progress : CGFloat
    
    var body: some View {
        Circle()
            .trim(from: 0, to: progress)
            .stroke(Color.green,
                    style: StrokeStyle(lineWidth: 6, lineCap: .butt))
            .rotationEffect(.degrees(-90))
            .frame(width: 56, height: 56)
           //.animation(.linear(duration: 31), value: progress)
            
    }
}
//form view preview
#Preview {
    
    struct FormViewPreview: View {
        @State private var isSizeSelect = false
        @State private var isConditionSelect = false
        @State private var isSwellSelect = false
        @State private var isBreakSelect = false
        @State private var isWindSelect = false
        @State private var isTideSelect = false
        @State private var isWaveSelect = false
        
        @StateObject private var formData = FormData()

        var body: some View {
            FormViewModel(isSizeSelect: $isSizeSelect, isConditionSelect: $isConditionSelect, isSwellSelect: $isSwellSelect, isBreakSelect: $isBreakSelect, isWindSelect: $isWindSelect, isTideSelect: $isTideSelect, isWaxSelect: $isWaveSelect)
                .environmentObject(formData)
        }
    }
    return FormViewPreview()
}

//Media picker button preview
/*struct MediaPickerButtonPreview: PreviewProvider {
   @State static var selectedURL: URL? = nil
   @State static var selectedUImage: UIImage? = nil
    
    static var previews: some View {
        MediaPicker(selectedImage: $selectedUImage, selectedVideoURL: $selectedURL)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
*/
//Horizontal drag slider animation effect preview
/*#Preview {
    struct sliderPreview: View {
        @State private var sliderValue: Double = 0.0
        let range = 0.0...100.0
        let gradient = Gradient(colors: [.blue, .red])
        
        var body: some View {
            VStack {
                SliderModifier(value: $sliderValue, range: range, gradient: gradient)
                Text("\(sliderValue)")
            }
        }
    }
    return sliderPreview()
    
}
*/
