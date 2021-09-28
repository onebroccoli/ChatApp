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
        tableView.tableFooterView = UIView()
        
        

    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
//        return channelSegmentOutlet.selectedSegmentIndex == 0 ? subscribedChannels.count : allChannels.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChannelTableViewCell
//        let channel = channelSegmentOutlet.selectedSegmentIndex == 0 ? subscribedChannels[indexPath.row] : allChannels[indexPath.row]
//        cell.configure(channel: channel)
        return cell
    }

    //MARK: -IBActions
    
    @IBAction func channelSegmentValueChanged(_ sender: Any) {
    }
    
}
