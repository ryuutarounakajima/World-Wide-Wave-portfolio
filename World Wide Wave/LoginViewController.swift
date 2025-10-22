//
//  loginViewController.swift
//  World Wide Wave
//
//  Created by Ryutarou Nakajima on 2024/09/26.
//

import UIKit
import AuthenticationServices
import CoreData

class LoginViewController: UIViewController, ASAuthorizationControllerDelegate {
    
    @IBOutlet weak var signUpImageView: UIImageView!
    
    @IBOutlet weak var signUpWithApple: UIButton!
    
    private let  imageLogo: UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Logo")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.layer.cornerRadius = 100
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private var gradientLayer: CAGradientLayer!
    
    private var backgroundColor: CAGradientLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUp()
        animateZoom()
        setBackgroundColor()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundColor?.frame = view.bounds
    }
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    @IBAction func SignUpWithAppleTapped(_ sender: Any) {
        performAppleSingnIn()
    }
    
    @IBAction func loginButton(_ sender: Any) {
        
        if isLoggedIn() {
            
            if let tabBarVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
                
                tabBarVC.selectedIndex = 1
                self.view.window?.rootViewController = tabBarVC
                self.view.window?.makeKeyAndVisible()
            }
            
            print("Already logged in")
            
        } else {
            performAppleSingnIn()
        }
        
    }
    
    
    private func setUp() {
        
        signUpImageView.layer.cornerRadius = 20
        signUpImageView.clipsToBounds = true
        signUpImageView.contentMode = .scaleAspectFill
        
        
    }
    
    private func isLoggedIn() -> Bool {
        
        if let token = UserDefaults.standard.string(forKey: "appleAuthToken") {
            return !token.isEmpty
        }
        return false
    }
    
    //MARK: - Zoom Animation
    private func animateZoom() {
        
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor.blue.cgColor,
            UIColor.cyan.cgColor,
            UIColor.white.cgColor,
            UIColor.systemBrown.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 1)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        
        view.layer.addSublayer(gradientLayer)
        view.addSubview(imageLogo)
        
        NSLayoutConstraint.activate([
            imageLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageLogo.widthAnchor.constraint(equalToConstant: 200),
            imageLogo.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        imageLogo.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        UIView.animate(withDuration: 2.0, delay: 0, options: [.curveEaseOut],
                       animations: {
            self.imageLogo.transform = CGAffineTransform(scaleX: 3.0, y: 3.0)
            self.imageLogo.alpha = 0.0
            
        }, completion: nil)
        
        let fadeAnimation = CABasicAnimation(keyPath: "opacity")
        fadeAnimation.fromValue = 1.0
        fadeAnimation.toValue = 0.0
        fadeAnimation.duration = 3.0
        fadeAnimation.fillMode = .forwards
        fadeAnimation.isRemovedOnCompletion = false
        
        gradientLayer.add(fadeAnimation, forKey: "fadeAnimation")
        
        
    }
    
    //MARK: - Apple Singn-IN function
    func performAppleSingnIn() {
        
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationContoller = ASAuthorizationController(authorizationRequests: [request])
        
        authorizationContoller.delegate = self
        authorizationContoller.performRequests()
        
    }
    
    //MARK: - ASAuthorizationControllerDelegate methods
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            
            
            let appleAuthToken = appleIDCredential.identityToken != nil ? String(data: appleIDCredential.identityToken!, encoding: .utf8) : "nilだよ~ん"
            
            UserDefaults.standard.set(appleAuthToken, forKey: "appleAuthToken")
            
            
            
            let userIdentifier = appleIDCredential.user
            
            let fullName = appleIDCredential.fullName
            
            let email = appleIDCredential.email
            
            print("appleAuthToken: \(appleAuthToken ?? "nilだよ~ん")")
            print("userIdentifier: \(userIdentifier.isEmpty ? "nilだよ~ん" : userIdentifier)")
            print("givenName: \(fullName?.givenName ?? "nilだよ~ん")")
            print("email: \(email ?? "nilだよ~ん")")
            print("login sucess!")
            
            
            if let tabBarVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
                
                tabBarVC.selectedIndex = 1
                self.view.window?.rootViewController = tabBarVC
                self.view.window?.makeKeyAndVisible()
            }
        }
        
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        
        print("Error: \(error.localizedDescription)")
    }
    
    //MARK: - backgroun color
    private func setBackgroundColor() {
        backgroundColor = CAGradientLayer()
        backgroundColor.frame = view.bounds
        backgroundColor.colors = [
            UIColor.blue.cgColor,
            UIColor.cyan.cgColor,
            UIColor.white.cgColor,
            UIColor.systemBrown.cgColor
        ]
        
        backgroundColor.startPoint = CGPoint(x: 1, y: 1) // bottomTrailing
           backgroundColor.endPoint = CGPoint(x: 0, y: 0)   // topLeading
           view.layer.insertSublayer(backgroundColor, at: 0)
    }
    
    
}

