//
//  MylogSwiftUIView.swift
//  World Wide Wave
//
//  Created by Ryutarou Nakajima on 2024/11/13.
//

import SwiftUI
import SwiftData
import AVKit
import MapKit

struct MylogSwiftUIView: View {
    
    @StateObject private var formData = FormData()
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \SurfLog2.timestamp, order: .reverse) var logs: [SurfLog2]
    @State private var selectedAsset : WaveAsset? = nil
    
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
                                    .padding()
                                    .onTapGesture {
                                        selectedAsset = firstAsset
                                    }
                                   
                                Text(firstAsset.dateText)
                                
                                Text(firstAsset.timeText)

                            }
                            
                            
                        }
                        
                        Text("No logs yet 🌊")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading, spacing: height * 0.015) {
                            
                            Text("Recent")
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
                    .sheet(item: $selectedAsset) { asset in
                        AssetDetailView(asset: asset)
                    }
                    
                    
                } else {
                    List {
                        ForEach(logs) { log in
                            
                            VStack(alignment: .leading, spacing: 8) {
                                if let imageData = log.imageData, let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
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
                                
                                if let ts = log.timestamp {
                                    Text(ts.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Text(log.note)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(3)
                            }
                            // 個別スワイプアクション（iOS 15+）
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    deleteLogs([log])
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                        /* // 伝統的なスワイプ削除（編集モードや左スワイプで有効）
                        .onDelete { indexSet in
                            let targets = indexSet.map { logs[$0] }
                            deleteLogs(targets)
                        }
                         */
                    }
                }
            }
        }
        .environmentObject(formData)
    }
    
    private func deleteLogs(_ targets: [SurfLog2]) {
        for log in targets {
            modelContext.delete(log)
        }
        do {
            try modelContext.save()
        } catch {
            print("Failed to delete logs: \(error)")
        }
    }
}

struct AssetDetailView: View {
    
    let asset: WaveAsset
    @State private var cameraPosition: MapCameraPosition
    @EnvironmentObject var formData: FormData
    
    private var destinationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: asset.latitude, longitude: asset.longitude)
    }
    
    private func openInMapsDriving() {
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate))
        destination.name = asset.imageName
        let options = [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ]
        destination.openInMaps(launchOptions: options)
    }
    
    init(asset: WaveAsset) {
        self.asset = asset
        let coordinate = CLLocationCoordinate2D(latitude: asset.latitude, longitude: asset.longitude)
        
        _cameraPosition = State(initialValue: .region(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))))
    }

    var body: some View {
        GeometryReader {
            geo in
            
            VStack(spacing: 16) {
                
                Text(asset.dateText)
                   
                Text(asset.timeText)
                    .font(.title)
                
                // 1) Top image
                Image(asset.imageName)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 180))
                    .frame(height: geo.size.height * 0.25)
                    .shadow(radius: 4)

                // 2) Map from latitude/longitude
                Map(position: $cameraPosition) {
                    let coordinate = CLLocationCoordinate2D(latitude: asset.latitude, longitude: asset.longitude)
                    Marker("Here", coordinate: coordinate)
                }
                .frame(height: geo.size.height * 0.2)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 2)
                
                
                Button {
                        openInMapsDriving()
                    } label: {
                        Label("go surf", systemImage: "figure.surfing.circle.fill")
                    }
                    .buttonStyle(.borderedProminent)

                
                ReceivedForm()
            }
            .padding()
            .navigationTitle("Asset Detail")
        }
        
    }
}

struct AssetScrollView: View {
    
    let assets: [WaveAsset] = sortedWaveAssets
    @State private var selectedAsset: WaveAsset? = nil
    
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
                            .onTapGesture {
                                selectedAsset = asset
                            }
                        
                        VStack(spacing: 2) {
                            Text(asset.dateText)
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Text(asset.timeText)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding([.horizontal, .bottom])
        }
        .frame(height: 140)
        .sheet(item: $selectedAsset) { asset in
            AssetDetailView(asset: asset)
        }
    }
}

// MARK: - mock assets
let waveAssetImages: [String] = ["wave1", "wave2", "wave3", "wave4", "wave5", "wave6", "Logo"]
let waveAssets: [WaveAsset] = waveAssetImages.map { name in
    let randomDate = randomDateInBirthToCurent()
    let (dateText, timeText) = formatDate(randomDate)
    let coordinate = randomCoordinate()
    
    return WaveAsset(imageName: name, date: randomDate, dateText: dateText, timeText: timeText, latitude: coordinate.latitude, longitude: coordinate.longitude)
}
let sortedWaveAssets: [WaveAsset] = waveAssets.sorted(by: { $0.date > $1.date })
func randomDateInBirthToCurent() -> Date {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = .current

    let start = calendar.date(from: DateComponents(year: 1988, month: 11, day: 19))!
    let end = calendar.date(from: DateComponents(year: 2025, month: 11, day: 9))!

    let range = start.timeIntervalSince1970...end.timeIntervalSince1970
    let randomTime = TimeInterval.random(in: range)
    return Date(timeIntervalSince1970: randomTime)
}
func formatDate(_ date: Date) -> (dateText: String, timeText: String) {
    let formatter = DateFormatter()
    formatter.locale = .current
    formatter.calendar = Calendar(identifier: .gregorian)
    
    formatter.dateStyle = .long
    formatter.timeStyle = .none
    let dateText = formatter.string(from: date)
    
    formatter.dateStyle = .none
    formatter.timeStyle = .long
    let timeText = formatter.string(from: date)
    
    return (dateText, timeText)
}
func randomCoordinate() -> (latitude: Double, longitude: Double) {
    let latitude = Double.random(in: -90.0...90.0)
    let longitude = Double.random(in: -180.0...180.0)
    return (latitude, longitude)
}

struct WaveAsset: Identifiable {
    let id = UUID()
    let imageName: String
    let date: Date
    let dateText: String
    let timeText: String
    let latitude: Double
    let longitude: Double
}

#Preview {
    MylogSwiftUIView()
        .environmentObject(FormData())
        .modelContainer(for: SurfLog2.self )
}
