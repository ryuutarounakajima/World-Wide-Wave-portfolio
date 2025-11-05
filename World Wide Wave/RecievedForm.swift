//
//  RecievedForm.swift
//  World Wide Wave
//
//  Created by Ryuutarou Nakajima on 2025/11/05.
//

import SwiftUI

struct RecievedForm: View {
    
    @EnvironmentObject var formData: FormData
    @State private var isSizeSelected: Bool = false
    @State private var waveSizes: [(key: String, value: String)] = [ ("" , ""), ("go home" , "go home"), ("Waist-high", "Waist-high"), ("belly-high", "belly-high"), ("Chest-high" , "Chest-high"), ("Head-high", "Head-high"), ("Overhead", "Overhead"), ("Double", "Double"), ("Triple over", "Triple over")
    ]
    
    var body: some View {
        Form {
       
            }
        }
    }

#Preview {
    RecievedForm()
}
