//
//  Struct tools.swift
//  World Wide Wave
//
//  Created by Ryuutarou Nakajima on 2024/12/18.
//

import SwiftUI

class FormData: ObservableObject {
    @Published var selectedSize: String = ""
    @Published var selectedCondition: String = ""
}


struct FormView: View {
  
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
    
    var body: some View {
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
                            isSizeSelect  = false
                        }
                    }
                }
                //Logged wave size
                Text(formData.selectedSize)
                    .font(.custom("AvenirNext-Bold", size: 14))
                    .scaleEffect(1.2)
                    .shadow(radius: 2)
            }
            
            //wave conditon section
            Section(header: Button(action: {
                isConditionSelect.toggle()
            }) {
                Text("Conditon")
                    .headerProminence(.increased)
                    .modifier(SectionButtonModifier(isSelected: $isConditionSelect))
            })
            {
                if isConditionSelect {
                    Picker("", selection: $formData.selectedCondition) {
                        ForEach(waveCondtions, id: \.key) {
                            condition in
                            Text(condition.value).tag(condition.key)
                        }
                    }
                    .pickerStyle(.wheel)
                    .labelsHidden()
                    .onChange( of: formData.selectedCondition) {
                        waveCondition = formData.selectedCondition
                        withAnimation {
                            isConditionSelect = false
                        }
                    }
                }
                
                Text(formData.selectedCondition)
                    .font(.custom("AvenirNext-Bold", size: 14))
                    .scaleEffect(1.2)
                    .shadow(radius: 2)
                  
            }
            
            //swell
        }
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
    
    var shadowColor: Color = Color.black.opacity(0.2)
    var shadowRadius: CGFloat = 9
    var shadowOffsetX: CGFloat = 3
    var shadowOffsetY: CGFloat = 6
    
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .shadow(color: shadowColor, radius: shadowRadius, x: shadowOffsetX, y: shadowOffsetY)
            .padding([.leading,.trailing])
            .background(.primary)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .scaleEffect(isSelected ? 1.2 : 1)
            .animation(.easeInOut(duration: 0.3), value: isSelected)
            
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
        @StateObject private var formData = FormData()

        var body: some View {
            FormView(isSizeSelect: $isSizeSelect, isConditionSelect: $isConditionSelect)
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
