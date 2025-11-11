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
    
    var formData = FormData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Wave gallery"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always

        
        let container = try! ModelContainer(for: SurfLog2.self)

        // Do any additional setup after loading the view.
        let swiftUIView = NavigationStack {
            MylogSwiftUIView()
                .environmentObject(formData)
                
        }
        .modelContainer(container)
        
        let hostingController = UIHostingController(rootView: swiftUIView)
        addChild(hostingController)
        hostingController.view.frame = view.bounds
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsUpdateOfSupportedInterfaceOrientations()
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        
        UserDefaults.standard.removeObject(forKey: "appleAuthToken")
        UserDefaults.standard.removeObject(forKey: "useremail")
        UserDefaults.standard.synchronize()
        
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "ViewController") as? LoginViewController {
            
            self.view.window?.rootViewController = viewController
            self.view.window?.makeKeyAndVisible()
            
            print("logout success")
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
