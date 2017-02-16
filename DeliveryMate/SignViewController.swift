//
//  SignViewController.swift
//  DeliveryMate
//
//  Created by 장진영 on 2017. 2. 7..
//  Copyright © 2017년 Jinyoung. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn


class SignViewController : UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    @IBOutlet weak var googleSignOutButton: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    
    let userDefaults = UserDefaults.standard
    var userInfo: UserInfo?
    enum signInState { case signIn, signOut }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. sign in을 위한 초기화를 한다.
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        
        // 2. 이미 sign in 상태라면, current user값을 user객체에 저장한다.
        if let displayName = FIRAuth.auth()?.currentUser?.displayName {
            userInfo = UserInfo.init(userName: displayName)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if userInfo != nil {
            self.signConfigureUI(.signIn)
        } else {
            self.signConfigureUI(.signOut)
        }
    }
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            print(error)
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                          accessToken: authentication.accessToken)
        
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            if let error = error {
                print(error)
                return
            }
            
            if let userId = user?.uid {
            }
            
            if let userName = user?.displayName {
                self.userInfo = UserInfo.init(userName: userName)
                userDefaults.string(forKey: <#T##String#>)

                self.signConfigureUI(.signIn)
                
            } else {
                self.signConfigureUI(.signOut)
            }
            
        }
    }
    
    
    
    @IBAction func googleSignOutButtonPressed() {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            userInfo = nil
            signConfigureUI(.signOut)
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    
    // MARK: UI Functions
    func signConfigureUI(_ signState: signInState) {
        switch(signState) {
        case .signIn:
            self.userNameLabel.text = userInfo?.userName
            self.googleSignInButton.isHidden = true
            self.googleSignOutButton.isHidden = false
            
        case .signOut:
            self.userNameLabel.text = "Sign In"
            self.googleSignInButton.isHidden = false
            self.googleSignOutButton.isHidden = true
            
            
        }
    }
}
