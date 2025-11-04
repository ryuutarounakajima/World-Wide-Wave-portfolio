//
//  LoadingView.swift
//  World Wide Wave
//
//  Created by Ryutarou Nakajima on 2025/09/07.
//

import SwiftUI
import UIKit

struct UIKitRootViewControllerRepresentable: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> some UIViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rootVC = storyboard.instantiateViewController(identifier: "TabBarController")
        
        return rootVC
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

struct LoadingView: View {
    @State private var scale: CGFloat = 0.1
    @State private var opacity: CGFloat = 1.0
    var onFinished: () -> Void
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.blue, .cyan, .white, .brown]),
                          startPoint: .bottomTrailing,
                          endPoint: .topLeading)
            .ignoresSafeArea()
            
            Image("Logo")
                .resizable()
                .scaledToFill()
                .frame(width: 200, height: 200)
                .clipShape(Circle())
                .scaleEffect(scale)
                .opacity(opacity)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                self.scale = 3.0
                self.opacity = 0.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                onFinished()
            }
        }
    }
}

struct LoadingViewWrapper: View {
    @State private var finished: Bool = false
    
    var body: some View {
        if finished {
            UIKitRootViewControllerRepresentable()
        } else {
            LoadingView {
                finished = true
            }
        }
    }
}
#Preview {
    LoadingView( onFinished: {})
}
