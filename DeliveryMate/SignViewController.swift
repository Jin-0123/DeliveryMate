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
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

// UserInfoObject : 유저정보요청의 응답 맵핑에 필요한 객체를 선언한다.
class UserInfoObject: Mappable {
    var user_id = Int()
    required init?(map: Map) {}
    func mapping(map: Map) {
        user_id <- map["user_id"]
    }
}

class SignViewController : UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {
    let USER_URL = Constants.SERVER_URL+"/user"
    var callView : String?
    
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    @IBOutlet weak var googleSignOutButton: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    
    enum signInState { case signIn, signOut }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. sign in을 위한 초기화를 한다.
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        // 2. 로그인 상태가 아니라면, 유저정보를 초기화한다.
        if FIRAuth.auth()?.currentUser != nil {
            self.signConfigureUI(.signIn)
        } else {
            let appDomain = Bundle.main.bundleIdentifier
            UserDefaults.standard.removePersistentDomain(forName: appDomain!)
            self.signConfigureUI(.signOut)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if FIRAuth.auth()?.currentUser != nil {
            self.signConfigureUI(.signIn)
        } else {
            let appDomain = Bundle.main.bundleIdentifier
            UserDefaults.standard.removePersistentDomain(forName: appDomain!)
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
                var parameters : Parameters = [
                    "uid" : userId
                ]
                
                if let dong_code = UserDefaults.standard.string(forKey: Constants.User.USER_DONG_CODE) {
                    parameters["dong_code"] = dong_code
                }
                
                if let last_simple_address = UserDefaults.standard.string(forKey: Constants.User.USER_SIMPLE_ADDRESS) {
                    parameters["last_simple_address"] = last_simple_address
                }
                
                if let user_address = UserDefaults.standard.string(forKey: Constants.User.USER_ADDRESS) {
                    parameters["address"] = user_address
                }
                
                
                Alamofire.request(self.USER_URL, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseObject(completionHandler: {
                    (response: DataResponse<UserInfoObject>) in

                    if let userInfo = response.result.value {
                        UserDefaults.standard.set(userInfo.user_id, forKey: Constants.User.USER_ID)
                    }
                    
                    if self.callView == "modalView" {
                        self.dismiss(animated: true, completion: {
                            UserDefaults.standard.synchronize()
                        })
                    }
                })
            }
        
            if let userName = user?.displayName {
                UserDefaults.standard.set(userName, forKey: Constants.User.USER_NAME)
                self.signConfigureUI(.signIn)
                
            } else {
                self.signConfigureUI(.signOut)
            }
        }
    }
    
    
    
    @IBAction func googleSignOutButtonPressed() {
        let firebaseAuth = FIRAuth.auth()
        do {
            // 1. 파이어베이스 로그아웃을 한다.
            try firebaseAuth?.signOut()
           
            // 2. UserDefault 정보를 삭제한다.
            let appDomain = Bundle.main.bundleIdentifier
            UserDefaults.standard.removePersistentDomain(forName: appDomain!)
            UserDefaults.standard.synchronize()
            
            // 3. 로그아웃 UI로 변경한다.
            signConfigureUI(.signOut)
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    
    // MARK: UI Functions
    func signConfigureUI(_ signState: signInState) {
        switch(signState) {
        case .signIn:
            if UserDefaults.standard.object(forKey: Constants.User.USER_NAME) != nil {
                self.userNameLabel.text = UserDefaults.standard.object(forKey: Constants.User.USER_NAME) as! String?
                self.googleSignInButton.isHidden = true
                self.googleSignOutButton.isHidden = false
            }
            
        case .signOut:
            self.userNameLabel.text = ""
            self.googleSignInButton.isHidden = false
            self.googleSignOutButton.isHidden = true
            
            
        }
    }
}
