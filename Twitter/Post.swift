//
//  Post.swift
//  Twitter
//
//  Created by 樋口裕貴 on 2020/07/19.
//  Copyright © 2020 Yuki Higuchi. All rights reserved.
//

import UIKit

class Post {
    var objectId: String
    var user: User
    var imageUrl: String
    var text: String
    var createDate: Date
    var isLiked: Bool?
    var comments: [Comment]?
    var likeCount: Int = 0

    //初期化
    init(objectId: String, user: User, imageUrl: String, text: String, createDate: Date) {
        self.objectId = objectId
        self.user = user
        self.imageUrl = imageUrl
        self.text = text
        self.createDate = createDate
    }
}
