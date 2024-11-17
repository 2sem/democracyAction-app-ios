//
//  DAFavoriteTableViewController.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 6. 28..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit
import SwipeCellKit
import CoreData
import GADManager
import GoogleMobileAds

class DAFavoriteTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating, SwipeTableViewCellDelegate, NSFetchedResultsControllerDelegate {
    class Segues{
        static let personView = "person";
    }
    
    static let CellID = "DAInfoTableViewCell";

    fileprivate static var _shared : DAFavoriteTableViewController?;
    static var shared : DAFavoriteTableViewController?{
        get{
            return _shared;
        }
    }
    
    lazy var favorController : DAFavorFatchedResultController = {
        return DAFavorFatchedResultController(managedObjectContext: DAModelController.shared.context, delegate: self);
    }()
    lazy var modelController = DAModelController.shared;
    
    var searchController : UISearchController!;
    //var searchContainer : UISearchContainerViewController!;
    var searchBar : UISearchBar{
        get{
            return self.searchController.searchBar;
        }
    };
    
    var isAscending = true;
    
    var needAds = true{
        didSet{
            if self.isViewLoaded && !self.isMovingToParent && self.navigationController?.topViewController === self{
                self.refresh();
            }
        }
    }

    @IBOutlet weak var sortButton: UIBarButtonItem!
    @IBOutlet var banner: GADBannerView!

    var lastAlarmButton : UIButton?;
    
    var appearCount: Int = 0;
    
    override func viewWillAppear(_ animated: Bool) {
        if #available(iOS 11.0, *) {
            self.navigationItem.hidesSearchBarWhenScrolling = false;
        }
        
