//
//  SignUpViewController.swift
//  Twitter
//
//  Created by 樋口裕貴 on 2020/07/13.
//  Copyright © 2020 Yuki Higuchi. All rights reserved.
//

import UIKit
import NCMB
class SignUpViewController: UIViewController , UITextFieldDelegate{


  @IBOutlet var userIdTextField : UITextField!
  @IBOutlet var emailTextField : UITextField!
  @IBOutlet var passTextField : UITextField!
  @IBOutlet var confirmTextField : UITextField!
  
  override func viewDidLoad() {
      super.viewDidLoad()
      
      userIdTextField.delegate = self
      emailTextField.delegate = self
      passTextField.delegate = self
      confirmTextField.delegate = self
      
      
      
      // Do any additional setup after loading the view.
  }
 
//    テキストフィールドを閉じるコード
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      textField.resignFirstResponder()
      return true
  }
  
  @IBAction func signUp(){
      let user = NCMBUser()
    
//    文字数制限
//    if userIdTextField.text!.count >= 4{
//        print("文字数足らない")
//        return
//    }
    
    
//      userの中に入れられるものは決まっている
      user.userName = userIdTextField.text!
      user.mailAddress = emailTextField.text!
      print(emailTextField.text)
      
      if passTextField.text != confirmTextField.text {
          print("不一致")
          
      }else{
          
          user.password = passTextField.text
         
          user.signUpInBackground { (error) in
              if error != nil{
                  //エラーがある時
                  print(error)
              }else{
//                /登録成功
//メインのストーリーボードを呼び出す
                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootTabBarController")
//                画面の奥底??
                UIApplication.shared.keyWindow?.rootViewController = rootViewController
                
                //ログイン状態の保持
                let ud = UserDefaults.standard
                ud.set(true, forKey: "isLogin")
                ud.synchronize()
                
                let groupACL = NCMBACL()
                                
                                groupACL.setReadAccess(true, for: NCMBUser.current())
                                groupACL.setWriteAccess(true, for: NCMBUser.current())
                                
                                //全てのユーザの権限
                                //setPublicReadAccessをtrueにすれば他人の情報を取得可能！
                                //基本的にsetPublicWriteAccessをtrueにすると、他人でもユーザ消したり、情報変更できてしまうから注意
                                groupACL.setPublicReadAccess(true)
                                groupACL.setPublicWriteAccess(true)

                                //userクラスにこれまで設定してきたACL情報をセット
                                user.acl = groupACL

                                //userデータ(設定したacl情報)を保存する
                                user.save(nil)
                                
                                
                               
                            }
                        }
                    }
                }
                
                
            

}
