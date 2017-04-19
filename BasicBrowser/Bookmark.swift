//
//  Bookmark.swift
//  BasicBrowser
//
//  Created by Wayne Hartman on 4/19/17.
//  Copyright © 2017 wh. All rights reserved.
//

import UIKit

struct Bookmark {
    static private let BookmarkUserDefaultKey = "BookmarkUserDefaultKey"
    static private let BookmarkIdKey = "id"
    static private let BookmarkTitleKey = "title"
    static private let BookmarkURLKey = "url"

    let id: String
    let title: String
    let url: URL

    static func save(bookmark: Bookmark) {
        var bookmarks = self.fetch()

        if let index = bookmarks.index(where: { (existing: Bookmark) -> Bool in
            return existing.id == bookmark.id
        }) {
            bookmarks.remove(at: index)
            bookmarks.insert(bookmark, at: index)
        } else {
            bookmarks.append(bookmark)
        }

        self.save(bookmarks: bookmarks)
    }

    static func save(bookmarks: [Bookmark]) {
        var rawBookmarks = [[String : Any]]()

        for bookmark in bookmarks {
            let rawBookmark = [BookmarkIdKey : bookmark.id, BookmarkTitleKey : bookmark.title, BookmarkURLKey : bookmark.url.absoluteString]
            rawBookmarks.append(rawBookmark)
        }

        UserDefaults.standard.setValue(rawBookmarks, forKey: BookmarkUserDefaultKey)
    }

    static func fetch() -> [Bookmark] {
        var bookmarks = [Bookmark]()

        if let rawBookmarks = UserDefaults.standard.object(forKey: BookmarkUserDefaultKey) as? Array<Dictionary<String, Any>> {
            for dict in rawBookmarks  {

                guard let id = dict[BookmarkIdKey] as? String, let title = dict[BookmarkTitleKey] as? String, let uri = dict[BookmarkURLKey] as? String, let url = URL(string: uri) else {
                    continue
                }

                let bookmark = Bookmark(id: id, title: title, url: url)
                bookmarks.append(bookmark)
            }
        }

        return bookmarks
    }
}


