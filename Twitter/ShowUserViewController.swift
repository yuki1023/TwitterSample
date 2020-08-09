//
//  ShowUserViewController.swift
//  Twitter
//
//  Created by 樋口裕貴 on 2020/07/22.
//  Copyright © 2020 Yuki Higuchi. All rights reserved.
//

import UIKit
import NCMB
import NYXImagesKit
import Kingfisher
import SVProgressHUD

class ShowUserViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate {
   
    
    var selectedUser: NCMBUser!
    
    var posts = [Post]()
    
    var followingInfo: NCMBObject?
    
     @IBOutlet var userImageView : UIImageView!
    @IBOutlet var userDisplayNameLabel : UILabel!
       @IBOutlet var userintroductionTextView : UITextView!

    
    @IBOutlet var followerCountLabel: UILabel!
    
    @IBOutlet var followingCountLabel: UILabel!
    
    @IBOutlet var followButton: UIButton!
    
    @IBOutlet var tweetTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tweetTableView.delegate = self
        tweetTableView.dataSource = self
        
        //画像を丸くする
               userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
               userImageView.layer.masksToBounds = true
        
        loadPosts()
        
//        カスタムビューの取得
              let nib = UINib(nibName: "TimelineTableViewCell", bundle: Bundle.main)
              tweetTableView.register(nib, forCellReuseIdentifier: "Cell")
            
            tweetTableView.tableFooterView = UIView()
              
             tweetTableView.rowHeight = 360
        
        // ユーザー基礎情報の読み込み
              userDisplayNameLabel.text = selectedUser.object(forKey: "displayName") as? String
              userintroductionTextView.text = selectedUser.object(forKey: "introduction") as? String
              self.navigationItem.title = selectedUser.userName
              
              // プロフィール画像の読み込み
              let file = NCMBFile.file(withName: selectedUser.objectId, data: nil) as! NCMBFile
              file.getDataInBackground { (data, error) in
                  if error != nil {
                      print(error!.localizedDescription)
                  } else {
                      if data != nil {
                          let image = UIImage(data: data!)
                          self.userImageView.image = image
                      }
                  }
        }
        setRefreshControl()
        
        // フォロー状態の読み込み
               loadFollowingStatus()
               
               // フォロー数の読み込み
               loadFollowingInfo()
              
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        //ユーザー名と紹介文の読み込み
//        let user = NCMBUser.current()

////
//
    }
    
    
    func loadFollowingStatus() {
        let query = NCMBQuery(className: "Follow")
        query?.includeKey("user")
        query?.includeKey("following")
        query?.whereKey("user", equalTo: NCMBUser.current())
        
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            } else {
                print(result)
                for following in result as! [NCMBObject] {
                    let user = following.object(forKey: "following") as! NCMBUser
                    
                    // フォロー状態だった場合、ボタンの表示を変更
                    if self.selectedUser.objectId == user.objectId {
                        // 表示変更を高速化するためにメインスレッドで処理
                        DispatchQueue.main.async {
                            self.followButton.setTitle("フォロー解除", for: .normal)
                            self.followButton.setTitleColor(UIColor.red, for: .normal)
//                            self.followButton.borderColor = UIColor.red
                        }
                        
                        // フォロー状態を管理するオブジェクトを保存
                        self.followingInfo = following
                        break
                    }
                }
            }
        })
    }

    func loadFollowingInfo() {
           // フォロー中
           let followingQuery = NCMBQuery(className: "Follow")
           followingQuery?.includeKey("user")
           followingQuery?.whereKey("user", equalTo: selectedUser)
           followingQuery?.countObjectsInBackground({ (count, error) in
               if error != nil {
                   SVProgressHUD.showError(withStatus: error!.localizedDescription)
               } else {
                   // 非同期通信後のUIの更新はメインスレッドで
                   DispatchQueue.main.async {
                       self.followingCountLabel.text = String(count)
                   }
               }
           })
           
           // フォロワー
           let followerQuery = NCMBQuery(className: "Follow")
           followerQuery?.includeKey("following")
           followerQuery?.whereKey("following", equalTo: selectedUser)
           followerQuery?.countObjectsInBackground({ (count, error) in
               if error != nil {
                   SVProgressHUD.showError(withStatus: error!.localizedDescription)
               } else {
                   DispatchQueue.main.async {
                       // 非同期通信後のUIの更新はメインスレッドで
                       self.followerCountLabel.text = String(count)
                   }
               }
           })
       }
       
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return posts.count
          }
          
          func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! TimelineTableViewCell
           
           //内容
