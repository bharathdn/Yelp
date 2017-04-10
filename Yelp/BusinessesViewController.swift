//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FiltersViewControllerDelegate {
    
    var businesses: [Business]!
    var filteredBusinesses: [Business]!
    var searchBar: UISearchBar!
    var searchController: UISearchController!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        // Let the rowheight be decided by Auto-Layout
        tableView.rowHeight = UITableViewAutomaticDimension
        // Ballpark the number so that, scrollview can easily estimate the height and then lazily calculate the actual height
        tableView.estimatedRowHeight = 120 
        
        searchUpdateResults(searchTerm: nil)
        
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
    
 
    // MARK: - Navigation
     
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationViewController = segue.destination as! UINavigationController
        let filtersViewController = navigationViewController.topViewController as! FiltersViewController
        filtersViewController.delegate = self
    }
    
    
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String: [AnyObject]]) {
        
        let deals = filters["dealsOffered"]?[0] as? Bool
        let sort = filters["sort"]?[0] as? Int
        let distance = filters["distance"]?[0] as? Int
        let categories = filters["categories"] as? [String]
        
        Business.searchWithTerm(term: "Restaurants", sort: YelpSortMode(rawValue: sort!), categories: categories, deals: deals) { (businesses: [Business]!, error: Error!) -> Void in
            self.businesses = businesses
            print("\n\n \(businesses.count) numeber of Businesses returned from search")
            self.tableView.reloadData()
        }
    }
    
    func searchUpdateResults(searchTerm: String?) {
        Business.searchWithTerm(term: searchTerm ?? "Restaurants", completion: { (businesses: [Business]?, error: Error?) -> Void in
            
            self.businesses = businesses
            self.tableView.reloadData()
            
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
        searchUpdateResults(searchTerm: searchTerm!)
    }
}
