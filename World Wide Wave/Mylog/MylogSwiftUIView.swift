//
//  MylogSwiftUIView.swift
//  World Wide Wave
//
//  Created by Ryutarou Nakajima on 2024/11/13.
//

import SwiftUI
import SwiftData
import AVKit

let waveAssetImages: [String] = ["wave1", "wave2", "wave3", "wave4", "wave5", "wave6", "Logo"]

func randomDateInBirthToCurent() -> Date {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = .current

    // 2025/01/01 から 2025/12/31 まで
    let start = calendar.date(from: DateComponents(year: 1988, month: 11, day: 19))!
    let end = calendar.date(from: DateComponents(year: 2025, month: 11, day: 9))!

    let range = start.timeIntervalSince1970...end.timeIntervalSince1970
    let randomTime = TimeInterval.random(in: range)
    return Date(timeIntervalSince1970: randomTime)
}
func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = .current
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter.string(from: date)
}

struct WaveAsset: Identifiable {
    let id = UUID()
    let imageName: String
    let date: Date
    let dateText: String
}
let waveAssets: [WaveAsset] = waveAssetImages.map { name in
    let randomDate = randomDateInBirthToCurent()
    return WaveAsset(imageName: name, date: randomDate, dateText: formatDate(randomDate))
}
let sortedWaveAssets: [WaveAsset] = waveAssets.sorted(by: { $0.date > $1.date })


struct AssetScrollView: View {
    
    let assets: [WaveAsset] = sortedWaveAssets
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(spacing: 16) {
                ForEach(assets) { asset in
                    VStack(spacing: 8) {
                        Image(asset.imageName)
                            .resizable()
                            .scaledToFit()
                            .clipped()
                            .cornerRadius(180)
                            .shadow(radius: 5)
                        
                        Text(asset.dateText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                    }
                }
            }
            .padding([.horizontal, .bottom])
        }
        .frame(height: 140)
    }
}
struct MylogSwiftUIView: View {
    
    
    
    @Query(sort: \SurfLog2.timestamp, order: .reverse) var logs: [SurfLog2]
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                
                let _ = geometry.size.width
                let height = geometry.size.height
                
                if logs.isEmpty {
                    
                    VStack(spacing: height * 0.06) {
                        VStack(spacing: 3) {
                            if let firstAsset = sortedWaveAssets.first {
                                
                                Image(firstAsset.imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .clipped()
                                    .cornerRadius(180)
                                    .shadow(radius: 5)
                                   
                                
                                Text(firstAsset.dateText)
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .foregroundColor(.gray)
                                    .padding(.top, 4)

                            }
                            
                            
                        }
                        
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

