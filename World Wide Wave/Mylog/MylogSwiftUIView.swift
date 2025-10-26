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
        NavigationStack {
            if logs.isEmpty {
                 
                VStack(spacing: 12) {
                    Image("Logo")
                        .resizable()
                                                .scaledToFit()
                                                .frame(width: 360, height: 360)
                                                             .opacity(0.7)
                                            Text("No logs yet 🌊")
                                                .font(.headline)
                              .foregroundColor(.gray)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color(.systemGroupedBackground))
                                .navigationTitle("My surf logs")
                
            } else {
                List {
                    ForEach(logs) { log in
                        
                        VStack(alignment: .leading, spacing: 8) {
                            if let  imageData = log.imageData, let UIImage = UIImage(data: imageData) {
                                
                                Image(uiImage: UIImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 100)
                                    .clipped()
                                    .cornerRadius(12)
                            } else {
                                Image("Logo")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 180)
                                    .clipped()
                                    .cornerRadius(12)
                                    .overlay(
                                        Text("No Image Available")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                            .padding(6)
                                            .background(Color.black.opacity(0.5))
                                            .cornerRadius(8),
                                        alignment: .bottomTrailing
                                    )
                            }
                        }
                    }
                }
                
            }
                
        }
    }
}

#Preview {
    MylogSwiftUIView()
}
