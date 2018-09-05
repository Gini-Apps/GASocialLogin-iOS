//
//  GoogleViewController.swift
//  GASocialLogin_Example
//
//  Created by ido meirov on 05/09/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import GASocialLogin

class GoogleViewController: UIViewController
{
    // MARK: - Property
    @IBOutlet weak var resultLabel: UILabel!
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        GASocialLogin.GAGoogleLoginService.clientIdentifier = "241630699163-uhj5kr61bpau24tgu86pr2ne2to30nef.apps.googleusercontent.com"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBActions
    @IBAction func loginDidTap(_ sender: Any)
    {
        
        GASocialLogin.GAGoogleLoginService.shard.loginWithGmail(forClientIdentifier: "241630699163-uhj5kr61bpau24tgu86pr2ne2to30nef.apps.googleusercontent.com",viewController: self) { (result) in
            
            DispatchQueue.main.async { [weak self] in
                
                switch result {
                case .success(let user):
                    
                    self?.resultLabel.text = "user.profile.email: \(user.profile.email ?? "") \nuser.authentication.clientID: \(user.authentication.clientID ?? "") "
                    
                case .error(let error):
                    
                    self?.resultLabel.text = error.localizedDescription
                    
                }
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
