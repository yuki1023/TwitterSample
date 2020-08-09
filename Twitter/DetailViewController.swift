//
//  DetailViewController.swift
//  Twitter
//
//  Created by 樋口裕貴 on 2020/07/22.
//  Copyright © 2020 Yuki Higuchi. All rights reserved.
//

import UIKit
import NCMB
import SVProgressHUD
import Kingfisher

class DetailViewController: UIViewController {
  
    
    
    
    var postId: String!
    
    var postData : NCMBObject!
    
    var userData : NCMBUser!
    
    

    
    @IBOutlet var userImageView : UIImageView!
    
    @IBOutlet var userNameLabel : UILabel!
    
     @IBOutlet var photoImageView : UIImageView!
    
    

    @IBOutlet var tweetTextView : UITextView!
    
    override func viewDidAppear(_ animated: Bool) {
     
       }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
             loadData()
      
        
        print(postId)
       
        print(userData)
        
//        userNameLabel.text = userData.object(forKey: "displayName") as? String
//                                  tweetTextView.text = postData.object(forKey: "text") as? String
//
//
//                                  // プロフィール画像の読み込み
//                        let file = NCMBFile.file(withName: userData.objectId, data: nil) as! NCMBFile
//                                  file.getDataInBackground { (data, error) in
//                                      if error != nil {
//                                          print(error!.localizedDescription)
//                                      } else {
//                                          if data != nil {
//                                              let image = UIImage(data: data!)
//                                              self.userImageView.image = image
//                                          }
//                                      }
//
//
//
//
//                            }
    
    }
    
    
    func loadData() {
           let query = NCMBQuery(className: "Post")
        query?.includeKey("user")
        query?.whereKey("objectId", equalTo: postId)
        print(postId)
           query?.findObjectsInBackground({ (result, error) in
               if error != nil {
                print(error)
                   SVProgressHUD.showError(withStatus: error!.localizedDescription)
               } else {
                print(result)
                self.postData = result?[0] as! NCMBObject
                print(self.postData.object(forKey: "user"))
                let user = self.postData.object(forKey: "user") as! NCMBUser
                self.userData = user
                print(self.userData)
                
                
          }
           })
       }
    
    

    

}
