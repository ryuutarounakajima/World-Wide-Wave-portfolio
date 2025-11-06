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

struct RecievedForm: View {
    
    @EnvironmentObject var formData: FormData
    @State private var isSelected: Bool = false
    
    //wave size
    @State private var randomWaveSize: String = ""
    @State private var randomWaveSize2: String = ""
    
    //wave conditon
    @State private var randomWaveCondition: String = ""
        
    
    var body: some View {
        Form {
            CustomFormSection4(
                title: "Size",
                isSelected: $isSelected,
                selectedValue1: $formData.selectedSize1,
                selectedValue2: $formData.selectedSize2,
                options: WaveOptions.waveSizes
            ) {
                // ランダムに選んだ2値を表示（左 <= 右 の順序を保証）
                Text("\(randomWaveSize) ~ \(randomWaveSize2)")
                    .modifier(CustomFormTextModifier())
                
            }
            
            CustomFormSection3(title: "Condition", isSelected: $isSelected, selectedValue: $formData.selectedCondition, options: WaveOptions.waveConditons) {
                // ランダムに選んだ1値を表示
                Text(randomWaveCondition)
                    .modifier(CustomFormTextModifier())
            }
        }
        .onAppear {
            pickRandomWaveSizes()
           // pickRandomCondition()
            randomWaveCondition = pickRandomValue(from: WaveOptions.waveConditons)
        }
    }
    
    // 先頭の空要素 ("", "") は除外してランダムに2つ選択し、元配列の順序で左<=右に並べる
    private func pickRandomWaveSizes() {
        let candidates = Array(WaveOptions.waveSizes.dropFirst())
        let count = candidates.count
        
        if count >= 2 {
            let i = Int.random(in: 0..<count)
            var j = Int.random(in: 0..<count)
            while j == i {
                j = Int.random(in: 0..<count)
            }
            let low = min(i, j)
            let high = max(i, j)
            randomWaveSize = candidates[low].value
            randomWaveSize2 = candidates[high].value
        } else if let only = candidates.first {
            randomWaveSize = only.value
            randomWaveSize2 = only.value
        } else {
            randomWaveSize = ""
            randomWaveSize2 = ""
        }
    }
    
    // 先頭の空要素 ("", "") は除外してランダムに1つ選択
    private func pickRandomCondition() {
        let candidates = Array(WaveOptions.waveConditons.dropFirst())
        if let picked = candidates.randomElement() {
            randomWaveCondition = picked.value
        } else {
            randomWaveCondition = ""
        }
    }
    
    // MARK: - 共通ヘルパー
    // 先頭の空要素 ("", "") を除外してランダムに1つ選択
    private func pickRandomValue(from options: [(key: String, value: String)]) -> String {
        let candidates = Array(options.dropFirst())
        return candidates.randomElement()?.value ?? ""
    }
    

}

#Preview {
    RecievedForm()
        .environmentObject(FormData())
}
