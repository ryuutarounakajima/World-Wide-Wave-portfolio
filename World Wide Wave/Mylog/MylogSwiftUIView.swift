//
//  MylogSwiftUIView.swift
//  World Wide Wave
//
//  Created by Ryutarou Nakajima on 2024/11/13.
//

import SwiftUI
import SwiftData
import AVKit


struct AssetScrollView: View {
    
    let assetImages = ["wave1", "wave2", "wave3", "wave4", "wave5"]
    
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(spacing: 16) {
                ForEach(assetImages, id: \.self) {
                    imageName in
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .clipped()
                        .cornerRadius(180)
                        .shadow(radius: 5)
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 140)
    }
}
struct MylogSwiftUIView: View {
    
    
    
    @Query(sort: \SurfLog2.timestamp, order: .reverse) var logs: [SurfLog2]
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                
                let width = geometry.size.width
                let height = geometry.size.height
                
                if logs.isEmpty {
                    
                    VStack(spacing: height * 0.06) {
                        Image("Logo")
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(180)
                            .frame(width: width * 0.7)
                            .opacity(0.7)
                        
                        Text("No logs yet 🌊")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading, spacing: height * 0.015) {
                            
                            Text("Wave Gallery")
                                .font(.title)
                                .bold()
                                .padding(.vertical)
                                .padding(.leading)
                                .foregroundStyle(.primary)
                            
                            AssetScrollView()
                                
                        }
                        
                        
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
}

#Preview {
    MylogSwiftUIView()
}
