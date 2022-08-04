//
//  ProfileTableViewController.swift
//  ChatApp
//
//  Created by Sophia Zhu on 9/15/21.
//

import UIKit

class ProfileTableViewController: UITableViewController {

    // MARK: -IBOutlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    // MARK: - Vars
    var user: User?
    
    // MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never //to set user table view with no large title room
        tableView.tableFooterView = UIView()
        setupUI()
    }
    //MARK: - Tableview Delegates
    //remove headerviews
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "tableviewBackgroundColor")
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    //click start chat button
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1{
            print("Start chatting")
            //Go to chatroom
            let chatId = startChat(user1: User.currentUser!, user2: user!) // return chatroom id with 2 userids
            print("Start chatting chatroom id is ", chatId)
            
            //initialize chatroom
            let privateChatView = ChatViewController(chatId: chatId, recipientId: user!.id, recipientName: user!.username)
            privateChatView.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(privateChatView, animated: true)
        }
    }
    
    // MARK: - setupUI
    private func setupUI() {
        if user != nil {
            self.title = user!.username
            usernameLabel.text = user!.username
            statusLabel.text = user!.status
            
            if user!.avatarLink != "" {
                FileStorage.downloadImage(imageUrl: user!.avatarLink) { (avatarImage) in
                    self.avatarImageView.image = avatarImage?.circleMasked
                }
            }
        }
    }

    

}
