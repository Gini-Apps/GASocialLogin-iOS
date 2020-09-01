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
    func handleAppleResult(_ result: GAAppleSignInResult)
    {
        switch result
        {
        case .success(let user):
            
            self.resultLabel.text = "user.email: \(user.email ?? "") \nuser.userID: \(user.user) "

            
        case .error(let error):
                                
            self.resultLabel.text = error.localizedDescription
        }
    }
    
    // MARK: - IBActions
    @IBAction func loginDidTap(_ sender: Any)
    {
        GASocialLogin.shared.appleLoginService?.loginWithApple(with: { (result) in
            
            DispatchQueue.main.async { [weak self] in
                
                guard let strongSelf = self else { return }
                strongSelf.handleAppleResult(result)
            }
        })
    }
    
    @IBAction func signOut(_ sender: Any)
    {
        GASocialLogin.shared.appleLoginService?.signOut()
    }
}
