//
//  RssFeedManager.swift
//  RssReader
//
//  Created by Кирилл Делимбетов on 19.02.17.
//  Copyright © 2017 Кирилл Делимбетов. All rights reserved.
//

import FeedKit
import Foundation

struct Notification {
    static let rssFeedsItemsUpdates = "Rss feeds items updated"
}

class RssFeedManager {
    
    internal private(set) var feeds = [RSSFeed]()
    internal private(set) var items = [RSSFeedItem]()
    
    //shall be called on main thread
    func add(rssUrl: URL) {
        let url = rssUrl.absoluteString
        
        if absoluteUrlOfRssFeedToTurnedOnStatus.contains(url) == false {
            print("new rss url: " + url)
            absoluteUrlOfRssFeedToTurnedOnStatus.append(url)
        } else {
            print("url=\(url) already presented")
        }
    }
    
    func update() {
        var rssUrls = [URL]()
        
        if updating {
            print("already updating")
            return
        }
        
        print("update begins")
        updating = true
        
        for string in absoluteUrlOfRssFeedToTurnedOnStatus {
            if let url = URL(string: string) {
                rssUrls.append(url)
            }
        }
        
        DispatchQueue.global(qos: .default).async {
            var rssFeeds = [RSSFeed]()
            var rssItems = [RSSFeedItem]()
            
            for url in rssUrls {
                FeedParser(URL: url)?.parse({ (result) in
                    guard let feed = result.rssFeed, result.isSuccess else {
                        print(result.error)
                        return
                    }
                    
                    rssFeeds.append(feed)
                    
                    if let feedItems = feed.items {
                        rssItems.append(contentsOf: feedItems)
                    }
                })
            }
            
            //sort items by publication date, so newest articles are at the top
            rssItems.sort(by: { (left, right) -> Bool in
                return (left.pubDate ?? Date(timeIntervalSince1970: 0)) > (right.pubDate ?? Date(timeIntervalSince1970: 0))
            })
            
            DispatchQueue.main.async { [weak weakSelf = self] in
                weakSelf?.feeds = rssFeeds
                weakSelf?.items = rssItems
                print("update ends")
                weakSelf?.updating = false
            }
        }
    }
    
    //MARK: initializers
    init() {
        if let savedPropertyList = userDefaults.array(forKey: Constant.propertyListKey) as? PropertyList {
            absoluteUrlOfRssFeedToTurnedOnStatus = savedPropertyList
        }
    }
    
    //MARK: private
    private struct Constant {
        static let propertyListKey = "Url to turned on status array"
    }
    private typealias PropertyList = [String]
    
    //MARK: private data
    private var absoluteUrlOfRssFeedToTurnedOnStatus = PropertyList() {
        didSet {
            userDefaults.set(absoluteUrlOfRssFeedToTurnedOnStatus as Any, forKey: Constant.propertyListKey)
            userDefaults.synchronize()
            update()
        }
    }
    private var updating = false {
        didSet {
            if oldValue == true && updating == false {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notification.rssFeedsItemsUpdates), object: nil)
            }
        }
    }
    private let userDefaults = UserDefaults.standard
}

//to use in dictionary
extension RSSFeed: Hashable {
    public var hashValue: Int {
        return (title?.hashValue ?? 0) ^ (link?.hashValue ?? 0)
    }
    
    public static func ==(lhs: RSSFeed, rhs: RSSFeed) -> Bool {
        return lhs.title == rhs.title && lhs.link == rhs.link
    }
}
