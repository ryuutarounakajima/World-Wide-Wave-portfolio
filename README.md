# 🌊 World Wide Wave
link to the app↓

[![App Store](https://img.shields.io/badge/App_Store-Download-blue?logo=apple&style=for-the-badge)](https://apps.apple.com/us/app/world-wide-wave/id6758753103)

This app is available on the appstore.
It showcases the features and UI elements that have been completed so far, without including any private assets.
This branch will be updated whenever the main branch receives major updates.

このアプリはアップstoreでインストール可能です。
これまでに完成している機能や UI を、プライベートなデータを含めずにまとめています。
mainブランチに大きな更新が入ったときに随時更新されます。

---

## 🎬 App Demo
<img src="screenshots/loginview.gif" alt="Login Screen" height= "400" width= "200"> 
<img src="screenshots/mapview.gif" alt="Login Screen" height= "400" width= "200"> 
<img src="screenshots/mylogview.gif" alt="Login Screen" height= "400" width= "200"> 

---

## 📲 Overview

World Wide Wave is an ios app built using Swiftui and Uikit.
This app allows users to :
- Record surf condition
- Pin surf point on a map
- Log wave conditions using a condition list with photos or videos.
- Manage surf logs in a visual interface


World Wide Wave は SwiftUI と UIKit を使用して開発された iOS アプリです。
このアプリでは以下が可能です。
- サーフコンディションを記録
- 地図上にサーフポイントをピン留め
- コンディションリストと写真・動画を使って波の状態を記録
- 視覚的なインターフェースでサーフログを管理

---

## 🏗 Architecture

This project follows the MVVM architecture pattern.

このプロジェクトではMVVMアーキテクチャを採用しています。

--- 
```
View (SwiftUI / UIKit)
        │
        ▼
ViewModel (State / FormData)
        │
        ▼
Model (SwiftData)
        │
        ▼
Persistence (CloudKit)
```
---

### ⚙️Model

Implemented using SwiftData @Model
- SurfLog2
- userData

Stores surf session information such as:
- location
- wave condition
- wind / tide
- photos and videos
- generated video thumbnails
- user data

### 𝌭ViewModel

Implemented using:
- FormData

Manages form and user input such as:
- form validation
- thumbnail generation
- media processing
- saving data to SwiftData
- Video thumbnails are generated using AVFoundation.

### ⌗View

SwiftUI views render the UI Nd react to ViewModel state.
Examples:
- FormViewModel 

File:[Struct_tools.swift](./World%20Wide%20Wave/Struct_tools.swift)

---

## 🧰 Tech Stack
<a href="#">
<img src="https://img.shields.io/badge/SwiftUI-0A84FF?style=for-the-badge&logo=swift&logoColor=white"> <img src="https://img.shields.io/badge/UIKit-2396F3?style=for-the-badge&logo=apple&logoColor=white"> <img src="https://img.shields.io/badge/MapKit-007AFF?style=for-the-badge&logo=apple-maps&logoColor=white"> <img src="https://img.shields.io/badge/CoreLocation-007AFF?style=for-the-badge&logo=apple&logoColor=white"> <img src="https://img.shields.io/badge/SwiftData-FA7343?style=for-the-badge&logo=apple&logoColor=white"> <img src="https://img.shields.io/badge/CloudKit-0A84FF?style=for-the-badge&logo=icloud&logoColor=white"> <img src="https://img.shields.io/badge/AVFoundation-000000?style=for-the-badge&logo=apple&logoColor=white">
</a>

---


## 🛠 Key Features (MVP)

### ⏺️ SurfLog Recording

user can record surf seddions including:
- location
- wave conditions
- wind and tide
- photos and videos

サーフセッションの情報を記録できます。
- 位置情報
- 波のサイズやコンディション
- 風や潮位
- 写真 / 動画

### 📍 Map Interaction

Users can long-press the map to register surf points.
MapKit is implemented using UIKit to achieve deeper UI customization.

ユーザーは マップを長押しすることでサーフポイントを登録できます。
MapKit の細かい UI カスタマイズを実現するため、UIKit を併用しています。

File:[WaveMapViewController.swift](./World%20Wide%20Wave/WaveMap/mapView/WaveMapViewController.swift)

### 📋 Surf Log List

User can view previously recorded surf logs.
SwiftData and CloudKit is used to local persistence.

ユーザーが記録したサーフログを一覧表示できます。
SwiftData を利用してログを保存しています。

File:[myLog](./World%20Wide%20Wave/myLog)

### 📷 Custom Camera System

This app implements a custom camera and video recording system using AVFoundation.
Features:
- photo capture
- video recording
- landscape video support
- automatic video thumbnail generation

AVFoundation を使用して独自のカメラ機能を実装しています。
機能:
- 写真撮影
- 動画撮影
- 横画面動画対応
- 動画サムネイル自動生成

<img src="screenshots/unifiedcamera.png" height="400"> 
<img src="screenshots/unifiedcamera.gif" height="200">

File:[unified_camera](./World%20Wide%20Wave/WaveMap/infoView/unified_camera)

---

## 📂 Project Structure

---
```
WorldWideWave
│
├─ WaveMap
│   ├─ mapView
│   │   └─ WaveMapViewController.swift
│   │
│   └─ infoView
│       ├─ unified_camera
│       │   └─ UnifiedCameraViewController.swift
│       │
│       └─ WaveInfoViewController.swift
│
├─ myLog
│   └─ MylogSwiftUIView.swift
│
├─ Login
│   └─ LoginViewController.swift
│
└─ Models
    ├─ SurfLog2
    └─ UserData
```
--- 

## 🚀 Future Improvements

- Cloud synchronization improvements  Cloud同期の改善
- Advanced wave analytics  波データ分析機能
- Community surf point sharing  サーフポイント共有機能
- Apple Watch integration  Apple Watch対応

---
 
