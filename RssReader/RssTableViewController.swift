//
//  RssTableViewController.swift
//  RssReader
//
//  Created by Кирилл Делимбетов on 18.02.17.
//  Copyright © 2017 Кирилл Делимбетов. All rights reserved.
//

import FeedKit
import UIKit

class RssTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
        NotificationCenter.default.addObserver(self, selector: #selector(onUpdate), name: NSNotification.Name(Notification.rssFeedsItemsUpdates), object: nil)
        rssFeedManager.update()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rssFeedManager.items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.rssNewsCellReuseIdentifier, for: indexPath)
        let item = rssFeedManager.items[indexPath.row]
        var sourceString = ""
        let content = NSMutableAttributedString(string: (item.title ?? "No title") + "\n", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: Constant.cellTitleFontSize)])
        
        if let source = rssFeedManager.itemToSourceRssTitle[item] {
            sourceString = "Source: " + source
        } else {
            print("error - source shall always be available")
            sourceString = "Unknown source"
        }
        
        if selectedIndexPath == indexPath, let itemDescription = item.description {
            content.append(NSAttributedString(string: itemDescription.replacingOccurrences(of: "\n", with: "") + "\n", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: Constant.cellDetailFontSize)]))
        }
        
        content.append(NSAttributedString(string: sourceString, attributes: [NSFontAttributeName: UIFont.italicSystemFont(ofSize: Constant.cellSourceFontSize)]))
        
        cell.textLabel?.attributedText = content
        return cell
    }
    
    //MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let item = rssFeedManager.items[indexPath.row]
        
        if let link = URL(string: item.link ?? " "), UIApplication.shared.canOpenURL(link) {
            UIApplication.shared.open(link)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var indexPathsToReload = [indexPath]
        
        if selectedIndexPath != nil {
            indexPathsToReload.append(selectedIndexPath!)
        }
        
        //deselect if clicked again
        if selectedIndexPath == indexPath {
            selectedIndexPath = nil
        } else {
            selectedIndexPath = indexPath
            indexPathsToReload.append(selectedIndexPath!)
        }
        
        tableView.reloadRows(at: indexPathsToReload, with: .automatic)
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constant.segueIdentifierFeeds, let destination = segue.destination as? FeedsTableViewController {
            feedsTableViewController = destination
            destination.feeds = rssFeedManager.feeds
            destination.addUrl = { [weak weakSelf = self](url) in
                weakSelf?.rssFeedManager.add(rssUrl: url)
            }
            destination.deleteFeed = { [weak weakSelf = self](feed) in
                weakSelf?.rssFeedManager.delete(rssFeed: feed)
            }
        }
    }
    
    //MARK: private
    private struct Constant {
        static let cellDetailFontSize = CGFloat(14.0)
        static let cellSourceFontSize = CGFloat(14.0)
        static let cellTitleFontSize = CGFloat(16.0)
        static let segueIdentifierFeeds = "Feeds"
        static let rssNewsCellReuseIdentifier = "Rss news"
    }
    
    @objc private func onUpdate() {
        print("Notification caught")
        tableView.reloadData()
        
        if feedsTableViewController != nil {
            print("Updating feeds")
            feedsTableViewController!.feeds = rssFeedManager.feeds
        }
    }
    
    //MARK: private data
    private weak var feedsTableViewController: FeedsTableViewController? = nil
    private let rssFeedManager = RssFeedManager()
    private var selectedIndexPath: IndexPath? = nil
}
