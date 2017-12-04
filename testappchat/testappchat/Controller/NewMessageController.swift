//
//  NewMessageController.swift
//  testappchat
//
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {
    
    let cellId = "cellId"
    var users = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.title = "New message"
        tableView.register( userCell.self, forCellReuseIdentifier:  cellId)
        fetchUser()
    }
    
    func fetchUser() {
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let user = User()
                user.UserID = snapshot.key
                user.setValuesForKeys(dictionary)
                self.users.append(user)
                DispatchQueue.main.async { self.tableView.reloadData() }
            }
        }, withCancel: nil)
    }
    
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! userCell
        let user = users[indexPath.row]
        
        if let profileImageUrl = user.profileImageUrl{
            cell.profileImageView.loadimageUsingWithCacheUrl(urlString: profileImageUrl)
        }
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    var historyChatController: HistoryChatController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true){
            let user = self.users[indexPath.row]
            self.historyChatController?.showChatController(user: user)
        }
    }

}