//           cell.delegate = self
           cell.tag = indexPath.row

           let user = posts[indexPath.row].user
           cell.userNameLabel.text = user.displayName
           let userImageUrl = "https://mbaas.api.nifcloud.com/2013-09-01/applications/TdaEXHzlIBzZMnxF/publicFiles/" + user.objectId
          cell.userImageView.kf.setImage (with: URL (string: userImageUrl), placeholder: UIImage (named: "placeholder.jpg"))

           cell.tweetTextView.text = posts[indexPath.row].text
           let imageUrl = posts[indexPath.row].imageUrl
           cell.photoImageView.kf.setImage(with: URL(string: imageUrl))

           // Likeによってハートの表示を変える
           if posts[indexPath.row].isLiked == true {
               cell.likeButton.setImage(UIImage(named: "heart-fill"), for: .normal)
           } else {
               cell.likeButton.setImage(UIImage(named: "heart-outline"), for: .normal)
           }

           // Likeの数
           cell.likeCountLabel.text = "\(posts[indexPath.row].likeCount)件"

           // タイムスタンプ(投稿日時) (※フォーマットのためにSwiftDateライブラリをimport)
           cell.timestampLabel.text = posts[indexPath.row].createDate.toString()
           
           
           
           return cell
          }
    
    
    
    
    
    
    func loadPosts() {
        let query = NCMBQuery(className: "Post")
        query?.includeKey("user")
        query?.whereKey("user", equalTo: selectedUser)
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            } else {
                self.posts = [Post]()
                
                for postObject in result as! [NCMBObject] {
                    // ユーザー情報をUserクラスにセット
                    let user = postObject.object(forKey: "user") as! NCMBUser
                    let userModel = User(objectId: user.objectId, userName: user.userName)
                    userModel.displayName = user.object(forKey: "displayName") as? String
                    
                if postObject.object(forKey: "imageUrl") != nil{
                    
                    // 投稿の情報を取得
                    let imageUrl = postObject.object(forKey: "imageUrl") as! String
                    let text = postObject.object(forKey: "text") as! String
                    
                    // 2つのデータ(投稿情報と誰が投稿したか?)を合わせてPostクラスにセット
                    let post = Post(objectId: postObject.objectId, user: userModel, imageUrl: imageUrl, text: text, createDate: postObject.createDate)
                    
                    // likeの状況(自分が過去にLikeしているか？)によってデータを挿入
                    let likeUser = postObject.object(forKey: "likeUser") as? [String]
                    if likeUser?.contains(NCMBUser.current().objectId) == true {
                        post.isLiked = true
                    } else {
                        post.isLiked = false
                    }
                    // 配列に加える
                    self.posts.append(post)
                }else{
                    
                    // 投稿の情報を取得
//                                    let imageUrl = postObject.object(forKey: "imageUrl") as! String
                                    let text = postObject.object(forKey: "text") as! String
                                    
                                    // 2つのデータ(投稿情報と誰が投稿したか?)を合わせてPostクラスにセット
                                    let post = Post(objectId: postObject.objectId, user: userModel, imageUrl: "", text: text, createDate: postObject.createDate)
                                    
                                    // likeの状況(自分が過去にLikeしているか？)によってデータを挿入
                                    let likeUser = postObject.object(forKey: "likeUser") as? [String]
                                    if likeUser?.contains(NCMBUser.current().objectId) == true {
                                        post.isLiked = true
                                    } else {
                                        post.isLiked = false
                                    }
                                    // 配列に加える
                                    self.posts.append(post)
                    
                    
                    
                    }
                self.tweetTableView.reloadData()
                
                }
                // post数を表示
//                self.postCountLabel.text = String(self.posts.count)
            }
        })
    }
    
      func setRefreshControl() {
               let refreshControl = UIRefreshControl()
               refreshControl.addTarget(self, action: #selector(reloadTimeline(refreshControl:)), for: .valueChanged)
               tweetTableView.addSubview(refreshControl)
           }

        @objc func reloadTimeline(refreshControl: UIRefreshControl) {
               refreshControl.beginRefreshing()
    //           self.loadFollowingUsers()
               // 更新が早すぎるので2秒遅延させる
               DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                   refreshControl.endRefreshing()
               }
           }
    
    @IBAction func follow() {
            // すでにフォロー状態だった場合、フォロー解除
            if let info = followingInfo {
                info.deleteInBackground({ (error) in
                    if error != nil {
                        SVProgressHUD.showError(withStatus: error!.localizedDescription)
                    } else {
                        DispatchQueue.main.async {
                            self.followButton.setTitle("フォローする", for: .normal)
                            self.followButton.setTitleColor(UIColor.blue, for: .normal)
//                            self.followButton.borderColor = UIColor.blue
                        }
                        
                        // フォロー状態の再読込
                        self.loadFollowingStatus()
                        
                        // フォロー数の再読込
                        self.loadFollowingInfo()
                    }
                })
            } else {
                let displayName = selectedUser.object(forKey: "displayName") as? String
                let message = displayName! + "をフォローしますか？"
                let alert = UIAlertController(title: "フォロー", message: message, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                    let object = NCMBObject(className: "Follow")
                    if let currentUser = NCMBUser.current() {
                        object?.setObject(currentUser, forKey: "user")
                        object?.setObject(self.selectedUser, forKey: "following")
                        object?.saveInBackground({ (error) in
                            if error != nil {
                                SVProgressHUD.showError(withStatus: error!.localizedDescription)
                            } else {
                                self.loadFollowingStatus()
                            }
                        })
                    } else {
                        // currentUserが空(nil)だったらログイン画面へ
                        let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
                        let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
                        UIApplication.shared.keyWindow?.rootViewController = rootViewController
                        
                        // ログイン状態の保持
                        let ud = UserDefaults.standard
                        ud.set(false, forKey: "isLogin")
                        ud.synchronize()
                    }
                }
                let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (action) in
                    alert.dismiss(animated: true, completion: nil)
                }
                alert.addAction(okAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    
}
  

