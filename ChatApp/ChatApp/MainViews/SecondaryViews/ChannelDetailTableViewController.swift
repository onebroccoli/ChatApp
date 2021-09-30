//
//  ChannelTableViewController.swift
//  ChatApp
//
//  Created by Sophia Zhu on 9/29/21.
//

import UIKit

protocol ChannelDetailTableViewControllerDelegate {
    func didClickFollow()
}



class ChannelDetailTableViewController: UITableViewController {

    
    
    //MARK: - IBActions
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var membersLabel: UILabel!
    @IBOutlet weak var aboutTextView: UITextView!
    
    //MARK: - Vars
    var channel: Channel!
    var delegate: ChannelDetailTableViewControllerDelegate?
    
    
    //MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView() //get rid of the extra cells in the page
        showChannelData()
        configureRightBarButton()
       
    }

    //MARK: - Configure
    private func showChannelData() {
        self.title = channel.name
        
        nameLabel.text = channel.name
        membersLabel.text = "\(channel.memberIds.count) Members"
        aboutTextView.text = channel.aboutChannel
        setAvatar(avatarLink: channel.avatarLink)
        
    }
   
    
    private func configureRightBarButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Follow", style: .plain, target: self, action: #selector(followChannel))
    }
    

    
    private func setAvatar(avatarLink: String) {
        if avatarLink != "" {
            FileStorage.downloadImage(imageUrl: avatarLink) { (avatarImage) in
                DispatchQueue.main.async {
                    self.avatarImageView.image = avatarImage != nil ? avatarImage?.circleMasked : UIImage(named: "avatar")
                }
            }
        } else {
            
            self.avatarImageView.image = UIImage(named: "avatar")
        }
        
    }
    

    
    //MARK: - Actions
    @objc func followChannel() {
        //when user want to follow channel
        channel.memberIds.append(User.currentId)
        //update FB
        FirebaseChannelListener.shared.saveChannel(channel)
        delegate?.didClickFollow()
        self.navigationController?.popViewController(animated: true) //关闭
        //after controller pop out the window, need to update the page
    }

}
