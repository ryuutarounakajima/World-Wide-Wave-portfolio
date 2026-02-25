//
//  MylogSwiftUIView.swift
//  World Wide Wave
//
//  Created by Ryutarou Nakajima on 2024/11/13.
//
/*
 VStack(spacing: height * 0.06) {
     VStack(spacing: 3) {
         if let firstLog = logs.first {
             if let data = firstLog.imageData, let uiImage = UIImage(data: data) {
                 Image(uiImage: uiImage)
                     .resizable()
                     .scaledToFit()
                     .clipped()
                     .cornerRadius(180)
                     .shadow(radius: 5)
                     .padding()
             } else {
                 Image("Logo")
                     .resizable()
                     .scaledToFit()
                     .clipped()
                     .cornerRadius(180)
                     .shadow(radius: 5)
                     .padding()
             }
             
             if let ts = firstLog.timestamp {
                 Text(ts.formatted(date: .long, time: .omitted))
                 Text(ts.formatted(date: .omitted, time: .long))
             }
         }
     }
    
 */
 
import SwiftUI
import SwiftData
import AVKit
import MapKit

struct MylogSwiftUIView: View {
    
    @EnvironmentObject var formData: FormData

    //@StateObject private var formData = FormData()
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \SurfLog2.timestamp, order: .reverse) var logs: [SurfLog2]
    
    @State private var selectedAsset : WaveAsset? = nil
    @State private var selectedLog: SurfLog2? = nil
    
    var body: some View {
        GeometryReader { geo in
            
            let screenHeight = geo.size.height
            let screenWidth = geo.size.width
            ScrollView {
                
                //let screenHeight = UIScreen.main.bounds.height
               // let screenWidth = UIScreen.main.bounds.width
                
                if logs.isEmpty {
                    
                VStack(spacing: screenHeight * 0.06) {
                    VStack(spacing: 3) {
                        if let firstAsset = sortedWaveAssets.first {
                            
                         
                            
                            Image(firstAsset.imageName)
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .frame(height: geo.size.height * 0.25)
                                .frame(maxWidth: .infinity)
                                .shadow(radius: 4)
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
                    
                    VStack(alignment: .leading, spacing: screenHeight * 0.015) {
                        
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
                
                VStack {
                    VStack(spacing: 8) {
                        
                        if let firstLog = logs.first {
                            if let data = firstLog.imageData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: screenWidth * 0.8, height: screenHeight * 0.35)
                                    .background(Color(.systemGray2))
                                    .cornerRadius(20)
                                    .shadow(radius: 5)
                                    //.padding()
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.primary.opacity(1.5), lineWidth: 1)
                                    )
                                    .padding(.bottom, 10)                .onTapGesture {
                                        selectedLog = firstLog
                                    }
                            } else if let videoPath = firstLog.videoPath {
                                let url: URL? = {
                                    if videoPath.hasPrefix("http://") || videoPath.hasPrefix("https://") {
                                        return URL(string: videoPath)
                                    } else {
                                        return URL(fileURLWithPath: videoPath)
                                    }
                                }()
                                
                                if let url {
                                    VideoPlayer(player: AVPlayer(url: url))
                                        .scaledToFill()
                                        .clipped()
                                        //.clipShape(.capsule)
                                        .frame(width: screenWidth * 0.8, height: screenHeight * 0.35)
                                        .background(Color(.systemGray2))
                                        .cornerRadius(20)
                                        .shadow(radius: 5)
                                        //.padding()
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.primary.opacity(1.5), lineWidth: 1)
                                        )
                                        .padding(.bottom, 10)

                                    
                                    Button(action: {
                                        selectedLog = firstLog
                                    }) {
                                        Text("Wave info")
                                            .font(.headline)
                                            .foregroundColor(.black)
                                            .frame(width: screenWidth * 0.55,height: max(screenHeight * 0.025, 44) )
                                            //.padding()
                                            .background(    LinearGradient(gradient: Gradient(colors: [.blue, .cyan, .white, .brown]),
                                                                           startPoint: .bottomTrailing,
                                                                           endPoint: .topLeading))
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.primary, lineWidth: 2)
                                            )
                                            .shadow(radius: 3)
                                    }
                                } else {
                                    ZStack {
                                        Image("Logo")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(maxWidth: screenWidth * 0.7, maxHeight: screenHeight * 0.3)
                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                            .shadow(radius: 5)
                                            .padding(.vertical, 8)
                                            .grayscale(1.0)
                                            .onTapGesture {
                                                selectedLog = firstLog
                                            }
                                        
                                        Text("No URL Found...")
                                                  .font(.headline)
                                                  .bold()
                                                  .foregroundColor(.white)
                                                  .padding(.horizontal, 12)
                                                  .padding(.vertical, 6)
                                                  .background(Color.black.opacity(0.6))
                                                  .clipShape(Capsule())
                                        
                                    }
                                }
                            } else {
                                ZStack {
                                    Image("Logo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: screenWidth * 0.7, maxHeight: screenHeight * 0.3)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .shadow(radius: 5)
                                        .padding(.vertical, 8)
                                        .grayscale(1.0)
                                        .onTapGesture {
                                            selectedLog = firstLog
                                        }
                                    
                                    Text("No capture...")
                                              .font(.headline)
                                              .bold()
                                              .foregroundColor(.white)
                                              .padding(.horizontal, 12)
                                              .padding(.vertical, 6)
                                              .background(Color.black.opacity(0.6))
                                              .clipShape(Capsule())
                                    
                                }
                            }
                            
                            if let timeStamp = firstLog.timestamp {
                                Text(timeStamp.formatted(date: .long, time: .omitted))
                                Text(timeStamp.formatted(date: .omitted, time:.complete))
                            }
                        }
                    }
                    .sheet(item: $selectedLog) { log in
                        LogDetailView(log: log)
                    }
                    
                    VStack(alignment: .leading, spacing: screenHeight * 0.015) {
                        
                        Text("Wave log")
                            .font(.title)
                            .bold()
                            .padding(.vertical)
                            .padding(.leading)
                            .foregroundStyle(.primary)
                        
                        LogScrollView(logs: logs)
                        
                    }
                    
                    /*  List {
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
                     */
                    
                }
                
            }
        }
        .sheet(isPresented: $formData.showMyPagesheet) {
            MyPageView()
        }
    }
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

