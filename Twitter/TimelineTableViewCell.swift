//
//  TimelineTableViewCell.swift
//  Twitter
//
//  Created by 樋口裕貴 on 2020/07/15.
//  Copyright © 2020 Yuki Higuchi. All rights reserved.
//

import UIKit
import NCMB
import NYXImagesKit

protocol TimelineTableViewCellDelegate {
    func didTapLikeButton(tableViewCell: UITableViewCell, button: UIButton)
    func didTapMenuButton(tableViewCell: UITableViewCell, button: UIButton)
    func didTapCommentsButton(tableViewCell: UITableViewCell, button: UIButton)
}

class TimelineTableViewCell: UITableViewCell {
    
    var delegate: TimelineTableViewCellDelegate?
    

    @IBOutlet var userNameLabel : UILabel!
    
    @IBOutlet var userImageView :UIImageView!
    
    @IBOutlet var photoImageView : UIImageView!
    
    @IBOutlet var likeButton : UIButton!
    
    @IBOutlet var likeCountLabel : UILabel!
    
    @IBOutlet var tweetTextView : UITextView!
    
    @IBOutlet var timestampLabel : UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //画像を丸くする
            userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
            userImageView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func like(button: UIButton) {
        self.delegate?.didTapLikeButton(tableViewCell: self, button: button)
    }

    @IBAction func openMenu(button: UIButton) {
        self.delegate?.didTapMenuButton(tableViewCell: self, button: button)
    }

    @IBAction func showComments(button: UIButton) {
        self.delegate?.didTapCommentsButton(tableViewCell: self, button: button)
    }
    
    
}
