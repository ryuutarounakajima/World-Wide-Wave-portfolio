# World Wide Wave (Portfolio Branch)

This branch contains the portfolio version of the World Wide Wave iOS app.
It showcases the features and UI elements that have been completed so far, without including any private assets.
This branch will be updated whenever the main branch receives major updates.

このブランチは World Wide Wave iOS アプリのポートフォリオ版です。
これまでに完成している機能や UI を、プライベートなデータを含めずにまとめています。
mainブランチに大きな更新が入ったときに随時更新されます。

--

## 📲 Overview

World Wide Wave is an ios app built using Swiftui and Uikit.
It allows users to explore wave information, map interactions, and 
view visual elements.

This portfolio branch:

- Demonstrates selected featres using mock assets.
- Includes screenshots and brief descriptions.
- Provides a simplified, safe-to-share version of the project.

World Wide Wave は SwiftUI と UIKit を使用して開発された iOS アプリです。
波の情報確認、地図上のインタラクション、ビジュアル UI などを備えています。

このポートフォリオブランチは：
- モックデータを用いて主要機能を確認できる
- スクリーンショットと簡単な説明付き
- 公開用に安全に整理されたバージョン

--

## ⚙️features


### Login view

Authentication view for Apple users only.

Apple でサインイン専用の認証画面です。

<img src="screenshots/loginview.png" alt="Login Screen" height= "400">

File:[LoginViewController.swift](./World%20Wide%20Wave/LoginViewController.swift)



### MapView(Surf Point Registration)

Users can long-press on the map to register surf point location.

マップを長押しすることで、新しいサーフポイントを登録できます。

<img src="screenshots/mapview.gif" alt="Login Screen" height= "400">

Flie: [WaveMapViewController](./World%20Wide%20Wave/WaveMap/mapView/WaveMapViewController.swift)

File: [WaveInfoSwifUIViewController](./World%20Wide%20Wave/WaveMap/mapView/WaveMapViewController.swift) 


### MylogView(Coleection of User's Wave Logs)

Users can view a list of their recorded wave logs from the other tabs.

他のタブ画面(Mapview)で記録した波ログを一覧で確認できます。

<img src="screenshots/mylogView.gif" alt="log collections" height="400">

Flie:
    [MylogSwiftUiView](./World%20Wide%20Wave/myLog/MylogSwiftUIView.swift)
 

📦 Clone This Portfolio Branch

You can clone this portfolio branch and open it in Xcode using:

このポートフォリオブランチは Xcode でクローンして開くことができます:

git clone -b portfolio https://github.com/ryuutarounakajima/World-Wide-Wave-portfolio.git


