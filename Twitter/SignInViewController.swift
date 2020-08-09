//
//  SignInViewController.swift
//  Twitter
//
//  Created by 樋口裕貴 on 2020/07/13.
//  Copyright © 2020 Yuki Higuchi. All rights reserved.
//

import UIKit
import NCMB

class SignInViewController: UIViewController ,UITextFieldDelegate{
    
    @IBOutlet var userIdTextfield : UITextField!
    @IBOutlet var passTextField : UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        userIdTextfield.delegate = self
        passTextField.delegate = self
        
    }
    //キーボード閉じるコード
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func signin(){
        if userIdTextfield.text != nil && passTextField.text != nil {
            NCMBUser.logInWithUsername(inBackground: userIdTextfield.text!, password: passTextField.text!) { (user, error) in
                if error != nil {
                    print(error)
                }else{
                    //ログイン成功 ???
                    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootTabBarController")
                    UIApplication.shared.keyWindow?.rootViewController = rootViewController
                    
                    //ログイン状態の保持
                    let ud = UserDefaults.standard
                    ud.set(true, forKey: "isLogin")
                    ud.synchronize()
                }
            }
        }
    }
    
    @IBAction func forgetPass () {
        
    }
    
    

  
}