struct LogScrollView: View {
    
    let logs: [SurfLog2]
    @State private var selectedLog: SurfLog2? = nil
    
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(spacing: 16) {
                ForEach(logs) { log in
                    VStack(spacing: 8) {
                        if let data = log.imageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .clipped()
                                .cornerRadius(180)
                                .shadow(radius: 5)
                                .onTapGesture {
                                    selectedLog = log
                                }
                        } else if let thumbnailData = log.thumbnailData,
                                  let thumbnailImage = UIImage(data: thumbnailData) {
                            ZStack {
                                Image(uiImage: thumbnailImage)
                                    .resizable()
                                    .scaledToFit()
                                    .clipped()
                                
                                Circle()
                                    .fill(Color.black.opacity(0.35))
                                    .frame(width: 48, height: 48)
                                    .overlay(
                                        Image(systemName: "play.fill")
                                            .foregroundStyle(.white)
                                            .font(.system(size: 20, weight: .bold))
                                    )
                            }
                            .cornerRadius(180)
                            .shadow(radius: 5)
                            .onTapGesture {
                                selectedLog = log
                            }
                        } else {
                            Image("Logo")
                                .resizable()
                                .scaledToFit()
                                .grayscale(1.0)
                                .clipped()
                                .cornerRadius(180)
                                .shadow(radius: 5)
                                .overlay(
                                    Text("No capture")
                                        .font(.subheadline)
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color.black.opacity(0.5))
                                        .clipShape(Capsule())
                                        .padding(8),
                                    alignment: .center
                                )
                                .onTapGesture {
                                    selectedLog = log
                                }
                        }
                        
                        VStack(spacing: 2) {
                            if let ts = log.timestamp {
                                Text(ts.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .foregroundStyle(.primary)
                                
                                Text(ts.formatted(date: .omitted, time: .shortened))
                                    .font(.caption2)
                                    .foregroundStyle(.primary)
                            } else {
                                Text("_")
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                
            }
            .padding([.horizontal, .bottom])
        }
        .frame(height: 140)
        .sheet(item: $selectedLog) {
            log in
            LogDetailView(log: log)
        }}
}

struct LogDetailView: View {
    
    let log: SurfLog2
    @EnvironmentObject var formData: FormData
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var player: AVPlayer?
    
    enum FullScreenType: Identifiable {
        case video
        case camera
        
        var id: String {
            switch self {
            case .video: return "video"
            case .camera: return "camera"
            }
        }
    }
    @State private var fullScreenType: FullScreenType?
    
  
    private var destinationCoordinate: CLLocationCoordinate2D? {
        guard let lat = log.coordinateLat, let lon = log.coordinateLon else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    private func openInMapsDriving() {
        
        guard let coord = destinationCoordinate else { return }
        
        let placemark = MKPlacemark(coordinate: coord)
        let destination = MKMapItem(placemark: placemark)
        
        //destination.name = log.imageData.flatMap(\.debugDescription) ?? "Unknown Location"
        
        let options = [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ]
        
        destination.openInMaps(launchOptions: options)
    }
    
    init(log: SurfLog2) {
        self.log = log
        let coordinate = CLLocationCoordinate2D(latitude: log.coordinateLat ?? 0, longitude: log.coordinateLon ?? 0)
        
        _cameraPosition = State(initialValue: .region(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))))
    }

