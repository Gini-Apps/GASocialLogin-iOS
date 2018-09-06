//
//  ViewController.swift
//  GASocialLogin
//
//  Created by idoMeirov on 09/04/2018.
//  Copyright (c) 2018 idoMeirov. All rights reserved.
//

import UIKit
import GASocialLogin

class FacebookViewController: UIViewController {

    @IBOutlet weak var resultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginDidTap(_ sender: Any)
    {
        GASocialLogin.shard.facebookLoginService?.loginUser(from: self) {  (result) in

            DispatchQueue.main.async { [weak self] in

                switch result {
                case .success(let user, let userData):

                    self?.resultLabel.text = "user.email: \(user.email ?? "") \nuser.facebookId: \(user.facebookId ?? "") \nuser.facebookToken: \(user.facebookToken ?? "")"
                    print("FacebookViewController userData: \(userData)")

                case .cancelled:

                    self?.resultLabel.text = "cancelled"

                default:

                    self?.resultLabel.text = "error"

                }
            }
        }
    }
    
    @IBAction func customFieldsAndPermissionsLoginDidTap(_ sender: Any)
    {
        let fields = "cover,picture.type(large),id,name,first_name,last_name,gender,birthday,email,location,hometown"
        
        let permissions = ["email","public_profile"]
        GASocialLogin.shard.facebookLoginService?.loginUser(byPermissions: permissions, byFields: fields, from: self) {  (result) in

            DispatchQueue.main.async { [weak self] in

                switch result {
                case .success(let user, let userData):

                    self?.resultLabel.text = "user.email: \(user.email ?? "") \nuser.facebookId: \(user.facebookId ?? "") \nuser.facebookToken: \(user.facebookToken ?? "")"
                    print("FacebookViewController userData: \(userData)")

                case .cancelled:

                    self?.resultLabel.text = "cancelled"

                default:

                    self?.resultLabel.text = "error"

                }
            }

        }
    }
    
    @IBAction func permissionsDidTap(_ sender: Any)
    {
        print(GASocialLogin.shard.facebookLoginService?.logInToken ?? "")
        guard let permissions = GASocialLogin.shard.facebookLoginService?.currentTokenPermissions else { return }
        print(permissions)
//
    }
    
    
}

