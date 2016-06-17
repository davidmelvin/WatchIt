//
//  MoviesViewController.swift
//  WatchIt
//
//  Created by David Melvin on 6/15/16.
//  Copyright © 2016 David Melvin. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    //naming it imageView would conflict with internals
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var netorkErrorView: UIView!
    
    
    var movies: [NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.netorkErrorView.hidden = true;
        
        
        let refreshControl = UIRefreshControl()
        refreshControlAction(refreshControl)
        
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
         
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            // if movies is not nil
           return movies.count
        }
        else {
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell //downcast cell to MovieCell custom class
        
        let movie = movies![indexPath.row] //exclamation is you saying "I am sure this conditional will have a value"
        let title = movie["title"] as! String //as! is a force cast
        let overview = movie["overview"] as! String
        let baseURL = "http://image.tmdb.org/t/p/w500/"
        let posterPath = movie["poster_path"] as! String
        let imageURL = NSURL(string: baseURL + posterPath)
        
        cell.posterView.setImageWithURL(imageURL!)
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        
        
        return cell
    }
    
    func refreshControlAction(refreshControl : UIRefreshControl) {
        //can/should I move these constants outside of this function?
        let apiKey = "abc06d12299cb0cfc3bb4865fa38b909"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,completionHandler: { (dataOrNil, response, error) in
            
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            
            if let data = dataOrNil { //succesful
                
                self.netorkErrorView.hidden = true
                
                if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                    data, options:[]) as? NSDictionary {
                    //print("response: \(responseDictionary)")
                    print("gud response!")
                    self.netorkErrorView.hidden = true
                        self.tableView.frame = CGRectMake( 0, 20, self.tableView.frame.size.width, self.tableView.frame.size.height + 20); // set new position exactly
                    
                    
                    // specify the type of movies
                    self.movies = responseDictionary["results"] as? [NSDictionary]
                    self.tableView.reloadData()
                }
                
            }
            else {
                print("unsuccessful request!")
                self.netorkErrorView.hidden = false
                self.tableView.frame = CGRectMake( 0, 48, self.tableView.frame.size.width, self.tableView.frame.size.height ); // set new position exactly
            }
            
        });
        // Reload the tableView now that there is new data
        self.tableView.reloadData()
        
        // Tell the refreshControl to stop spinning
        refreshControl.endRefreshing()
        
        task.resume()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
