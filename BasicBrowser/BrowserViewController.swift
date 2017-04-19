//
//  BrowserViewController.swift
//  BasicBrowser
//
//  Created by Wayne Hartman on 4/18/17.
//  Copyright © 2017 wh. All rights reserved.
//

import UIKit

class BrowserViewController: UIViewController {
    @IBOutlet var textField: UITextField!
    @IBOutlet var webView: UIWebView!
    @IBOutlet var backButton: UIBarButtonItem!
    @IBOutlet var forwardButton: UIBarButtonItem!
    @IBOutlet var refreshButton: UIBarButtonItem!
    @IBOutlet var stopButton: UIBarButtonItem!
    @IBOutlet var addButton: UIBarButtonItem!
    @IBOutlet var bookmarksButton: UIBarButtonItem!
    @IBOutlet var goButton: UIBarButtonItem!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateUI()
        self.textField.rightView = self.activityIndicator
        self.textField.rightViewMode = .always
    }

    fileprivate func updateUI() {
        self.backButton.isEnabled = self.webView.canGoBack
        self.forwardButton.isEnabled = self.webView.canGoForward
        self.refreshButton.isEnabled = self.webView.request != nil
        self.stopButton.isEnabled = self.webView.isLoading
    }

    fileprivate func loadRequest() {
        if self.textField.isFirstResponder {
            self.textField.resignFirstResponder()
        }

        if var uri = self.textField.text {
            if !uri.hasPrefix("http") {
                uri = "http://\(uri)"
            }

            let url = URL(string: uri)

            if let url = url {
                let request = URLRequest(url: url)
                self.webView.loadRequest(request)
            }
        }
    }
}

// All the IBActions
extension BrowserViewController {
    @IBAction func didSelectGoButton(_ sender: Any) {
        self.loadRequest()
    }

    @IBAction func didSelectBackButton(_ sender: Any) {
        self.webView.goBack()
    }

    @IBAction func didSelectForwardButton(_ sender: Any) {
        self.webView.goForward()
    }

    @IBAction func didSelectRefreshButton(_ sender: Any) {
        self.webView.reload()
    }

    @IBAction func didSelectStopButton(_ sender: Any) {
        self.webView.stopLoading()
    }

    @IBAction func didSelectAddBookmark(_ sender: Any) {
        guard let title = self.webView.stringByEvaluatingJavaScript(from: "document.title"), let uri = self.webView.request?.url?.absoluteString, let url = URL(string: uri) else {
            return;
        }

        let alert = UIAlertController(title: "Add Bookmark", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in

            if let title = alert.textFields?[0].text, let uri = alert.textFields?[1].text, let url = URL(string: uri) {
                let newBookmark = Bookmark(id: UUID().uuidString, title: title, url: url)

                Bookmark.save(bookmark: newBookmark)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction) in
            // DO NOTHING
        }))
        alert.addTextField { (textfield: UITextField) in
            textfield.placeholder = "Title"
            textfield.text = title
        }
        alert.addTextField { (textfield: UITextField) in
            textfield.placeholder = "URL"
            textfield.text = url.absoluteString
        }

        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func didSelectViewBookmarks(_ sender: Any) {
        if let bookmarksVC = self.storyboard?.instantiateViewController(withIdentifier: "BookmarksViewController") as? BookmarksViewController {

            weak var weakSelf = self

            bookmarksVC.finishHandler = {
                if let zelf = weakSelf {
                    zelf.dismiss(animated: true, completion: nil)
                }
            }
            bookmarksVC.selectionHandler = {(bookmark: Bookmark) in
                if let zelf = weakSelf {
                    zelf.dismiss(animated: true, completion: nil)
                    zelf.textField.text = bookmark.url.absoluteString
                    zelf.webView.loadRequest(URLRequest(url: bookmark.url))
                }
            }

            let navController = UINavigationController(rootViewController: bookmarksVC)

            self.present(navController, animated: true, completion: nil)
        }
    }
}

extension BrowserViewController : UIWebViewDelegate {

    func webViewDidStartLoad(_ webView: UIWebView) {
        self.activityIndicator.isHidden = false
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.activityIndicator.isHidden = true
        self.updateUI()

        if let currentAddress = webView.request?.url?.absoluteString {
            self.textField.text = currentAddress
        }
    }

    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        self.activityIndicator.isHidden = true

        self.present(alert, animated: true, completion: nil)
    }
}

extension BrowserViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.loadRequest()

        return true
    }
}












