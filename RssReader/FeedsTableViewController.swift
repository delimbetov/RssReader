//
//  FeedsTableViewController.swift
//  RssReader
//
//  Created by Кирилл Делимбетов on 19.02.17.
//  Copyright © 2017 Кирилл Делимбетов. All rights reserved.
//

import FeedKit
import UIKit

class FeedsTableViewController: UITableViewController {
    
    var addUrl: ((URL)->Void)!
    var deleteFeed: ((RSSFeed)->Void)!
    var feeds = [RSSFeed]() {
        didSet {
            tableView?.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onAdd))
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeds.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.cellFeedsReuseIdentifier, for: indexPath)
        let feed = feeds[indexPath.row]
        
        cell.textLabel?.text = feed.title
        cell.detailTextLabel?.text = feed.link
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteFeed(feeds[indexPath.row])
        }
    }
    
    //MARK: private
    private struct Constant {
        static let cellFeedsReuseIdentifier = "Feeds cell"
    }
    
    @objc private func onAdd() {
        print("addition requested")
        let alert = UIAlertController(title: "Add RSS feed", message: "Type rss feed link you would like to subscribe to", preferredStyle: .alert)
        
        textFieldUrl = nil
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        addAlertAction.isEnabled = false
        alert.addAction(addAlertAction)
        alert.addTextField { (textField) in
            textField.placeholder = "https://www.example.com/rss"
            textField.addTarget(self, action: #selector(self.onTextFieldTextChange(textField:)), for: .editingChanged)
        }
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func onTextFieldTextChange(textField: UITextField) {
        if let text = textField.text, let url = URL(string: text), UIApplication.shared.canOpenURL(url) {
            textFieldUrl = url
            addAlertAction.isEnabled = true
        } else {
            addAlertAction.isEnabled = false
        }
    }
    
    private lazy var addAlertAction: UIAlertAction = {
        return UIAlertAction(title: "Add", style: .default) { (action) in
            DispatchQueue.main.async {
                if self.textFieldUrl == nil {
                    print("integrity error - textFieldUrl shall not be nil here")
                    return
                }
                
                self.addUrl(self.textFieldUrl!)
            }
        }
    }()
    
    private var textFieldUrl: URL?
}