    var body: some View {
        GeometryReader {
            geo in
            ScrollView {
            VStack(spacing: 16) {
                
                if let ts = log.timestamp {
                    Text(ts.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundStyle(.primary)
                    
                    Text(ts.formatted(date: .omitted, time: .shortened))
                        .font(.caption2)
                        .foregroundStyle(.primary)
                } else {
                    Text("_")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                
                //WavePhoto
                if let data = log.imageData, let uiImage = UIImage(data: data) {
                    Button {
                        fullScreenType = .camera
                    } label: {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .frame(height: geo.size.height * 0.25)
                            .frame(maxWidth: .infinity)
                            .shadow(radius: 4)
                    }
                } else {
                    Button{
                        //fullScreenType = .camera
                    } label: {
                        Image("Logo")
                            .resizable()
                            .scaledToFit()
                            .grayscale(1.0)
                            .clipped()
                            .cornerRadius(180)
                            .shadow(radius: 5)
                            .frame(height: geo.size.height * 0.25)
                            .overlay(
                                Text("No capture")
                                    .font(.subheadline)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.black.opacity(0.5))
                                    .clipShape(Capsule())
                                    .padding(8),
                                alignment: .center
                            )
                    }
                }
                
                // Video
                /*
                 if let videoPath = log.videoPath, !videoPath.isEmpty {
                 if let url = URL(string: videoPath) ?? URL(string: videoPath.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "") {
                 VideoPlayer(player: AVPlayer(url: url))
                 .clipShape(RoundedRectangle(cornerRadius: 180))
                 .frame(height: geo.size.height * 0.25)
                 .shadow(radius: 4)
                 
                 */
                if let videoPath = log.videoPath, !videoPath.isEmpty {
                    if let player
                    {
                        VStack(spacing: 8) {
                            VideoPlayer(player: player)
                                .clipShape(RoundedRectangle(cornerRadius: 180))
                                .frame(height: geo.size.height * 0.25)
                                .shadow(radius: 4)
                            
                            Button {
                                //videoFullScreen = true
                                
                                fullScreenType = .video
                            } label: {
                                Label("Full Screen", systemImage: "arrow.up.left.and.arrow.down.right")
                            }
                            .buttonStyle(.bordered)
                        }
                    } else {
                        Text("Invalid video URL")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Map
                Map(position: $cameraPosition) {
                    if let lat = log.coordinateLat, let lon = log.coordinateLon {
                        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                        Marker("Here", coordinate: coordinate)
                    }
                }
                .frame(height: geo.size.height * 0.33)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 2)
                .padding(.horizontal)
                
                //Go button
                Button {
                    openInMapsDriving()
                } label: {
                    Label("Go surf", systemImage: "figure.surfing.circle.fill")
                }
                .buttonStyle(.borderedProminent)
                
                //wave data form
                ReceivedForm2(log: log)
                
                
            }
            .padding()
            .fullScreenCover(item: $fullScreenType) { type in
                NavigationStack {
                    ZStack {
                        Color.white.ignoresSafeArea()
                        switch type {
                        case .video:
                            if let player {
                                VideoPlayer(player: player)
                                    .ignoresSafeArea()
                                    .onAppear { player.play() }
                            } else {
                                Text("No video available")
                                    .foregroundStyle(.white)
                            }
                        case .camera:
                            if let data = log.imageData, let uiImage = UIImage(data: data) {
              
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .clipped()
                                    .ignoresSafeArea()
                                
                            } else {
                                Image("Logo")
                                    .resizable()
                                    .scaledToFit()
                                    .ignoresSafeArea()
                            }
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                fullScreenType = nil
                            } label: {
                                Image(systemName: "xmark")
                            }
                        }
                    }
                    .navigationTitle( type == .video ? "Video" : "Photo" )
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
            .onAppear {
                if player == nil, let videoPath = log.videoPath,
                   !videoPath.isEmpty {
                    
                    print("🎥 videoPath:", videoPath)
                    print("🎥 exists:",
                          FileManager.default.fileExists(atPath: videoPath))
                    
                    let url = URL(fileURLWithPath: videoPath)
                    player = AVPlayer(url: url)
                    player?.play()
                }
            }
            .onDisappear {
                player?.pause()
            }
        }
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
let waveAssetImages: [String] = ["wave1", /*"wave2",*/ "wave3", "wave4", "wave5", "wave6", "Logo"]
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
    let schema = Schema([SurfLog2.self])
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [configuration])

    return MylogSwiftUIView()
        .environmentObject(FormData())
        .modelContainer(container)
}

