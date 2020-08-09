//
//  AppDelegate.swift
//  Twitter
//
//  Created by 樋口裕貴 on 2020/07/11.
//  Copyright © 2020 Yuki Higuchi. All rights reserved.
//

import UIKit
import NCMB

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    
    
    var window: UIWindow!
      
      


      //アプリが起動した時に反映される場所
      func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
          NCMB.setApplicationKey("00c4b286bb802bd2ee438ba6741c44f7067f31289e7ce03a124f7e4954e6ddb6", clientKey: "54e3c2f1e39c784c98f4cb487b8db62b0c7f16ac20556303a81400b766b1cbed")
          
          //ログイン状態の管理
          let ud = UserDefaults.standard
          //ログインしてたか判別
          let isLogin = ud.bool(forKey: "isLogin")
          print(isLogin)
          
          if isLogin == true {
              //ログイン中だったら
            //iPhoneのサイズに合わせてウィンドウを作る
              self.window = UIWindow(frame: UIScreen.main.bounds)
            //ストーリーボードを取得
              let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            //最初に表示させるボードの選択
              let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootTabBarController")
              self.window?.rootViewController = rootViewController
              //背景を白に
              self.window?.backgroundColor = UIColor.white
              //その画面を出す
              self.window?.makeKeyAndVisible()
              
              
          }else {
              //違ったら
              self.window = UIWindow(frame: UIScreen.main.bounds)
              let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
              let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
              self.window?.rootViewController = rootViewController
              //背景を白に
              self.window?.backgroundColor = UIColor.white
              //その画面を出す
              self.window?.makeKeyAndVisible()
             
          }
          
          
          // Override point for customization after application launch.
          return true
      }

    // MARK: UISceneSession Lifecycle

   

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

