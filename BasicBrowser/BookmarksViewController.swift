//
//  BookmarksViewController.swift
//  BasicBrowser
//
//  Created by Wayne Hartman on 4/19/17.
//  Copyright © 2017 wh. All rights reserved.
//

import UIKit

typealias BookmarkSelectionHandler = (Bookmark) -> (Void)
typealias FinishHandler = (Void) -> (Void)

class BookmarksViewController: UITableViewController {

    internal var selectionHandler: BookmarkSelectionHandler?
    internal var finishHandler: FinishHandler?

    fileprivate var bookmarks = [Bookmark]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.bookmarks = Bookmark.fetch()
    }
}

extension BookmarksViewController {
    @IBAction func didSelectDoneButton(_ sender: Any) {
        if let handler = self.finishHandler {
            handler()
        }
    }
}

extension BookmarksViewController {
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bookmarks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let bookmark = self.bookmarks[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "BookmarkCell", for: indexPath)
        cell.textLabel?.text = bookmark.title

        return cell
    }
}

extension BookmarksViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let handler = self.selectionHandler {
            handler(self.bookmarks[indexPath.row])
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            var bookmarks = self.bookmarks

            bookmarks.remove(at: indexPath.row)

            Bookmark.save(bookmarks: bookmarks)
            self.bookmarks = bookmarks

            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let bookmark = self.bookmarks[indexPath.row]

        let alert = UIAlertController(title: "Edit Bookmark", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (action: UIAlertAction) in
            if let title = alert.textFields?[0].text, let uri = alert.textFields?[1].text, let url = URL(string: uri) {
                let newBookmark = Bookmark(id: bookmark.id, title: title, url: url)

                Bookmark.save(bookmark: newBookmark)
                self.bookmarks = Bookmark.fetch()
                self.tableView.reloadData()
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction) in
            // DO NOTHING
        }))
        alert.addTextField { (textfield: UITextField) in
            textfield.placeholder = "Title"
            textfield.text = bookmark.title
        }
        alert.addTextField { (textfield: UITextField) in
            textfield.placeholder = "URL"
            textfield.text = bookmark.url.absoluteString
        }

        self.present(alert, animated: true, completion: nil)
    }
}
