//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Bharath D N on 4/5/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    @objc optional func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String: [AnyObject]])
}

class FiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate {

    var categories: [[String: String]]!
    var filtersEx: [(String, [[String: Any]])] = []
    let CellIdentifier = "TableViewCell", HeaderViewIdentifier = "TableViewHeaderView"
    
    // filter values
    var dealsOffered = false
    var switchStates = [Int:Bool]()
    // sortby is Best Match by default
    var sortBy = 0
    // distance is 0 by default
    var distance = 0.00

    var isDistanceExpanded = false
    var filteredDistanceIndex = 0
    var isSortByExpanded = false
    var filteredSortIndex = 0
    
    @IBOutlet weak var tableView: UITableView!
    weak var delegate: FiltersViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        categories = YelpFilter.yelpCategories()
        
        filtersEx = [
            ("Deals Offered", [["name": "Deals", "code" : "deals"]]),
            ("Distance", YelpFilter.yelpDistances()),
            ("Sort By", YelpFilter.yelpSortValues()),
            ("category", YelpFilter.yelpCategories())
        ]
        
        print(filtersEx[2].1[0]["code"] as! Int)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellIdentifier)
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: HeaderViewIdentifier)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    
    @IBAction func onSearchButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        var searchfilters = [String: [AnyObject]]()
        
        // Fetch selected categories
        var selectedCategories = [String]()
        for (row, isSelected) in switchStates {
            if isSelected {
                selectedCategories.append(categories[row]["code"]!)
                let catg = categories[row]["code"]!
                print("adding selected category \(catg)")
            }
        }
        
        searchfilters["categories"] = selectedCategories as [AnyObject]
        searchfilters["dealsOffered"] = ([dealsOffered] as AnyObject) as? [AnyObject]
        searchfilters["distance"] = ([distance] as AnyObject) as? [AnyObject]
        searchfilters["sort"] = ([sortBy] as AnyObject) as? [AnyObject]
        
        delegate?.filtersViewController?(filtersViewController: self, didUpdateFilters: searchfilters)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (filtersEx as AnyObject).count
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0, 3 :
            return filtersEx[section].1.count
            
        case 1:
            if isDistanceExpanded {
                print("returning 3 for Distance section")
                return filtersEx[section].1.count
            }
            else {
                print("returning 1 for Distance section")
                return 1
            }
            
        case 2:
            if isSortByExpanded {
                print("returning 3 for SortBy section")
                return filtersEx[section].1.count
            }
            else {
                print("returning 1 for SortBy section")
                return 1
            }
            
        default:
            print("\n*** Error fetching numberOfRowsInSection ***\n")
            return filtersEx[section].1.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        
        switch section {
        case 0, 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
            cell.delegate = self
            let filter = filtersEx[section].1
            print(filter[indexPath.row]["name"]!)
            cell.switchLabel?.text = filter[indexPath.row]["name"]! as? String
            cell.onSwitch.isOn = false
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DropDownCell", for: indexPath) as! DropDownCell
            //cell.delegate = self
            let filter = filtersEx[section].1
            var labelText = ""
            
            if(!isDistanceExpanded) {
                print("\n\nfiltered Distance Index::: ")
                print(filter[filteredSortIndex]["name"]!)
                labelText = filter[filteredDistanceIndex]["name"]! as! String
                cell.dropDownView.image = #imageLiteral(resourceName: "down")
            }
            else {
                if(filteredDistanceIndex == row) {
                    cell.dropDownView.image = #imageLiteral(resourceName: "checked")
                }
                else {
                    cell.dropDownView.image = #imageLiteral(resourceName: "unchecked")
                }
                labelText = filter[indexPath.row]["name"]! as! String
            }
            
            cell.dropDownLabel?.text = labelText
            return cell
            
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DropDownCell", for: indexPath) as! DropDownCell
            //cell.delegate = self
            let filter = filtersEx[section].1
            var labelText = ""
            
            if(!isSortByExpanded) {
                print("\n\nfiltered sort Index::: ")
                print(filter[filteredSortIndex]["name"]!)
                labelText = filter[filteredSortIndex]["name"]! as! String
                cell.dropDownView.image = #imageLiteral(resourceName: "down")
            }
            else {
                if(filteredSortIndex == row) {
                    cell.dropDownView.image = #imageLiteral(resourceName: "checked")
                }
                else {
                    cell.dropDownView.image = #imageLiteral(resourceName: "unchecked")
                }
                
                labelText = filter[indexPath.row]["name"]! as! String
            }
            
            cell.dropDownLabel?.text = labelText
            return cell
        
        
        default:
            print("\n*** Error dequeing ***\n")
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: HeaderViewIdentifier)!
        header.textLabel?.text = filtersEx[section].0
        return header
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Row Selection => \(indexPath.row) was selected in section \(indexPath.section)")
        
        switch indexPath.section {
        case 1:
            if isDistanceExpanded {
                isDistanceExpanded = false
                filteredDistanceIndex = indexPath.row
                distance = filtersEx[1].1[filteredDistanceIndex]["code"] as! Double
            }
            else {
                isDistanceExpanded = true
            }
            tableView.reloadSections(IndexSet([indexPath.section]), with: .fade)
            
        case 2:
            if isSortByExpanded {
                isSortByExpanded = false
                filteredSortIndex = indexPath.row
                sortBy = filtersEx[2].1[filteredSortIndex]["code"] as! Int
            }
            else {
                isSortByExpanded = true
            }
            tableView.reloadSections(IndexSet([indexPath.section]), with: .automatic)
            
        default:
            print("Row Selection => Non Checkbox cell selected")
            return
        }
    }
    
    // Delegates Implementation
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPath(for: switchCell)!
        if(indexPath.section == 0) {
            dealsOffered = value
            print("Offers switch toggeld to \(value)")
        }
        else if(indexPath.section == 3) {
            switchStates[indexPath.row] = value
            print("Switch at index \(indexPath.row) for section \(indexPath.section) toggled to \(value)")
        }
        else {
            print("SwitchCell delegate could not detect the right section")
        }
    }
}
