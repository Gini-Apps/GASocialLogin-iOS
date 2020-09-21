//
//  AppleViewController.swift
//  GASocialLogin_Example
//
//  Created by Ido Meirov on 01/09/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import GASocialLogin

class AppleViewController: UIViewController
{

    // MARK: - Property
    @IBOutlet weak var resultLabel: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Methods
    @available(iOS 13.0, *)
    func handleAppleResult(_ result: GAAppleSignInResult)
    {
        switch result
        {
        case .success(let user):
            
            UserStorage.shared.saveAppleUser(user)
            self.resultLabel.text = "user.email: \(user.email ?? "") \nuser.userID: \(user.user)"

            
        case .error(let error):
                                
            self.resultLabel.text = error.localizedDescription
        }
    }
    
    @available(iOS 13.0, *)
    func signOutAppleUser()
    {
        UserStorage.shared.cleanAppleUser()
        GASocialLogin.shared.appleLoginService?.signOut()
    }
    
    // MARK: - IBActions
    @IBAction func loginDidTap(_ sender: Any)
    {
        if #available(iOS 13.0, *) {
            GASocialLogin.shared.appleLoginService?.loginWithApple(with: { (result) in
                
                DispatchQueue.main.async { [weak self] in
                    
                    guard let strongSelf = self else { return }
                    strongSelf.handleAppleResult(result)
                }
            })
        } else {
            // Fallback on earlier versions
        }
    }
    
    @IBAction func silentLoginWithApple(_ sender: Any)
    {
        if #available(iOS 13.0, *) {
            GASocialLogin.shared.appleLoginService?.silentLoginWithApple(completion: { [weak self] (isLogIn, error) in
                
                DispatchQueue.main.async { [weak self] in
                    
                    guard let strongSelf = self else { return }
                    
                    guard error == nil else {
                        
                        strongSelf.resultLabel.text = error?.localizedDescription
                        return
                    }
                    
                    guard isLogIn, let user = UserStorage.shared.bringAppleUser() else
                    {
                        strongSelf.signOutAppleUser()
                        return
                    }
                    
                    strongSelf.resultLabel.text = "user.email: \(user.email ?? "") \nuser.userID: \(user.user)"
                }
            })
        } else {
            // Fallback on earlier versions
        }
    }
    
    @IBAction func signOut(_ sender: Any)
    {
        if #available(iOS 13.0, *) {
            signOutAppleUser()
        } else {
            // Fallback on earlier versions
        }
    }
}
