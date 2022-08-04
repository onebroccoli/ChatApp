//
//  SettingsTableViewController.swift
//  ChatApp
//
//  Created by Sophia Zhu on 9/8/21.
//

import UIKit
import Firebase
class SettingsTableViewController: UITableViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var usernamelabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var appVersionLabel: UILabel!
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showUserInfo()
    }

    // MARK - TableView Delegates
    //type viewForHeaderInSection
    //remove section by setting the background color same as cell background color
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "tableviewBackgroundColor")
        return headerView
    }
    //type heightForHeaderInSection
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return section == 0 ? 0.0 :10.0 //if first section set as 0, if not the first seciton, set gap as 10
    }
  
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 && indexPath.row == 0 { //if on the first row in the edit profile page
            
            performSegue(withIdentifier: "settingsToEditProfileSeg", sender: self)
        }
    }
    
    // MARK - IBActions
    @IBAction func tellAFriendButtonPressed(_ sender: Any) {
        print("tell a friend")
    }
    
    @IBAction func termsAndConditionsButtonPressed(_ sender: Any) {
        print("terms and conditions")

    }
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        FirebaseUserListener.shared.logOutCurrentUser { (error) in
            //if sign out successfully, return to login page
            if error == nil {
                let loginView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "loginView")
                DispatchQueue.main.async {
                    loginView.modalPresentationStyle = .fullScreen //user cannot go back to the application unless login again
                    self.present(loginView, animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: - UpdateUI
    private func showUserInfo(){
        if let user = User.currentUser {
            usernamelabel.text = user.username
            statusLabel.text = user.status
            appVersionLabel.text = "App version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")"
            if user.avatarLink != "" {
                //download and set avatar image
                FileStorage.downloadImage(imageUrl: user.avatarLink) { (avatarImage) in
                    self.avatarImageView.image = avatarImage?.circleMasked
                }
            }
        }
    }
    
}
