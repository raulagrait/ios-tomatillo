//
//  MoviesViewController.swift
//  Tomatillo
//
//  Created by Raul Agrait on 4/15/15.
//  Copyright (c) 2015 rateva. All rights reserved.
//

import UIKit

class MoviesViewController: UIViewController, UITabBarDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var gridView: UICollectionView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var tableViewDataSource: MoviesTableViewDataSource?
    var gridViewDataSource: MoviesCollectionViewDataSource?
    
    var tableViewDelegate: MoviesTableViewDelegate?

    var movies: [NSDictionary]? {
        didSet {
            tableViewDataSource?.movies = movies
            gridViewDataSource?.movies = movies
        }
    }

    var filteredMovies: [NSDictionary]? {
        didSet {
            tableViewDataSource?.filteredMovies = filteredMovies
            gridViewDataSource?.filteredMovies = filteredMovies
        }
    }
    
    var refreshControl: UIRefreshControl!
    var loadBoxOffice: Bool = true
    
    // MARK: UIViewController

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
        tableView.dataSource = tableViewDataSource
        
        tableViewDelegate = MoviesTableViewDelegate()
        tableView.delegate = tableViewDelegate

        gridView.hidden = true
        gridViewDataSource = MoviesCollectionViewDataSource()
        gridView.dataSource = gridViewDataSource

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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Data loading
    
    func load() {
        tableView.hidden = true
        gridView.hidden = true
        
        SVProgressHUD.show()
        
        loadMovies({
            self.updateVisibility()
            SVProgressHUD.dismiss()
        })
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
                println(data)
                if let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? NSDictionary {
                    self.errorView.hidden = true
                    self.movies = json["movies"] as? [NSDictionary]
                    self.reloadData()
                } else {
                    self.errorView.hidden = false
                }
            }
            callback()
        }
    }
    
    func reloadData() {
        tableView.reloadData()
        gridView.reloadData()
    }
    
    // MARK: UITabBar
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem!) {
        searchBar.text = ""
        setSearchText("")
        
        loadBoxOffice = (item.tag == 0)
        load()
    }

    // MARK: Refresh control
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        setSearchText(searchText)
        
        tableViewDataSource?.filterMovies({
            self.tableView.reloadData()
        })
        
        gridViewDataSource?.filterMovies({
            self.gridView.reloadData()
        })
    }
    
    func setSearchText(searchText: String) {
        tableViewDataSource?.searchText = searchText
        gridViewDataSource?.searchText = searchText
    }
    
    func onRefresh() {
        reload()
    }
    
    func reload() {
        loadMovies({
            self.refreshControl.endRefreshing()
        })
    }

    // MARK: - Segmented Control
    
    @IBAction func onSegmentedControlValueChanged(sender: AnyObject) {
        updateVisibility()
    }
    
    func updateVisibility() {
        var index = segmentedControl.selectedSegmentIndex
        var listVisible = (index == 0)
        
        tableView.hidden = !listVisible
        gridView.hidden = listVisible
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        var indexPath: NSIndexPath?
        if let tableCell = sender as? UITableViewCell {
            indexPath = tableView.indexPathForCell(tableCell)
        } else if let gridCell = sender as? UICollectionViewCell {
            indexPath = gridView.indexPathForCell(gridCell)
        }
        
        if let indexPath = indexPath {
            let movie = tableViewDataSource?.getMovie(indexPath.row)
            let movieDetailsViewController = segue.destinationViewController as! MovieDetailsViewController
            movieDetailsViewController.movie = movie
        }
    }
}
