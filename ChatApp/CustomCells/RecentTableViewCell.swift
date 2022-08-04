//
//  RecentTableViewCell.swift
//  ChatApp
//
//  Created by Sophia Zhu on 9/15/21.
//

import UIKit

class RecentTableViewCell: UITableViewCell {

    // MARK: -IBActions
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var unreadCounterLabel: UILabel!
    @IBOutlet weak var unreadCounterBackgroundView: UIView!
    
    //it's like viewdidload function
    override func awakeFromNib() {
        super.awakeFromNib()
        
        unreadCounterBackgroundView.layer.cornerRadius = unreadCounterBackgroundView.frame.width / 2
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(recent: RecentChat){
        usernameLabel.text = recent.receiverName
        usernameLabel.adjustsFontSizeToFitWidth = true // if chat is long, will adjust the font size to the width
        usernameLabel.minimumScaleFactor = 0.9
        
        lastMessageLabel.text = recent.lastMessage
        lastMessageLabel.adjustsFontSizeToFitWidth = true
        lastMessageLabel.numberOfLines = 2
        lastMessageLabel.minimumScaleFactor = 0.9
        
        if recent.unreadCounter != 0 {
            self.unreadCounterLabel.text = "\(recent.unreadCounter)"
            self.unreadCounterBackgroundView.isHidden = false //show the circle to show the unread msg count
        } else {
            self.unreadCounterBackgroundView.isHidden = true //hide the circle
        }
        
        
        setAvatar(avatarLink: recent.avatarLink)
        dateLabel.text = timeElapsed(recent.date ?? Date()) //globalFunction
        dateLabel.adjustsFontSizeToFitWidth = true
        
    }
    
    private func setAvatar(avatarLink: String) {
        if avatarLink != "" {
            
            FileStorage.downloadImage(imageUrl: avatarLink) { (avatarImage) in
                self.avatarImageView.image = avatarImage?.circleMasked
            }
        } else {
            self.avatarImageView.image = UIImage(named: "avatar")
        }
    }

}
