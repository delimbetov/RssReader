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
        rssFeedManager.add(rssUrl: URL(string: "https://www.lenta.ru/rss")!)
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
        var detailString = ""
        let content = NSMutableAttributedString(string: (item.title ?? "No title") + "\n", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: Constant.cellTitleFontSize)])
        
        if let source = rssFeedManager.itemToSourceRssTitle[item] {
            detailString = "source: " + source
        } else {
            print("error - source shall be always available")
            detailString = "Unknown source"
        }
        
        if selectedIndexPath == indexPath, let itemDescription = item.description {
            detailString += itemDescription
        }
        
        content.append(NSAttributedString(string: detailString, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: Constant.cellDetailFontSize)]))
        cell.textLabel?.attributedText = content
        return cell
    }
    
    //MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        tableView.reloadRows(at: [selectedIndexPath!], with: .bottom)
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    //MARK: private
    private struct Constant {
        static let rssNewsCellReuseIdentifier = "Rss news"
        static let cellTitleFontSize = CGFloat(16.0)
        static let cellDetailFontSize = CGFloat(14.0)
    }
    
    @objc private func onUpdate() {
        print("Notification caught")
        tableView.reloadData()
    }
    
    //MARK: private data
    private let rssFeedManager = RssFeedManager()
    private var selectedIndexPath: IndexPath? = nil
}
