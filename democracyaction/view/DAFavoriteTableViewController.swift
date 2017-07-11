//
//  DAFavoriteTableViewController.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 6. 28..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit
import SwipeCellKit

class DAFavoriteTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating, SwipeTableViewCellDelegate {
    static let CellID = "DAInfoTableViewCell";
    static let adCellID = "DABannerTableViewCell";

    fileprivate static var _shared : DAFavoriteTableViewController?;
    static var shared : DAFavoriteTableViewController?{
        get{
            return _shared;
        }
    }
    
    var modelController : DAModelController{
        return DAModelController.Default;
    }
    
    var searchController : UISearchController!;
    //var searchContainer : UISearchContainerViewController!;
    var searchBar : UISearchBar{
        get{
            return self.searchController.searchBar;
        }
    };
    
    var isAscending = true;
    
    var favorites : [DAFavoriteInfo] = [];
    var needAds = true{
        didSet{
            if self.isViewLoaded && !self.isMovingToParentViewController && self.navigationController?.topViewController === self{
                self.refresh();
            }
        }
    }

    @IBOutlet weak var sortButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if DAFavoriteTableViewController._shared == nil{
            DAFavoriteTableViewController._shared = self;
        }
        //developer mode - upgrade database
        //load groups & persons from excel
        
        //convert to database
        //self.groupsBySpell = DAExcelController.Default.groupsBySpell();
        //self.favorites = self.modelController.loadFavoritesByName(self.isAscending);
        //self.filteredGroupsBySpell = self.groupsBySpell;
        //firstWords = groupsBySpell.keys.sorted();
        
        self.searchController = UISearchController(searchResultsController: nil);
        self.searchController.searchResultsUpdater = self;
        self.searchBar.delegate = self;
        self.definesPresentationContext = true;
        self.tableView.tableHeaderView = self.searchController.searchBar;
        self.searchBar.placeholder = "검색할 이름이나 지역구 입력";
        self.searchBar.returnKeyType = .done;
        //self.searchBar.tintColor = Color.yellow;
        
        //self.searchContainer = UISearchContainerViewController(searchController: self.searchController);
        //self.searchBar = SearchBar()
        self.searchController.hidesNavigationBarDuringPresentation = false;
        self.searchController.dimsBackgroundDuringPresentation = false;
        //self.navigationItem.titleView = self.searchController.searchBar;
        //self.searchBar.scopeButtonTitles = ["모두", "이름", "지역"];
        self.searchBar.selectedScopeButtonIndex = 0;
        //self.searchBar.showsSearchResultsButton = true;
        //self.searchBar.showsScopeBar = true;
        self.searchBar.sizeToFit();
        
        self.needAds = DAInfoTableViewController.shared?.needAds ?? true;
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.favorites = self.modelController.loadFavoritesByName(self.isAscending);
        self.refresh();
    }
    
    func refresh(_ needToScrollTop : Bool = false){
        self.tableView.reloadData();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func onShare(_ sender: UIBarButtonItem) {
        ReviewManager.shared?.show(true);
    }
    
    @IBAction func onSort(_ button: UIBarButtonItem) {
        self.isAscending = !self.isAscending;
        if self.isAscending{
            button.image = UIImage(named: "icon_asc.png");
        }else{
            button.image = UIImage(named: "icon_desc.png");
        }

        self.filterByName(self.searchBar.text ?? "");
        
        self.refresh();
    }
    
    
    
    func filterByName(_ keyword : String){
        self.favorites = self.modelController.loadFavoritesByName(self.isAscending, name: keyword, area: keyword);
        
        //self.filteredGroupsBySpell = self.sortPersonsByName(groups: self.filteredGroupsBySpell, needToOrderGroups: true);
    }
    
    // MARK: SwipeTableViewCellDelegate
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        var values : [SwipeAction] = [];
        var cell : DAInfoTableViewCell! = self.tableView.cellForRow(at: indexPath) as? DAInfoTableViewCell;
        
        guard orientation == .right else{
            var shareAction = SwipeAction.init(style: .default, title: nil) { (act, indexPath) in
                var cell : DAInfoTableViewCell! = self.tableView.cellForRow(at: indexPath) as? DAInfoTableViewCell
                //http://www.assembly.go.kr/photo/9770941.jpg
                cell.info?.shareByKakao();
            }
            shareAction.image = UIImage(named: "icon_share.png");
            shareAction.backgroundColor = UIColor.yellow;
            values.append(shareAction);
            values.append(contentsOf: cell.swipeActions);
            return values;
        }
        
        let delImage = UIImage(named: "icon_del")?.withRenderingMode(.alwaysTemplate);
        
        var delAction = SwipeAction.init(style: .destructive, title: nil) { (act, indexPath) in
            var cell : DAInfoTableViewCell! = self.tableView.cellForRow(at: indexPath) as? DAInfoTableViewCell
            
            self.tableView.beginUpdates()
            var favor = self.favorites[indexPath.row];
            //if let favor = self.modelController.findFavorite(cell.info!){
                self.modelController.removeFavorite(favor);
                self.favorites.remove(at: indexPath.row);
                //act.image = favOffImage;
            //}
            
            self.modelController.saveChanges();
            //self.tableView.deleteRows(at: [indexPath], with: .automatic);
            act.fulfill(with: .delete);
            self.tableView.endUpdates()
            //cell.hideSwipe(animated: true);
        }
        
        delAction.image = delImage;
        //favAction.backgroundColor = UIColor.red;
        //favAction.backgroundColor = Color.blue;
        values.append(delAction);
        
        return [delAction];
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions();
        
        options.expansionStyle = .destructive;
        options.transitionStyle = .reveal;
        
        return options;
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        var value = 1;
        
        return value;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var value = self.favorites.count;
        // #warning Incomplete implementation, return the number of rows
        /*switch self.groupingType{
         case .byName:
         //var key = self.groupsBySpell.keys.sorted()[section];
         var group = self.filteredGroupsBySpell[section]
         value = group.persons.count;
         break;
         case .byGroup:
         var group = self.filteredGroups[section];
         value = self.filteredGroups[section].persons.count;
         break;
         }*/
        
        return value + (self.needAds ? 1 : 0);
        //return self.excelController.persons.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell?;
        var infoCell : DAInfoTableViewCell?;
        
        
        if self.needAds && indexPath.row == self.tableView.numberOfRows(inSection: indexPath.section) - 1{
            cell = tableView.dequeueReusableCell(withIdentifier: DAInfoTableViewController.adCellID, for: indexPath) as? DABannerTableViewCell;
        }else{
            infoCell = tableView.dequeueReusableCell(withIdentifier: DAInfoTableViewController.CellID, for: indexPath) as? DAInfoTableViewCell;
            
            var person : DAPersonInfo? = self.favorites[indexPath.row].person;
            
            infoCell?.info = person;
            infoCell?.delegate = self;
            cell = infoCell;
        }
        
        return cell!;
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    // MARK: UISearchBarDelegate
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //searchBar.sizeToFit();
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //searchBar.sizeToFit();
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("search keyword changed. keyword[\(searchText)]");
        
        self.filterByName(searchText);
        
        self.refresh();
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar(searchBar, textDidChange: "");
    }
    
    // MARK: UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
