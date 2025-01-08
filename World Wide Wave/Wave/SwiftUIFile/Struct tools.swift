//
//  Struct tools.swift
//  World Wide Wave
//
//  Created by Ryuutarou Nakajima on 2024/12/18.
//

import SwiftUI
//view model
class FormData: ObservableObject {
    @Published var selectedSize: String = ""
    @Published var selectedCondition: String = ""
    @Published var selectedSwell : String = ""
    @Published var selectedWind: String = ""
    @Published var selectedWindStrengthValue: Double = 0
    
    func isFormValid() -> Bool {
        return !selectedSize.isEmpty && !selectedCondition.isEmpty && !selectedSwell.isEmpty && !selectedWind.isEmpty
    }
    
    func submitForm() {
        print("Form submitted with \(selectedSize), \(selectedCondition), \(selectedSwell), \(selectedWind), \(selectedWindStrengthValue)")
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
        case "Wind" :
            formData.selectedWind = selectedValue
        default:
            break
        }
    }
    
}


struct FormViewModel: View {
  
    @EnvironmentObject var formData: FormData
    //wave size select
    @Binding var isSizeSelect: Bool
    @State private var waveSize: String = ""
    @State private var waveSizes: [(key: String, value: String)] = [ ("" , ""), ("Small" , "Small"), ("Chest-high" , "Chest-high"), ("Head-high", "Head-high"), ("Overhead", "Overhead"), ("Double", "Double"), ("Triple over", "Triple over")
    ]
    
    //wave conditon select
    @Binding var isConditionSelect: Bool
    @State private var waveCondition: String = ""
    @State private var waveCondtions: [(key: String, value: String)] = [("", ""), ("Go home", "Go home"), ("Choppy", "Choppy"), ("Mushy", "Mushy"), ("Windy", "windy"), ("Clean", "Clean"), ("Glass", "Glass"), ("Rippable", "Rippable"), ("Barrels", "Barrels"), ("Peaky", "Peaky"), ("Gnarly", "Gnarly"), ("Close out", "Close out") ]
    
    //swell
    @Binding var isSwellSelect: Bool
    
    @State private var swells: [(key: String, value: String)] = [("", ""), ("Small", "Small"), ("Chest-high" , "Chest-high"), ("Head-high", "Head-high"), ("Overhead", "Overhead"), ("Double", "Double"), ("Triple over", "Triple over")
    ]
    
    //wind
    @Binding var isWindSelect: Bool
    @State private var wind: String = ""
    @State private var winds: [(key: String, value: String)] = [("", ""), ("Offshore", "Offshore"), ("Onshore" , "Onshore"), ("Side off", "Side off"), ("Side on", "Side on"), ("ClossShore", "ClossShore")]
    
    var body: some View {
        //info form
        Form {
            //wave size section
            CustomFormSection(title: "Size", isSelected: $isSizeSelect, selectedValue: $formData.selectedSize, options: waveSizes) {
                Text(formData.selectedSize)
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
                        
                        SliderModifier(value: $formData.selectedWindStrengthValue, range: 0...100, gradient: Gradient(colors:[.blue, .red]))
                        
                        
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
    var shadowOffsetX: CGFloat = 5
    var shadowOffsetY: CGFloat = 10
    
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
                                
                                print("\(value)")
                            }
                    )
                    .animation(.easeInOut(duration: 0.2), value: value)
                
            }
            

            
        }
       
        
    }
        
        
}
//form view preview
#Preview {
    struct FormViewPreview: View {
        @State private var isSizeSelect = false
        @State private var isConditionSelect = false
        @State private var isSwellSelect = false
        @State private var isWindSelect = false
        @StateObject private var formData = FormData()

        var body: some View {
            FormViewModel(isSizeSelect: $isSizeSelect, isConditionSelect: $isConditionSelect, isSwellSelect: $isSwellSelect, isWindSelect: $isWindSelect)
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
