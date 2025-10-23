//
//  MylogSwiftUIView.swift
//  World Wide Wave
//
//  Created by Ryutarou Nakajima on 2024/11/13.
//

import SwiftUI
import SwiftData
import AVKit

struct MylogSwiftUIView: View {
    @Query(sort: \SurfLog2.timestamp, order: .reverse) var logs: [SurfLog2]
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    MylogSwiftUIView()
}
