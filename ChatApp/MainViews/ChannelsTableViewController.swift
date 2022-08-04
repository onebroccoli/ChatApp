//
//  ChannelsTableViewController.swift
//  ChatApp
//
//  Created by Sophia Zhu on 9/28/21.
//

import UIKit

class ChannelsTableViewController: UITableViewController {

    //MARK: - IBOutlets
    
    @IBOutlet weak var channelSegmentOutlet: UISegmentedControl!
    
    
    //MARK: -vars
    var allChannels: [Channel] = []
    var subscribedChannels: [Channel] = []

    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .always
        self.title = "Channel"
        
        self.refreshControl = UIRefreshControl()
        self.tableView.refreshControl = self.refreshControl
        tableView.tableFooterView = UIView()
        
        downloadAllChannels()
        downloadSubsribedChannels()

    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
//        return 1
        return channelSegmentOutlet.selectedSegmentIndex == 0 ? subscribedChannels.count : allChannels.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChannelTableViewCell
//        print("-----indexPath is :" , indexPath.row)
        let channel = channelSegmentOutlet.selectedSegmentIndex == 0 ? subscribedChannels[indexPath.row] : allChannels[indexPath.row]
        cell.configure(channel: channel)
        
        
        return cell
    }

    
    
    
    //MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if channelSegmentOutlet.selectedSegmentIndex == 1 {
            //show channel view
            showChannelView(channel: allChannels[indexPath.row])
        } else {
            //show chat view
            showChat(channel: subscribedChannels[indexPath.row])
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if channelSegmentOutlet.selectedSegmentIndex == 1{
            return false
        } else {
            return subscribedChannels[indexPath.row].adminId != User.currentId

        }
        
//        let tempChannel = channelSegmentOutlet.selectedSegmentIndex == 1 ? allChannels[indexPath.row] : subscribedChannels[indexPath.row]
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            var channelToUnfollow = subscribedChannels[indexPath.row]
            subscribedChannels.remove(at: indexPath.row)
//            var channelToUnfollow: Channel!
//            if channelSegmentOutlet.selectedSegmentIndex == 1 {
//                allChannels.remove(at: indexPath.row)
//            } else {
//                channelToUnfollow = subscribedChannels[indexPath.row]
////                subscribedChannels.remove(at: indexPath.row)
//            }
            if let index = channelToUnfollow.memberIds.firstIndex(of: User.currentId) {
                channelToUnfollow.memberIds.remove(at: index)

            }
            FirebaseChannelListener.shared.saveChannel(channelToUnfollow)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    //MARK: -IBActions
    
    @IBAction func channelSegmentValueChanged(_ sender: Any) {
        tableView.reloadData()
    }
    
    //MARK: - Download channels
    private func downloadAllChannels() {
        FirebaseChannelListener.shared.downloadAllChannels { (allChannels) in
            self.allChannels = allChannels
            if self.channelSegmentOutlet.selectedSegmentIndex == 1 {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    private func downloadSubsribedChannels() {
        FirebaseChannelListener.shared.downloadSubsribedChannels { (subscribedChannels) in
            self.subscribedChannels = subscribedChannels
            if self.channelSegmentOutlet.selectedSegmentIndex == 0 {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    //MARK: - UIScrollViewDelegate
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.refreshControl!.isRefreshing {
            self.downloadAllChannels() //downloadsubsribedChannels is happening automatically
            self.refreshControl!.endRefreshing()
        }
    }
    
    
    //MARK: -Navigation
    
    private func showChannelView(channel: Channel) {
        let channelVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "channelView") as! ChannelDetailTableViewController
        
        channelVC.channel = channel
        channelVC.delegate = self
        self.navigationController?.pushViewController(channelVC, animated: true)
    }
    
    private func showChat(channel: Channel) {
//        print("chat of channel ", channel.name)
        let channelChatVC = ChannelChatViewController(channel: channel)
        channelChatVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(channelChatVC, animated: true)
        
    }
    
}


extension ChannelsTableViewController : ChannelDetailTableViewControllerDelegate {
    func didClickFollow() {
        print("delegate update")
        self.downloadAllChannels()
    }
    
    
}
