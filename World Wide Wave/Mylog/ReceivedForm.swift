//
//  RecievedForm.swift
//  World Wide Wave
//
//  Created by Ryuutarou Nakajima on 2025/11/05.
//

import SwiftUI

struct CustomFormSection3<Content: View>: View {
    
    
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
               // isSelected.toggle()
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
               
            } else {
                
                
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
struct CustomFormSection4<Content: View>: View {
    
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
                       //isSelected.toggle()
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
                   } else {
                      
                       
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

struct ReceivedForm: View {
    
    @EnvironmentObject var formData: FormData
    @State private var isSelected: Bool = false
    
    // 共通定義から参照
    private let waveSizes: [(key: String, value: String)] = WaveOptions.waveSizes
    private let waveConditions: [(key: String, value: String)] = WaveOptions.waveConditions
    private let swells: [(key: String, value: String)] = WaveOptions.swells
    private let breaks: [(key: String, value: String)] = WaveOptions.breaks
    private let winds: [(key: String, value: String)] = WaveOptions.winds
    private let tides: [(key: String, value: String)] = WaveOptions.tides
    private let waxes: [(key: String, value: String)] = WaveOptions.waxes
    

    @State private var randomWaveSize: String = ""
    @State private var randomWaveSize2: String = ""
    @State private var randomWaveCondition: String = ""
    @State private var randomSwell: String = ""
    @State private var randomBreak: String = ""
    @State private var randomWind: String = ""
    @State private var randomWindSpeed: Double = 0.0
    @State private var randomTides: String = ""
    @State private var randomTideLevel: Double = 0.0
    @State private var randomWax: String = ""
    @State private var randomWaterTemp: Double = 0
    
    var body: some View {
        Form {
            CustomFormSection4(
                title: "Size",
                isSelected: $isSelected,
                selectedValue1: $formData.selectedSize1,
                selectedValue2: $formData.selectedSize2,
                options: waveSizes
            ) {
                // ランダムに選んだ2値を表示（左 <= 右 の順序を保証）
                Text("\(randomWaveSize) ~ \(randomWaveSize2)")
                    .modifier(CustomFormTextModifier())
                
            }
            
            CustomFormSection3(
                title: "Condition",
                isSelected: $isSelected,
                selectedValue: $formData.selectedCondition,
                options: waveConditions
            ) {
                // ランダムに選んだ1値を表示
                Text(randomWaveCondition)
                    .modifier(CustomFormTextModifier())
            }
            
            CustomFormSection3(title: "swell", isSelected: $isSelected, selectedValue: $formData.selectedSwell, options: swells) {
            
                Text(randomSwell)
                    .modifier(CustomFormTextModifier())
            }
            
            CustomFormSection3(title: "break type", isSelected: $isSelected, selectedValue: $formData.selectedBreaks, options: breaks) {
                
                Text(randomBreak)
                    .modifier(CustomFormTextModifier())
            }
            
            CustomFormSection3(title: "Wind", isSelected: $isSelected, selectedValue: $formData.selectedWind, options: winds) {
                
                VStack {
                    Text(randomWind)
                        .modifier(CustomFormTextModifier())
                    HStack {
                        Text("Strength")
                            .font(.custom("AvenirNext-Bold", size: 14))
                            .scaleEffect(0.8)
                            .shadow(radius: 2)
                        
                        Spacer()
                        
                        ReadOnlyValueTrack(value: randomWindSpeed, range: 0...20, gradient: Gradient(colors: [.cyan, .red]))
                    }
                }
            }
            
            CustomFormSection3(title: "Tide", isSelected: $isSelected, selectedValue: $formData.selectedTide, options: WaveOptions.tides) {
                VStack {
                    Text(randomTides)
                        .modifier(CustomFormTextModifier())
                    HStack {
                        Text("High & Low")
                            .font(.custom("AvenirNext-Bold", size: 14))
                            .scaleEffect(0.8)
                            .shadow(radius: 2)
                        
                        Spacer()
                        
                        ReadOnlyValueTrack(value: randomTideLevel, range: 0...3, gradient: Gradient(colors: [.brown, .yellow, .cyan, .blue]))
                    }
                }
               
            }
            
            CustomFormSection3(title: "wax", isSelected: $isSelected, selectedValue: $formData.selectedTide, options: WaveOptions.waxes) {
                VStack {
                    Text(randomWax)
                        .modifier(CustomFormTextModifier())
                    HStack {
                        Text("Cold water")
                            .font(.custom("AvenirNext-Bold", size: 14))
                            .scaleEffect(0.8)
                            .shadow(radius: 2)
                        
                        Spacer()
                        
                        ReadOnlyValueTrack(value: randomWaterTemp, range: 0...36, gradient: Gradient(colors: [.white, .cyan, .orange]))
                    }
                }
               
            }
            
            
        }
        .onAppear {
            refreshRandomSuggestions()
            randomWindSpeed = Double.random(in: 0...20)
            randomTideLevel = Double.random(in: 0...3)
            randomWaterTemp = Double.random(in: 0...36)
        }
    }
    
    // ここに「全部のランダム候補」をまとめて更新
    private func refreshRandomSuggestions() {
        
        let (low, high) = pickTwoValuesOrdered(from: waveSizes)
        randomWaveSize = low
        randomWaveSize2 = high
        
        randomWaveCondition = pickOneValue(from: waveConditions)
        randomSwell = pickOneValue(from: swells)
        randomBreak = pickOneValue(from: breaks)
        randomWind = pickOneValue(from: winds)
        randomTides = pickOneValue(from: tides)
        randomWax = pickOneValue(from: waxes)
    }
    
    
    // MARK: - 共通ランダム選択ユーティリティ
    private func pickOneValue(from options: [(key: String, value: String)]) -> String {
        let candidates = Array(options.dropFirst())
        return candidates.randomElement()?.value ?? ""
    }
    
    private func pickTwoValuesOrdered(from options: [(key: String, value: String)]) -> (String, String) {
        let candidates = Array(options.dropFirst())
        let count = candidates.count
        
        if count >= 2 {
            let i = Int.random(in: 0..<count)
            var j = Int.random(in: 0..<count)
            while j == i {
                j = Int.random(in: 0..<count)
            }
            let low = min(i, j)
            let high = max(i, j)
            return (candidates[low].value, candidates[high].value)
        } else if let only = candidates.first {
            return (only.value, only.value)
        } else {
            return ("", "")
        }
    }

}

#Preview {
    ReceivedForm()
        .environmentObject(FormData())
}
