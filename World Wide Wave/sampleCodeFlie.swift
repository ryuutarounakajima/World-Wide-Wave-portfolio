//
//  sampleCodeFlie.swift
//  World Wide Wave
//
//  Created by Ryutarou Nakajima on 2024/10/16.
//

import Foundation



/*
// external storage
 @Attribute(.externalStorage) var videoData: Data?
 
// Log ScrollView
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
                         } else {
                             Image("Logo")
                                 .resizable()
                                 .scaledToFit()
                                 .clipped()
                                 .cornerRadius(180)
                                 .shadow(radius: 5)
                                 .onTapGesture {
                                     selectedLog = log
                                 }
                         }

                         VStack(spacing: 2) {
                             if let ts = log.timestamp {
                                 Text(ts.formatted(date: .abbreviated, time: .omitted))
                                     .font(.caption)
                                     .foregroundStyle(.secondary)
                                 Text(ts.formatted(date: .omitted, time: .shortened))
                                     .font(.caption2)
                                     .foregroundStyle(.secondary)
                             } else {
                                 Text("-")
                                     .font(.caption)
                                     .foregroundStyle(.secondary)
                             }
                         }
                     }
                 }
             }
             .padding([.horizontal, .bottom])
         }
         .frame(height: 140)
         .sheet(item: $selectedLog) { log in
             LogDetailView(log: log)
         }
     }
 }
//unified camera code
 import UIKit
 import AVFoundation
 import SwiftUI

 final class UnifiedCameraViewController: UIViewController {

     enum Mode { case photo, video }

     // MARK: - Callbacks
     var onPhotoCaptured: ((UIImage) -> Void)?
     var onVideoCaptured: ((URL) -> Void)?
     var onDismiss: (() -> Void)?

     // MARK: - AV properties
     private let session = AVCaptureSession()
     private let sessionQueue = DispatchQueue(label: "com.example.camera.session")
     private var previewLayer: AVCaptureVideoPreviewLayer!

     private let photoOutput = AVCapturePhotoOutput()
     private let movieOutput = AVCaptureMovieFileOutput()

     // UI
     private var captureButton: UIButton!
     private var modeControl: UISegmentedControl!

     // state
     private(set) var mode: Mode = .photo
     private var isSessionRunning = false

     // temp file url for recording
     private var currentRecordingURL: URL?

     // MARK: - Lifecycle
     override func viewDidLoad() {
         super.viewDidLoad()
         view.backgroundColor = .black

         setupPreviewLayer()
         setupUI()
         configureSessionAsync()
     }

     deinit {
         stopSession()
     }

     override func viewDidLayoutSubviews() {
         super.viewDidLayoutSubviews()
         previewLayer.frame = view.bounds
         layoutUI()
     }

     // MARK: - Session config
     private func configureSessionAsync() {
         sessionQueue.async { [weak self] in
             guard let self = self else { return }
             self.session.beginConfiguration()
             self.session.sessionPreset = .high

             // inputs
             do {
                 if let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                     let videoInput = try AVCaptureDeviceInput(device: videoDevice)
                     if self.session.canAddInput(videoInput) { self.session.addInput(videoInput) }
                 }
                 if let audioDevice = AVCaptureDevice.default(for: .audio) {
                     let audioInput = try AVCaptureDeviceInput(device: audioDevice)
                     if self.session.canAddInput(audioInput) { self.session.addInput(audioInput) }
                 }
             } catch {
                 print("error creating inputs: \(error)")
             }

             // outputs
             if self.session.canAddOutput(self.photoOutput) {
                 self.session.addOutput(self.photoOutput)
             }
             if self.session.canAddOutput(self.movieOutput) {
                 self.session.addOutput(self.movieOutput)
             }

             self.session.commitConfiguration()

             // start running
             self.session.startRunning()
             self.isSessionRunning = true
             DispatchQueue.main.async {
                 self.previewLayer.session = self.session
             }
         }
     }

     func stopSession() {
         sessionQueue.async { [weak self] in
             guard let self = self else { return }
             if self.session.isRunning {
                 self.session.stopRunning()
                 self.isSessionRunning = false
             }
         }
         DispatchQueue.main.async {
             self.previewLayer.session = nil
             self.previewLayer.removeFromSuperlayer()
         }
     }

     // MARK: - Preview Layer + UI
     private func setupPreviewLayer() {
         previewLayer = AVCaptureVideoPreviewLayer(session: session)
         previewLayer.videoGravity = .resizeAspectFill
         previewLayer.frame = view.bounds
         view.layer.insertSublayer(previewLayer, at: 0)
     }

     private func setupUI() {
         // segmented control for mode
         modeControl = UISegmentedControl(items: ["Photo", "Video"])
         modeControl.selectedSegmentIndex = 0
         modeControl.addTarget(self, action: #selector(modeChanged(_:)), for: .valueChanged)
         view.addSubview(modeControl)

         // capture button
         captureButton = UIButton(type: .system)
         captureButton.backgroundColor = .white
         captureButton.layer.cornerRadius = 35
         captureButton.addTarget(self, action: #selector(capturePressed(_:)), for: .touchUpInside)
         view.addSubview(captureButton)

         // dismiss button
         let close = UIButton(type: .system)
         close.setTitle("Close", for: .normal)
         close.setTitleColor(.white, for: .normal)
         close.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
         view.addSubview(close)
         close.frame = CGRect(x: 16, y: 44, width: 80, height: 30)
     }

     private func layoutUI() {
         let safe = view.safeAreaLayoutGuide
         modeControl.translatesAutoresizingMaskIntoConstraints = false
         captureButton.translatesAutoresizingMaskIntoConstraints = false

         NSLayoutConstraint.activate([
             modeControl.centerXAnchor.constraint(equalTo: safe.centerXAnchor),
             modeControl.topAnchor.constraint(equalTo: safe.topAnchor, constant: 10),
             modeControl.widthAnchor.constraint(equalToConstant: 200),

             captureButton.centerXAnchor.constraint(equalTo: safe.centerXAnchor),
             captureButton.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -40),
             captureButton.widthAnchor.constraint(equalToConstant: 70),
             captureButton.heightAnchor.constraint(equalToConstant: 70),
         ])
     }

     // MARK: - Actions
     @objc private func modeChanged(_ seg: UISegmentedControl) {
         mode = seg.selectedSegmentIndex == 0 ? .photo : .video
     }

     @objc private func capturePressed(_ sender: UIButton) {
         switch mode {
         case .photo:
             capturePhoto()
         case .video:
             if movieOutput.isRecording {
                 stopRecording()
             } else {
                 startRecording()
             }
         }
     }

     @objc private func closeTapped() {
         stopSession()
         onDismiss?()
         dismiss(animated: true, completion: nil)
     }

     // MARK: - Photo
     private func capturePhoto() {
         let settings = AVCapturePhotoSettings()
         settings.isHighResolutionPhotoEnabled = true
         photoOutput.capturePhoto(with: settings, delegate: self)
     }

     // MARK: - Video
     private func startRecording() {
         sessionQueue.async { [weak self] in
             guard let self = self, !self.movieOutput.isRecording else { return }
             let tmp = URL(fileURLWithPath: NSTemporaryDirectory())
             let fileURL = tmp.appendingPathComponent(UUID().uuidString).appendingPathExtension("mov")
             self.currentRecordingURL = fileURL

             if let connection = self.movieOutput.connection(with: .video) {
                 connection.videoOrientation = self.currentVideoOrientation()
             }
             self.movieOutput.startRecording(to: fileURL, recordingDelegate: self)
             DispatchQueue.main.async {
                 // maybe animate UI to indicate recording
                 self.captureButton.backgroundColor = .red
             }
         }
     }

     private func stopRecording() {
         sessionQueue.async { [weak self] in
             guard let self = self, self.movieOutput.isRecording else { return }
             self.movieOutput.stopRecording()
             DispatchQueue.main.async {
                 self.captureButton.backgroundColor = .white
             }
         }
     }

     private func currentVideoOrientation() -> AVCaptureVideoOrientation {
         switch UIDevice.current.orientation {
         case .landscapeLeft: return .landscapeRight
         case .landscapeRight: return .landscapeLeft
         case .portraitUpsideDown: return .portraitUpsideDown
         default: return .portrait
         }
     }
 }

 // MARK: - AVCapturePhotoCaptureDelegate
 extension UnifiedCameraViewController: AVCapturePhotoCaptureDelegate {
     func photoOutput(_ output: AVCapturePhotoOutput,
                      didFinishProcessingPhoto photo: AVCapturePhoto,
                      error: Error?) {

         guard let data = photo.fileDataRepresentation(),
               var image = UIImage(data: data) else {
             print("photo convert failed")
             return
         }

         // fix orientation if needed (optional)
         DispatchQueue.main.async { [weak self] in
             self?.onPhotoCaptured?(image)
             // keep session running or stop depending on UX
         }
     }
 }

 // MARK: - AVCaptureFileOutputRecordingDelegate
 extension UnifiedCameraViewController: AVCaptureFileOutputRecordingDelegate {
     func fileOutput(_ output: AVCaptureFileOutput,
                     didFinishRecordingTo outputFileURL: URL,
                     from connections: [AVCaptureConnection],
                     error: Error?) {
         if let err = error {
             print("recording error: \(err)")
         } else {
             DispatchQueue.main.async { [weak self] in
                 self?.onVideoCaptured?(outputFileURL)
             }
         }
     }
 }
//VideoManagerSampleCode
 import UIKit
 import AVFoundation
 import AVKit

 class VideoPreviewViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
     
     private let session = AVCaptureSession()
     private let videoOutput = AVCaptureMovieFileOutput()
     private var previewLayer: AVCaptureVideoPreviewLayer!
     
     private var playerLayer: AVPlayerLayer?
     private var recordedVideoURL: URL?
     private var isRecording: Bool = false
     
     private let previewSize: CGFloat = 120
     private let margin: CGFloat = 20
     
     override func viewDidLoad() {
         super.viewDidLoad()
         setupVideoSession()
         setupPreviewLayer()
         setupRecordingButton()
     }
     
     override func viewDidLayoutSubviews() {
         super.viewDidLayoutSubviews()
         updatePreviewLayerFrame()
         updateRecordingButtonPosition()
     }
     
     // 🎥 撮影開始 / 停止
     @objc private func toggleRecording() {
         if isRecording {
             videoOutput.stopRecording()
         } else {
             let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).mov")
             videoOutput.startRecording(to: outputURL, recordingDelegate: self)
         }
         isRecording.toggle()
     }
     
     // 📽 録画完了
     func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
         isRecording = false
         
         if let error = error {
             print("❌ Recording failed: \(error.localizedDescription)")
             return
         }
         
         print("✅ Video saved at: \(outputFileURL)")
         
         DispatchQueue.main.async {
             self.recordedVideoURL = outputFileURL
             self.setupPlayerLayer(with: outputFileURL)
         }
     }
     
     // 🎞 撮影後の動画を正しい向きでプレビューに表示
     private func setupPlayerLayer(with url: URL) {
         let player = AVPlayer(url: url)
         let playerLayer = AVPlayerLayer(player: player)
         playerLayer.videoGravity = .resizeAspectFill
         playerLayer.cornerRadius = 10
         playerLayer.masksToBounds = true
         
         view.layer.addSublayer(playerLayer)
         self.playerLayer = playerLayer
         
         updatePlayerLayerFrame(with: url)
         player.play()
     }
     
     // 📏 プレビューの位置と回転調整
     private func updatePlayerLayerFrame(with url: URL) {
         guard let playerLayer = playerLayer else { return }
         
         let transform = getVideoTransform(for: url)
         let size = getVideoSize(for: url)
         
         let width = previewSize
         let height = previewSize * (size.height / size.width)  // アスペクト比を保つ
         
         playerLayer.frame = CGRect(
             x: view.bounds.width - width - margin,
             y: view.bounds.height - height - margin,
             width: width,
             height: height
         )
         
         playerLayer.setAffineTransform(transform)
     }
     
     // 🎭 動画の向きを取得
     private func getVideoTransform(for url: URL) -> CGAffineTransform {
         let asset = AVAsset(url: url)
         guard let track = asset.tracks(withMediaType: .video).first else { return .identity }
         return track.preferredTransform
     }
     
     // 📏 動画のサイズを取得
     private func getVideoSize(for url: URL) -> CGSize {
         let asset = AVAsset(url: url)
         guard let track = asset.tracks(withMediaType: .video).first else { return .zero }
         let size = track.naturalSize.applying(track.preferredTransform)
         return CGSize(width: abs(size.width), height: abs(size.height))
     }
     
     // 🎬 カメラ設定
     private func setupVideoSession() {
         session.sessionPreset = .high
         
         guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
               let input = try? AVCaptureDeviceInput(device: camera) else {
             print("❌ Error: Could not access camera")
             return
         }
         
         if session.canAddInput(input) { session.addInput(input) }
         if session.canAddOutput(videoOutput) { session.addOutput(videoOutput) }
         
         let connection = videoOutput.connection(with: .video)
         connection?.videoOrientation = .portrait  // 縦向きで録画
     }
     
     // 📷 カメラプレビュー
     private func setupPreviewLayer() {
         previewLayer = AVCaptureVideoPreviewLayer(session: session)
         previewLayer.videoGravity = .resizeAspectFill
         view.layer.addSublayer(previewLayer)
     }
     
     // 🎛 録画ボタン
     private func setupRecordingButton() {
         let button = UIButton(type: .system)
         button.setTitle("●", for: .normal)
         button.titleLabel?.font = UIFont.systemFont(ofSize: 40)
         button.setTitleColor(.red, for: .normal)
         button.addTarget(self, action: #selector(toggleRecording), for: .touchUpInside)
         view.addSubview(button)
         
         button.frame = CGRect(x: (view.bounds.width - 60) / 2,
                               y: view.bounds.height - 80,
                               width: 60,
                               height: 60)
     }
     
     // 📏 プレビューのレイアウト更新
     private func updatePreviewLayerFrame() {
         previewLayer.frame = view.bounds
     }
     
     private func updateRecordingButtonPosition() {
         // ボタンの位置は固定なので特に変更不要
     }
 }
 
//ITEncryption
 <key>ITSAppUsesNonExemptEncryption</key>
 <false/>
 
// ASAuthorizationControllerDelegate methods
func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
        let userIdentifier = appleIDCredential.user
        let fullName = appleIDCredential.fullName
        let email = appleIDCredential.email
        
        // Save credentials in CoreData
        saveUserInCoreData(userID: userIdentifier, name: fullName?.givenName, email: email)
        
        // Handle successful login
        print("Login successful: \(userIdentifier), \(fullName?.givenName ?? ""), \(email ?? "")")
    }
}

func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // Handle error during Apple authentication
    print("Error during Apple sign-in: \(error.localizedDescription)")
}

// CoreData save function
func saveUserInCoreData(userID: String, name: String?, email: String?) {
    // Assuming Core Data setup with an entity "User" that has attributes "id", "name", and "email"
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
    let context = appDelegate.persistentContainer.viewContext
    
    let entity = NSEntityDescription.entity(forEntityName: "User", in: context)!
    let newUser = NSManagedObject(entity: entity, insertInto: context)
    
    newUser.setValue(userID, forKey: "id")
    newUser.setValue(name, forKey: "name")
    newUser.setValue(email, forKey: "email")
    
    do {
        try context.save()
        print("User saved to CoreData")
    } catch {
        print("Failed to save user: \(error)")
    }
}
}
 
 // checking if user logged in or not
 import UIKit
 import AuthenticationServices

 class SceneDelegate: UIResponder, UIWindowSceneDelegate {

     var window: UIWindow?

     func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
 
 
 
 
         guard let windowScene = (scene as? UIWindowScene) else { return }

         let window = UIWindow(windowScene: windowScene)

         // ユーザーが既にログインしているかチェック
         if UserDefaults.standard.bool(forKey: "appoleAuthToken") {
             // ログイン済みの場合、メインタブバーを表示
             let mainTabBarController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MainTabBarController") as! UITabBarController
             mainTabBarController.selectedIndex = 2  // 移動したいタブのインデックス

             window.rootViewController = mainTabBarController
         } else {
             // ログイン画面を表示
             let loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "LoginViewController")
             window.rootViewController = loginViewController
         }

         self.window = window
         window.makeKeyAndVisible()
     }
 }
 
 //ASAuthorizationControllerDelegate methods
 
 func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
     
     if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
         
         let appleAuthToken = appleIDCredential.identityToken != nil ? String(data: appleIDCredential.identityToken!, encoding: .utf8) : "nilだよ~ん"
         UserDefaults.standard.set(appleAuthToken, forKey: "appleAuthToken")
         
         let userIdentifier = appleIDCredential.user
         let fullName = appleIDCredential.fullName
         let email = appleIDCredential.email
         
         let identifierString = userIdentifier.isEmpty ? "nilだよ~ん" : userIdentifier
         let givenName = fullName?.givenName ?? "nilだよ~ん"
         let emailString = email ?? "nilだよ~ん"
         
         print("Login successful: \(identifierString), \(givenName), \(emailString)")
         
         let tabBarVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController")
         tabBarVC.tabBarController?.selectedIndex = 0
         
         self.view.window?.rootViewController = tabBarVC
         self.view.window?.makeKeyAndVisible()
     }
 }
 
 mark:: map setting uikit
 import UIKit
 import MapKit

 class ViewController: UIViewController, CLLocationManagerDelegate {
     var mapView: MKMapView!
     var locationManager: CLLocationManager!

     override func viewDidLoad() {
         super.viewDidLoad()

         // 地図を作成
         mapView = MKMapView(frame: self.view.bounds)
         mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
         self.view.addSubview(mapView)

         // 現在位置を表示する設定
         mapView.showsUserLocation = true
         mapView.userTrackingMode = .follow

         // 位置情報の許可と設定
         locationManager = CLLocationManager()
         locationManager.delegate = self
         locationManager.desiredAccuracy = kCLLocationAccuracyBest
         locationManager.requestWhenInUseAuthorization()
         locationManager.startUpdatingLocation()
     }

     // 位置情報の許可状態が変更された場合の処理
     func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
         switch status {
         case .authorizedWhenInUse, .authorizedAlways:
             locationManager.startUpdatingLocation()
         case .denied, .restricted:
             print("位置情報の利用が許可されていません。")
         default:
             break
         }
     }

     // 位置情報が更新された場合の処理
     func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
         guard let location = locations.last else { return }

         // 現在位置を地図の中心に設定
         let coordinate = location.coordinate
         let region = MKCoordinateRegion(
             center: coordinate,
             span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
         )
         mapView.setRegion(region, animated: true)
     }

     func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
         print("位置情報の取得に失敗しました: \(error.localizedDescription)")
     }
 }
 import UIKit
 import MapKit

 class WaveViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
     var mkMapView: MKMapView!
     var locationManager: CLLocationManager!
     var selectedLocation: CLLocationCoordinate2D?
     var isTransitioning = false

     override func viewDidLoad() {
         super.viewDidLoad()

         // MapView setup
         mkMapView = MKMapView(frame: self.view.bounds)
         mkMapView.delegate = self
         self.view.addSubview(mkMapView)

         mkMapView.showsUserLocation = true
         mkMapView.userTrackingMode = .follow

         // Location manager setup
         locationManager = CLLocationManager()
         locationManager.delegate = self
         locationManager.requestWhenInUseAuthorization()
         locationManager.startUpdatingLocation()

         // Add example annotation
         let exampleAnnotation = MKPointAnnotation()
         exampleAnnotation.coordinate = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194) // Example coordinate
         exampleAnnotation.title = "Example Location"
         mkMapView.addAnnotation(exampleAnnotation)
     }

     // Annotation tap handling
     func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
         guard let annotation = view.annotation, !(annotation is MKUserLocation) else {
             // Ignore user location annotation
             return
         }

         if isTransitioning { return } // Prevent double transitions
         isTransitioning = true

         // Save selected annotation location
         selectedLocation = annotation.coordinate

         // Navigate to the WaveInfoViewController
         navigateToWaveInfoViewController()
     }

     // Navigate to WaveInfoViewController
     func navigateToWaveInfoViewController() {
         let waveInfoVC = WaveInfoViewController()
         waveInfoVC.coordinate = selectedLocation
         navigationController?.pushViewController(waveInfoVC, animated: true)

         // Reset the transition flag after navigation
         DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
             self.isTransitioning = false
         }
     }
 }

 class WaveInfoViewController: UIViewController {
     var coordinate: CLLocationCoordinate2D?

     override func viewDidLoad() {
         super.viewDidLoad()
         view.backgroundColor = .white

         // Display the passed coordinate
         if let coordinate = coordinate {
             let coordinateLabel = UILabel()
             coordinateLabel.text = "Latitude: \(coordinate.latitude), Longitude: \(coordinate.longitude)"
             coordinateLabel.textAlignment = .center
             coordinateLabel.translatesAutoresizingMaskIntoConstraints = false

             view.addSubview(coordinateLabel)
             NSLayoutConstraint.activate([
                 coordinateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                 coordinateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
             ])
         }
     }
 }

*/