        if self.appearCount > 0 {
            AppDelegate.sharedGADManager?.show(unit: .full);
        }
        self.appearCount = self.appearCount.advanced(by: 1);
    }
    
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
        if #available(iOS 11.0, *){
            self.navigationItem.searchController = self.searchController;
        }else{
            self.tableView.tableHeaderView = self.searchController.searchBar;
        }
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
        self.searchBar(self.searchBar, textDidChange: "");
        
        self.needAds = DAInfoTableViewController.shared?.needAds ?? true;
        
        switch UIDevice.current.userInterfaceIdiom {
            case .pad:
                self.banner = AppDelegate.sharedGADManager?.prepare(bannerUnit: .fav, size: GADAdSizeFullBanner);
                break;
            default:
                self.banner = AppDelegate.sharedGADManager?.prepare(bannerUnit: .fav);
                break;
        }
        
        self.tableView?.hideExtraRows = true;
        if let tableView = self.tableView, let banner = self.banner{
            self.view?.addSubview(banner);
            //banner.translatesAutoresizingMaskIntoConstraints = false;
            //banner.heightAnchor.constraint(equalToConstant: 50).isActive = true;
            //banner.leadingAnchor.constraint(equalTo: tableView.leadingAnchor).isActive = true;
            //banner.trailingAnchor.constraint(equalTo: tableView.trailingAnchor).isActive = true;
            //banner.bottomAnchor.constraint(equalTo: tableView.bottomAnchor).isActive = true;
            banner.frame.size.width = tableView.frame.width;
            
            banner.delegate = self;
            banner.rootViewController = self;
            self.banner?.isHidden = true;
            banner.load(GADRequest());
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false;
        if #available(iOS 11.0, *) {
            self.navigationItem.hidesSearchBarWhenScrolling = true;
        } else {
            // Fallback on earlier versions
            self.tableView.setContentOffset(CGPoint.zero, animated: true);
        };
        /*self.favorites.forEach { (fav) in
            guard fav.person == nil else{
                return
            }
            
            let index : Int! = self.favorites.index(of: fav);
            guard index != nil else{
                return;
            }
            
            self.modelController.removeFavorite(fav);
            self.favorites.remove(at: index);
        }
        self.modelController.saveChanges();
        self.refresh();*/
    }
    
    override func viewDidLayoutSubviews() {
        guard let tableView = self.tableView, let banner = self.banner else{
            return;
        }
        
        banner.frame.size.width = tableView.frame.width;
    }
    
    func layoutBanner(){
        guard let banner = self.banner else{
            return;
        }
        
        banner.frame.origin.y = self.view.bounds.maxY - banner.bounds.height * 1.2;
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.layoutBanner();
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
        //self.favorites = self.favorController.loadFavorites(self.isAscending, ByName: keyword, ByArea: keyword);
        self.favorController.query(self.isAscending, ByName: keyword, ByArea: keyword);
        
        //self.filteredGroupsBySpell = self.sortPersonsByName(groups: self.filteredGroupsBySpell, needToOrderGroups: true);
    }
    
    // MARK: SwipeTableViewCellDelegate
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        var values : [SwipeAction] = [];
        let cell : DAInfoTableViewCell! = self.tableView.cellForRow(at: indexPath) as? DAInfoTableViewCell;
        
        guard orientation == .right else{
            let shareAction = SwipeAction.init(style: .default, title: nil) { (act, indexPath) in
                let cell : DAInfoTableViewCell! = self.tableView.cellForRow(at: indexPath) as? DAInfoTableViewCell
                //http://www.assembly.go.kr/photo/9770941.jpg
                cell.info?.shareByKakao();
            }
            shareAction.image = UIImage(named: "icon_share.png");
            shareAction.backgroundColor = UIColor.yellow;
            values.append(shareAction);
            
            guard let favor = self.favorController.fetch(indexPath: indexPath) else{
                values.append(contentsOf: cell.swipeActions);
                return values;
            }
            
            let alarmAction = SwipeAction.init(style: .default, title: nil){ [unowned self](act, indexPath) in
                guard let favor = self.favorController.fetch(indexPath: indexPath), let person = favor.person else{
                    return;
                }
                let topic = "congress_\(person.assemblyNo)_\(person.assembly)_law";
                
                if !favor.isAlarmOn{
                    AppDelegate.firebase?.subscribe(toTopic: topic, completion: { (error) in
                        guard error == nil else{
                            return;
                        }
                        
                        favor.isAlarmOn = !favor.isAlarmOn;
                        self.modelController.saveChanges();
                        let image = UIImage(named: "icon_notification_\(favor.isAlarmOn ? "on" : "off").png");
                        self.lastAlarmButton?.setImage(image, for: .normal);
                        print("subscribing has been turned on. topic[\(topic)]");
                    })
                }else{
                    AppDelegate.firebase.unsubscribe(fromTopic: topic, completion: { (error) in
                        guard error == nil else{
                            return;
                        }
                        
                        favor.isAlarmOn = !favor.isAlarmOn;
                        self.modelController.saveChanges();
                        let image = UIImage(named: "icon_notification_\(favor.isAlarmOn ? "on" : "off").png");
                        self.lastAlarmButton?.setImage(image, for: .normal);
                        print("subscribing has been turned off. topic[\(topic)]");
                    })
                }
            }
            alarmAction.textColor = UIColor.black;
            alarmAction.image = UIImage(named: "icon_notification_\(favor.isAlarmOn ? "on" : "off").png");
            alarmAction.backgroundColor = UIColor.green;
            alarmAction.transitionDelegate = self;
            alarmAction.hidesWhenSelected = true;
            values.append(alarmAction);
            values.append(contentsOf: cell.swipeActions);
            return values;
        }
        
        let delImage = UIImage(named: "icon_del")?.withRenderingMode(.alwaysTemplate);
        
        let delAction = SwipeAction.init(style: .destructive, title: nil) { (act, indexPath) in
            //let cell : DAInfoTableViewCell! = self.tableView.cellForRow(at: indexPath) as? DAInfoTableViewCell
            
            self.tableView.beginUpdates()
            if let favor = self.favorController.fetch(indexPath: indexPath){
                self.modelController.removeFavorite(favor);
                self.modelController.saveChanges();
            }
            
            //self.tableView.deleteRows(at: [indexPath], with: .automatic);
            act.fulfill(with: .delete);
            self.tableView.endUpdates();
            //cell.hideSwipe(animated: true);
        }
        
        delAction.image = delImage;
        //favAction.backgroundColor = UIColor.red;
        //favAction.backgroundColor = Color.blue;
        
        return [delAction];
    }
    
    /*func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions();
        
        options.expansionStyle = .destructive;
        options.transitionStyle = .reveal;
        
        return options;
    }*/
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        let value = 1;
        
        return value;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let value = self.favorController.count(section: 0);
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
        
        return value;
        // + (self.needAds ? 1 : 0);
        //return self.excelController.persons.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell?;
        var infoCell : DAInfoTableViewCell?;
        
        infoCell = tableView.dequeueReusableCell(withIdentifier: DAInfoTableViewController.CellIDs.InfoCell, for: indexPath) as? DAInfoTableViewCell;
        
        if let favor = self.favorController.fetch(indexPath: indexPath) {
            if let person = favor.person, person.name?.any ?? false{
                infoCell?.info = person;
            }
        }
        infoCell?.delegate = self;
        cell = infoCell;
        
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
    
    // MARK: NSFetchedResultsControllerDelegate
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type{
            case .insert:
                if let newIndexPath = newIndexPath{
                    self.tableView.insertRows(at: [newIndexPath], with: .fade);
                }
                break;
            case .delete:
                if let indexPath = indexPath{
                    self.tableView.deleteRows(at: [indexPath], with: .fade);
                }
                break;
            default:
                break;
        }
    }
    
    // MARK: - Navigation
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        var value = true;
        
        switch identifier {
        case Segues.personView:
            guard let manager = AppDelegate.sharedGADManager else{
                return value;
            }
            
            guard manager.canShow(.full) else{
                return value;
            }
            
            manager.show(unit: .full) { [weak self](unit, ad, result) in
                self?.performSegue(withIdentifier: identifier, sender: sender);
            }
            value = false;
            break;
        default:
            break;
        }
        
        return value;
    }
    
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let personView = segue.destination as? DAPersonViewController, let cell = sender as? DAInfoTableViewCell{
            personView.info = cell.info;
        }
     }
}

extension DAFavoriteTableViewController : SwipeActionTransitioning{
    func didTransition(with context: SwipeActionTransitioningContext) {
        self.lastAlarmButton = context.button;
    }
}

extension DAFavoriteTableViewController : GADBannerViewDelegate{
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("receive info banner");
        self.banner?.isHidden = false;
        self.tableView?.contentInset.bottom = 50 + 16;
        self.layoutBanner();
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("receive info banner failed. error[\(error.localizedDescription)]");
    }
}
