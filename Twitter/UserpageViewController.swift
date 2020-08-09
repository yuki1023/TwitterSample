//
//  UserpageViewController.swift
//  Twitter
//
//  Created by 樋口裕貴 on 2020/07/14.
//  Copyright © 2020 Yuki Higuchi. All rights reserved.
//

import UIKit
import NCMB
import NYXImagesKit
import Kingfisher
import SVProgressHUD

class UserpageViewController: UIViewController ,UITableViewDataSource,UITableViewDelegate {
   
    
    var posts = [Post]()
    
    
     @IBOutlet var userImageView : UIImageView!
    @IBOutlet var userDisplayNameLabel : UILabel!
       @IBOutlet var userintroductionTextView : UITextView!
    
    @IBOutlet var followerCountLabel: UILabel!
       
       @IBOutlet var followingCountLabel: UILabel!
       

    
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
        
        setRefreshControl()
              
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //ユーザー名と紹介文の読み込み
//        let user = NCMBUser.current()

        loadFollowingInfo()
//        1週間以上ログインしなかった人へのクラッシュの対処
        if let user = NCMBUser.current(){
            userDisplayNameLabel.text = user.object(forKey: "displayName") as? String
                          userintroductionTextView.text = user.object(forKey: "introduction") as? String
                          print(userintroductionTextView)
                   
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
        query?.whereKey("user", equalTo: NCMBUser.current())
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
        func loadFollowingInfo() {
            // フォロー中
            let followingQuery = NCMBQuery(className: "Follow")
            followingQuery?.includeKey("user")
            followingQuery?.whereKey("user", equalTo: NCMBUser.current())
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
            followerQuery?.whereKey("following", equalTo: NCMBUser.current())
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
        
    
  
}
