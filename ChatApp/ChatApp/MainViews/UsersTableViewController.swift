//
//  UsersTableViewController.swift
//  ChatApp
//
//  Created by Sophia Zhu on 9/14/21.
//

import UIKit

class UsersTableViewController: UITableViewController {

    // MARK: - Vars
    var allUsers: [User] = []
    var filteredUsers: [User] = [] //used for searching user
    
    let searchController = UISearchController(searchResultsController: nil)
    
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl = UIRefreshControl()
        self.tableView.refreshControl = self.refreshControl
        tableView.tableFooterView = UIView() //get rid of the bottom empty lines
//        createDummyUsers() //只跑一遍
        
        setupSearchController()
        downloadUsers()
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //make sure when we come back from user profile page, we will get big title view
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    // MARK: - Table view data source



    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        return searchController.isActive ? filteredUsers.count : allUsers.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UserTableViewCell
        let user = searchController.isActive ? filteredUsers[indexPath.row] : allUsers[indexPath.row] //always have access to user object
        cell.configureC(user: user)
        return cell
    }
    // MARK: - TableViewDelegates
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "tableViewBackgroundColor")
        return headerView
    }

    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //TODO: show profile view
    }
    
    //MARK: - downloadUsers
    private func downloadUsers() {
        FirebaseUserListener.shared.downloadAllUsersFromFirebase { (allFirebaseUsers) in
            self.allUsers = allFirebaseUsers
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - setupSearchController
    private func setupSearchController() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search user"
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
    }
    
    private func filteredContentForSearchText(searchText: String){
//        print("searching for", searchText)
        filteredUsers = allUsers.filter({(user) -> Bool in
            return user.username.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    //MARK: - UIScrollViewDelegate
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //scrolldown and the refreshing start showing spin icon, need to end it.
        if self.refreshControl!.isRefreshing {
            self.downloadUsers()
            self.refreshControl?.endRefreshing()
        }
    }
}


extension UsersTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filteredContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
