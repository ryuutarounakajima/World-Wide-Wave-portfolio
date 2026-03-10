//
//  ProfileViewController.swift
//  World Wide Wave
//
//  Created by Ryutarou Nakajima on 2024/10/22.
//

import UIKit
import SwiftUI
import AuthenticationServices
import SwiftData

class MylogViewController: UIViewController {
    
   
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    
    @IBOutlet weak var mypageButton: UIBarButtonItem!
    
    var formData = FormData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Recent"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always

        
        // _ = try! ModelContainer(for: SurfLog2.self, UserData.self)

        // Do any additional setup after loading the view.
        let swiftUIView =
        MylogSwiftUIView()
            .environmentObject(formData)
            .modelContainer(ModelContainerProvider.shared)
        
        
       
        
        let hostingController = UIHostingController(rootView: swiftUIView)

        addChild(hostingController)
        view.addSubview(hostingController.view)

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        hostingController.didMove(toParent: self)

    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .landscapeRight, .landscapeLeft]
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsUpdateOfSupportedInterfaceOrientations()
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        
        //UserDefaults.standard.removeObject(forKey: "appleAuthToken")
        //UserDefaults.standard.removeObject(forKey: "useremail")
        //UserDefaults.standard.synchronize()
        
        _ = KeychainService.shared.delete(for: "appleAuthToken")
        print("Logout success: token deleted")
        
      /*   if let viewController = storyboard?.instantiateViewController(withIdentifier: "ViewController") as? LoginViewController {
            
            self.view.window?.rootViewController = viewController
            self.view.window?.makeKeyAndVisible()
       }
       */
            resetToLoginRoot()
            print("logout success")
        
        
        
    }
    
    
    @IBAction func myPageButoonPressed(_ sender: Any) {
        
        print("my page sheet tapped")
        formData.showMyPagesheet = true
    }
  
    // MARK: - Root reset helper
    private func resetToLoginRoot() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        // Ensure the storyboard ID of the login screen is set to "LoginViewController"
        let loginVC = storyboard.instantiateViewController(withIdentifier: "ViewController")

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = loginVC
            window.makeKeyAndVisible()
        } else if let window = self.view.window {
            window.rootViewController = loginVC
            window.makeKeyAndVisible()
        } else {
            // Fallback: present modally if window not found
            loginVC.modalPresentationStyle = .fullScreen
            self.present(loginVC, animated: true, completion: nil)
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
