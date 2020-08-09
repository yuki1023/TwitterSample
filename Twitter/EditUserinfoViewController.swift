//
//  EditUserinfoViewController.swift
//  Twitter
//
//  Created by 樋口裕貴 on 2020/07/13.
//  Copyright © 2020 Yuki Higuchi. All rights reserved.
//

import UIKit
import NCMB
import NYXImagesKit

class EditUserinfoViewController: UIViewController , UITextFieldDelegate,UITextViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate{

    @IBOutlet var userImageView : UIImageView!
       @IBOutlet var userNameTextField : UITextField!
       @IBOutlet var introductionTextView : UITextView!


    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userNameTextField.delegate = self
        introductionTextView.delegate = self
        
        if let user = NCMBUser.current(){
            userNameTextField.text = user.object(forKey: "displayName") as? String
                   introductionTextView.text = user.object(forKey: "introduction") as? String
                   
                   //画像の読み込みコード　ファイルは直接取得できる
                           let file = NCMBFile.file(withName: user.objectId, data: nil) as! NCMBFile
                                 file.getDataInBackground { (data, error) in
                                     if error != nil{
                                         print(error)
                                     }else{
                                      if data != nil{
                                         let image = UIImage(data: data!)
                                         self.userImageView.image = image
                                      }
                                     }
                                 }
        }else{
            //            NCMBuser.currentがnilだったとき
            //            ログアウト成功
                        let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
                            let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
                                           UIApplication.shared.keyWindow?.rootViewController = rootViewController
                                           
                                           //ログイン状態の保持
                                           let ud = UserDefaults.standard
                                           ud.set(false, forKey: "isLogin")
                                           ud.synchronize()
            
        }
       
        
        //画像を丸くする
                      userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
                      userImageView.layer.masksToBounds = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
    return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        
        return true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        
        //写真の容量をリサイズ NYXを忘れない
        let resizedImage = selectedImage.scale(byFactor: 0.3)
              
              
              picker.dismiss(animated: true, completion: nil)
              
//        UIImage型をデータ型になおす
        let data = resizedImage?.pngData()!
              let file = NCMBFile.file(withName: NCMBUser.current()?.objectId, data: data) as! NCMBFile
              file.saveInBackground({ (error) in
                  if error != nil{
                      print(error)
                  }else{
                      self.userImageView.image = selectedImage            }
              }) { (progress) in
                  print(progress)
              
    }
    }
    
    @IBAction func closeEditViewController () {
        self.dismiss(animated: true, completion: nil)
    }

    
    
    @IBAction func selsctImage (){
    //        アラート　アクションシートは選択に出てくるシート
            let actionController = UIAlertController(title: "画像の選択", message: "画像を選択してください", preferredStyle: .actionSheet)
            
            let cameraAction = UIAlertAction(title: "カメラ", style: .default) { (action) in
                //カメラ起動のコード
                if UIImagePickerController.isSourceTypeAvailable(.camera){
                let picker = UIImagePickerController()
                //カメラからソースをひっぱてくる
                picker.sourceType = .camera
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
                }else{
                    print("この端末では使用できません")
                }
            }
        
        
            let albumAction = UIAlertAction(title: "フォトライブラリ", style: .default) { (action) in
                //アルバムの起動
                
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                 let picker = UIImagePickerController()
                           //フォトライブラリからソースをひっぱてくる
                picker.sourceType = .photoLibrary
                           picker.delegate = self
                           self.present(picker, animated: true, completion: nil)
                
                }else{
                    print("この端末では使用できません")
                }
        }
    //    キャンセルコード
            let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (action) in
                actionController.dismiss(animated: true, completion: nil)
            }
            
    //       使うアクションの選択
            actionController.addAction(cameraAction)
            actionController.addAction(albumAction)
            actionController.addAction(cancelAction)
            //アクションを表示させるコード
            self.present(actionController,animated: true,completion: nil)
            
        }
    
    @IBAction func saveUserInfo () {
           let user = NCMBUser.current()
           user?.setObject(userNameTextField.text, forKey: "displayName")
           user?.setObject(introductionTextView.text, forKey: "introduction")
           user?.saveInBackground({ (error) in
               if error != nil{
                   print(error)
               }else{
                   self.dismiss(animated: true, completion: nil)
               }
           })
       }
   

}
