//
//  MoviesViewController.swift
//  Tomatillo
//
//  Created by Raul Agrait on 4/15/15.
//  Copyright (c) 2015 rateva. All rights reserved.
//

import UIKit

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITabBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var tabBar: UITabBar!
    var movies: [NSDictionary]?
    var refreshControl: UIRefreshControl!
    var loadBoxOffice: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // I tried for way too long to try to do this in IB
        view.bringSubviewToFront(self.errorView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tabBar.delegate = self
        tabBar.selectedItem = tabBar.items![0] as? UITabBarItem
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        load()
    }
    
    func load() {
        tableView.hidden = true
        SVProgressHUD.show()
        
        loadMovies({
            self.tableView.hidden = false
            SVProgressHUD.dismiss()
        })
    }
    
    func reload() {
        loadMovies({
            self.refreshControl.endRefreshing()
        })
    }
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem!) {
        loadBoxOffice = (item.tag == 0)
        load()
    }
    
    func loadMovies(callback: () -> Void) {
        var type = loadBoxOffice ? "movies/box_office" : "dvds/top_rentals"
        let url = NSURL(string: "http://api.rottentomatoes.com/api/public/v1.0/lists/\(type).json?apikey=dagqdghwaq3e3mxyrp7kmmj5&limit=20&country=US")!

        var timeoutInterval = 60.0 // 0.1
        let request = NSURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: timeoutInterval)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if (error != nil) {
                self.errorView.hidden = false
            } else {
                let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? NSDictionary
                self.errorView.hidden = true
                if let json = json {
                    self.movies = json["movies"] as? [NSDictionary]
                    self.tableView.reloadData()
                }
            }
            callback()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        }
        return 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        cell.titleLabel.text = movie["title"] as? String
        cell.synopsisLabel.text = movie["synopsis"] as? String
        
        let url = NSURL(string: movie.valueForKeyPath("posters.thumbnail") as! String)!
        cell.posterImageView.setImageWithURL(url)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func onRefresh() {
        reload()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)!
        
        let movie = movies![indexPath.row]
        let movieDetailsViewController = segue.destinationViewController as! MovieDetailsViewController
        movieDetailsViewController.movie = movie
    }
}
