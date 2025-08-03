//
//  SceneDelegate.swift
//  World Wide Wave
//
//  Created by Ryutarou Nakajima on 2024/09/26.
//

import UIKit
import AuthenticationServices

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        //guard (scene is UIWindowScene) else { return }
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        self.window = UIWindow(windowScene: windowScene)
        
        // cheking if user logeed in or not
        if let appleAuthToken = UserDefaults.standard.string(forKey: "appleAuthToken"), !appleAuthToken.isEmpty {
            // トークンが存在し、ログイン済みの場合
            if let tabBarVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "TabBarController") as? UITabBarController {
                
            let hasLoggedInBefore = UserDefaults.standard.bool(forKey: "hasLoggedInBefore")
                if hasLoggedInBefore {
                    
                    let lastIndex = UserDefaults.standard.integer(forKey: "lastSelectedTabIndex")
                    if lastIndex < (tabBarVC.viewControllers?.count ?? 0) {
                        tabBarVC.selectedIndex = lastIndex
                    } else {
                        tabBarVC.selectedIndex = 0
                    }
                } else {
                    
                    tabBarVC.selectedIndex = 1
                    UserDefaults.standard.set(true, forKey: "hasLoggedInBefore")
                    UserDefaults.standard.set(1, forKey: "lastSelectedTabIndex")
                }
                self.window?.rootViewController = tabBarVC
               /* let lastIndex = UserDefaults.standard.integer(forKey: "lastSelectedTabIndex")
                tabBarVC.selectedIndex = lastIndex
                window?.rootViewController = tabBarVC
                */
                //tabBarVC.selectedIndex = 1
                //self.window?.rootViewController = tabBarVC
            }
            
        } else {
            // トークンがない、または空の場合（未ログイン）
            let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ViewController")
            self.window?.rootViewController = loginVC
        }
        
        self.window?.makeKeyAndVisible()
    }
    
    
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        // Save changes in the application's managed object context when the application transitions to the background.
        if let tabBarVC = self.window?.rootViewController as? UITabBarController {
            let selectIndex = tabBarVC.selectedIndex
            UserDefaults.standard.set(selectIndex, forKey: "lastSelectedTabIndex")
        }
        
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    
    
}
