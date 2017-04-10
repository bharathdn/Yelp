//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import CoreLocation;

//let locationMgr = CLLocationManager()
// CLLocationManagerDelegate

class BusinessesViewController: UIViewController, FiltersViewControllerDelegate {
    
    var businesses: [Business]!
    var filteredBusinesses: [Business]!
    var searchBar: UISearchBar!
    var searchController: UISearchController!
    var isMoreDataLoading = false

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // request location permission
//        locationMgr.requestWhenInUseAuthorization()
        
        tableView.delegate = self
        tableView.dataSource = self
        // Let the rowheight be decided by Auto-Layout
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120 
        
        searchUpdateResults(searchTerm: nil, offset: nil, limit: nil)
        
        // Initialize the UISearchBar
        searchBar = UISearchBar()
        searchBar.delegate = self
        
        // Add SearchBar to the NavigationBar
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 
    // MARK: - Navigation
     
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationViewController = segue.destination as! UINavigationController
        let filtersViewController = navigationViewController.topViewController as! FiltersViewController
        filtersViewController.delegate = self
    }
    
    
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters searchFilters: [String: [AnyObject]]) {
        
        let deals = searchFilters["dealsOffered"]?[0] as! Bool
        let sort = searchFilters["sort"]?[0] as! Int
        let categories = searchFilters["categories"] as! [String]
        
        let distance = searchFilters["distance"]?[0] as! Double

        Business.searchWithTerm(term: "Restaurants", sort: YelpSortMode(rawValue: sort), categories: categories, deals: deals, distance: distance, offset: nil, limit: nil) { (businesses: [Business]!, error: Error!) -> Void in
            self.businesses = businesses
            print("\n\n \(businesses.count) number of Businesses returned from search")
            self.tableView.reloadData()
        }
    }
    
    
    func searchUpdateResults(searchTerm: String?, offset: Int?, limit: Int?) {
        Business.searchWithTerm(term: searchTerm ?? "Restaurants", offset: offset ?? 0, limit: limit ?? 0 ,completion: { (businesses: [Business]?, error: Error?) -> Void in
            
            self.businesses = businesses
            self.tableView.reloadData()
            
            print("\n\n \(businesses?.count ?? 0) number of Businesses returned from search")
            
            // dev console
            if let businesses = businesses {
                for business in businesses {
                    print(business.name!)
                    print(business.address!)
                }
            }
        })
        
        /* Example of Yelp search with more search options specified
         Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
         self.businesses = businesses
         
         for business in businesses {
         print(business.name!)
         print(business.address!)
         }
         }
         */
    }
    
//    class func getLocation() -> CLLocationCoordinate2D? {
//        if CLLocationManager.locationServicesEnabled() {
//            locationMgr.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//            return locationMgr.location?.coordinate
//        }
//        return nil
//    }
}

extension BusinessesViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(businesses != nil) {
            return businesses.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
        
        cell.business = businesses[indexPath.row]
        return cell
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        // Calculate the position of one screen length before the bottom of the results
//        let scrollViewContentHeight = tableView.contentSize.height
//        let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
//        
//        if (!isMoreDataLoading) {
//            print("UI Scrolled for more data")
//            isMoreDataLoading = true
//        }
//    }
}

extension BusinessesViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchTerm = searchBar.text
        searchBar.resignFirstResponder()
        searchUpdateResults(searchTerm: searchTerm!, offset: nil, limit: nil)
    }
}
