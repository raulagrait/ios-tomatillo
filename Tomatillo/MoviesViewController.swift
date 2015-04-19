//
//  MoviesViewController.swift
//  Tomatillo
//
//  Created by Raul Agrait on 4/15/15.
//  Copyright (c) 2015 rateva. All rights reserved.
//

import UIKit

class MoviesViewController: UIViewController, UITableViewDelegate, UITabBarDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var tabBar: UITabBar!
    
    var tableViewDataSource: MoviesTableViewDataSource?
    
    var movies: [NSDictionary]? {
        didSet {
            tableViewDataSource?.movies = movies
        }
    }

    var filteredMovies: [NSDictionary]? {
        didSet {
            tableViewDataSource?.filteredMovies = filteredMovies
        }
    }
    
    var refreshControl: UIRefreshControl!
    var loadBoxOffice: Bool = true

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barStyle = UIBarStyle.Black
        setNeedsStatusBarAppearanceUpdate()
        
        navigationController?.navigationBar.titleTextAttributes = [ NSForegroundColorAttributeName : UIColor.whiteColor() ]
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        // I tried for way too long to try to do this in IB
        view.bringSubviewToFront(self.errorView)
        
        tableViewDataSource = MoviesTableViewDataSource()
        tableView.delegate = self
        tableView.dataSource = tableViewDataSource
        
        tabBar.delegate = self
        tabBar.selectedItem = tabBar.items![0] as? UITabBarItem
        UITabBar.appearance().tintColor = UIColor.redColor()
        
        searchBar.delegate = self        
        view.bringSubviewToFront(searchBar)
        
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
        
        searchBar.text = ""
        tableViewDataSource?.searchText = ""
        
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
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func onRefresh() {
        reload()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        tableViewDataSource?.searchText = searchText
        tableViewDataSource?.filterMovies({
            self.tableView.reloadData()
        })
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)!
        let movie = tableViewDataSource?.getMovie(indexPath.row)
        
        let movieDetailsViewController = segue.destinationViewController as! MovieDetailsViewController
        movieDetailsViewController.movie = movie
    }
}
