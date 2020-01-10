//
//  DAEventTableViewController.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 7. 20..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit
import Material
import DownPicker
import SwipeCellKit
import KakaoLink
import CoreData

class DAEventTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating, SwipeTableViewCellDelegate, LSScrollButtonDelegate, DAGroupTableViewCellDelegate {
    class Segues{
        static let personView = "person";
    }
    
    static let CellID = "DAInfoTableViewCell";
    static let groupCellID = "DAGroupTableViewCell";
    
    fileprivate static var _shared : DAEventTableViewController?;
    static var shared : DAEventTableViewController?{
        get{
            return _shared;
        }
    }
    
    var excelController : DAExcelController{
        return DAExcelController.shared;
    }
    
    var modelController : DAModelController{
        return DAModelController.shared;
    }
    
    var searchController : UISearchController!;
    var searchBar : UISearchBar{
        get{
            return self.searchController.searchBar;
        }
    };
    
    enum SearchingType : Int{
        case byAll = 0
        case byName = 1
        case byArea = 2
    }
    
    var searchingType : SearchingType{
        get{
            return SearchingType(rawValue: self.searchBar.selectedScopeButtonIndex)!;
        }
    }
    
    var groups : [DAEventGroupInfo] = [];
    var group : DAEventGroupInfo!;
    var events : [DAPersonGroup] = [];
    
    var eventExpanding : [Int:Bool] = [:];
    
    @IBOutlet weak var groupButton: UIButton!
    var groupPicker : UIDownPicker!;
    var isAscending = true;
    var cellPreparingQueue = OperationQueue();
    
    var scrollButton : LSScrollButton?;
    var needAds = true{
        didSet{
            if self.isViewLoaded && !self.isMovingToParentViewController && self.navigationController?.topViewController === self{
                self.refresh();
            }
        }
    }
    
    var minimumRowsForAds : Int{
        get{
            return Int(self.tableView.height / self.tableView.rowHeight) - 1;
        }
    }
    
    var allHasLessRows : Bool{
        get{
            var value = true;
            
            for section in 0..<self.groups.count{
                value = value && self.groups.first!.groupEvents[section].eventMembers.count <= self.minimumRowsForAds;
            }
            
            return value;
        }
    }
    
    @IBOutlet weak var groupingSegment: UISegmentedControl!
    @IBOutlet weak var sortButton: UIBarButtonItem!
    
    var appearCount: Int = 0;
    override func viewWillAppear(_ animated: Bool) {
        self.searchByLaunchQuery();
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
        
        if DAEventTableViewController._shared == nil{
            DAEventTableViewController._shared = self;
        }
        
        //developer mode - upgrade database
        self.groups = self.modelController.loadEventGroups();
        self.group = self.groups.first!;
        self.events = self.modelController.loadEvents(self.group, isAscending: self.isAscending, name: "", area: "");
        self.groupPicker = UIDownPicker(data: self.groups.map({ (group) -> String in
            return group.name ?? "";
        }));
        
        self.groupPicker.downPicker.setToolbarDoneButtonText("완료");
        self.groupPicker.downPicker.setToolbarCancelButtonText("취소");
        self.groupPicker.downPicker.selectedIndex = self.groups.index(of: self.group) ?? 0;
        self.groupButton.setTitle(self.group.name, for: .normal);
        self.groupPicker.downPicker.addTarget(self, action: #selector(onGroupSelected(_:)), for: .valueChanged);
        self.view.addSubview(self.groupPicker);
        
        self.scrollButton = LSScrollButton(self);
        self.scrollButton?.delegate = self;
        
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
        
        self.searchController.hidesNavigationBarDuringPresentation = false;
        self.searchController.dimsBackgroundDuringPresentation = false;
        self.searchBar.scopeButtonTitles = ["모두", "이름", "지역"];
        self.searchBar.selectedScopeButtonIndex = 0;
        self.searchBar.sizeToFit();
        
        self.needAds = GADInterstialManager.shared?.canShow ?? true;
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if #available(iOS 11.0, *) {
            self.navigationItem.hidesSearchBarWhenScrolling = true;
        } else {
            // Fallback on earlier versions
            self.tableView.setContentOffset(CGPoint.zero, animated: true);
        };

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let cells = self.tableView.visibleCells as? [DAInfoTableViewCell] ?? []
        cells.forEach { (cell) in
            cell.hideSwipe(animated: true);
        }
    }
    
    func refresh(_ needToScrollTop : Bool = false){
        self.cellPreparingQueue.cancelAllOperations();
        self.tableView.reloadData();
        self.scrollButton?.updateNextButton();
        if needToScrollTop && self.tableView.numberOfSections > 0 && self.tableView.numberOfRows(inSection: 0) > 0{
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false);
        }
    }
    
    func searchByLaunchQuery(_ force : Bool = false){
        guard DAInfoTableViewController.startingQuery != nil else{
            return;
        }
        
        var urlComponents = URLComponents(url: DAInfoTableViewController.startingQuery!, resolvingAgainstBaseURL: true);
        var queryId = urlComponents?.queryItems?.first(where: { (query) -> Bool in
            return query.name == "id";
        })
        var queryName = urlComponents?.queryItems?.first(where: { (query) -> Bool in
            return query.name == "name";
        })
        /*var queryArea = urlComponents?.queryItems?.first(where: { (query) -> Bool in
            return query.name == "area";
        })*/
        var queryMobile = urlComponents?.queryItems?.first(where: { (query) -> Bool in
            return query.name == "mobile";
        })
        /*self.showAlert(title: "공지", msg: "\(queryName) \(queryArea)", actions: [UIAlertAction(title: "확인", style: .default, handler: nil)], style: .alert);
         DAInfoTableViewController.startingQuery = nil;*/
        
        guard force || queryMobile == nil else{
            guard let info = self.modelController.findPerson(Int16(queryId?.value ?? "0") ?? 0) else{
                self.searchByLaunchQuery(true);
                return;
            }
            
            guard info.personSms?.number != queryMobile?.value else{
                self.searchByLaunchQuery(true);
                return;
            }
            
            if let alert = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController as? UIAlertController{
                alert.dismiss(animated: false, completion: {
                    self.searchByLaunchQuery();
                });
                return;
            }
            
            self.showAlert(title: "핸드폰 번호 업데이트", msg: "\(info.job ?? "") \(info.name ?? "")의 휴대폰 번호를 '\(queryMobile!.value ?? "")'로 변경하시겠습니까?", actions: [UIAlertAction(title: "취소", style: .cancel, handler: { (act) in
                self.searchByLaunchQuery(true);
            }), UIAlertAction(title: "적용", style: .default, handler: { (act) in
                if info.personSms?.number != nil{
                    info.personSms?.number = queryMobile?.value;
                }else{
                    info.createPhone(name: "휴대폰", number: queryMobile?.value ?? "", canSendSMS: true);
                }
                self.modelController.saveChanges();
                
                self.searchByLaunchQuery(true);
            })], style: .alert);
            return;
        }
        
        self.searchBar.text = queryName?.value;
        //self.groupingType = .byGroup;
        self.searchBar(self.searchBar, textDidChange: queryName?.value?.trim() ?? "");
        self.searchBar.becomeFirstResponder();
        
        DAInfoTableViewController.startingQuery = nil;
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.scrollButton?.isDragging = true;
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.scrollButton?.isDragging = false;
        
        self.scrollButton?.updateMoveButtons(scrollView);
    }
    
    var beforeContentOffset : CGFloat = -100;
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.scrollButton?.layoutBeginButton();
        self.scrollButton?.layoutEndButton();
        //self.tableView.flashScrollIndicators();
        
        self.scrollButton?.isScrollingToUp = self.tableView.contentOffset.y < self.beforeContentOffset;
        self.beforeContentOffset = self.tableView.contentOffset.y;
        
        //self.endButton.isHidden = true;
        //print("scroll content offset[\(scrollView.contentOffset)] size[\(scrollView.contentSize)] height[\(scrollView.height)] tableOffset[\(self.tableView.contentOffset)]");
        
        self.scrollButton?.updateMoveButtons(scrollView);
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
            self.sortButton.image = UIImage(named: "icon_asc.png");
        }else{
            self.sortButton.image = UIImage(named: "icon_desc.png");
        }
        
        self.filter(self.searchBar.text ?? "");
        
        self.refresh();
    }
    
    func filter(_ keyword : String){
        var name = keyword;
        var area = keyword;
        
        switch self.searchingType{
        case .byName:
            area = "";
            break;
        case .byArea:
            name = "";
            break;
        default:
            break;
        }
        
        self.events = self.modelController.loadEvents(self.group, isAscending: self.isAscending, name: name, area: area);
    }
    
    func sortPersonsByName(groups : [DAExcelGroupInfo], needToOrderGroups : Bool) -> [DAExcelGroupInfo]{
        var values : [DAExcelGroupInfo] = groups;
        
        if needToOrderGroups{
            values.sort { (left, right) -> Bool in
                //return true;
                return (self.isAscending && left.title.compare(right.title) == .orderedAscending)
                    || (!self.isAscending && left.title.compare(right.title) == .orderedDescending);
            }
        }
        
        for group in groups{
            group.persons.sort(by: { (left, right) -> Bool in
                return (self.isAscending && left.name.compare(right.name) == .orderedAscending)
                    || (!self.isAscending && left.name.compare(right.name) == .orderedDescending);
            })
        }
        
        return values;
    }
    
    @objc func onGroupSelected(_ picker: DownPicker){
        guard self.group != self.groups[picker.selectedIndex] else{
            return;
        }
        
        self.group = self.groups[picker.selectedIndex];
        self.groupButton.setTitle(self.group.name, for: .normal);
        self.filter(self.searchBar.text ?? "");
        self.refresh(true);
        
        print("selected \(self.group.name ?? "")");
    }
    
    @IBAction func onGroup(_ sender: UIButton) {
        self.groupPicker.becomeFirstResponder();
    }
    
    // MARK: SwipeTableViewCellDelegate
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .left else{
            return nil;
        }
        var values : [SwipeAction] = [];
        
        let favOnImage = UIImage(named: "icon_favor_on")?.withRenderingMode(.alwaysTemplate);
        let favOffImage = UIImage(named: "icon_favor_off")?.withRenderingMode(.alwaysTemplate);
        
        let favAction = SwipeAction.init(style: .default, title: nil) { (act, indexPath) in
            let cell : DAInfoTableViewCell! = self.tableView.cellForRow(at: indexPath) as? DAInfoTableViewCell
            
            if let favor = self.modelController.findFavorite(cell.info!){
                self.modelController.removeFavorite(favor);
                //act.image = favOffImage;
            }
            else{
                self.modelController.createFavorite(person: cell.info!);
                //act.image = favOnImage;
            }
            
            self.modelController.saveChanges();
        }
        favAction.hidesWhenSelected = true;
        
        let cell : DAInfoTableViewCell! = self.tableView.cellForRow(at: indexPath) as? DAInfoTableViewCell;
        if self.modelController.findFavorite(cell.info!) != nil{
            favAction.image = favOnImage;
        }else{
            favAction.image = favOffImage;
        }
        //favAction.backgroundColor = Color.blue;
        let shareAction = SwipeAction.init(style: .default, title: nil) { (act, indexPath) in
            let cell : DAInfoTableViewCell! = self.tableView.cellForRow(at: indexPath) as? DAInfoTableViewCell
            //http://www.assembly.go.kr/photo/9770941.jpg
            cell.info?.shareByKakao();
        }
        shareAction.image = UIImage(named: "icon_share.png");
        shareAction.backgroundColor = UIColor.yellow;
        
        values.append(favAction);
        values.append(shareAction);
        values.append(contentsOf: cell.swipeActions);
        return values;
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions();
        
        options.buttonPadding = 0;
        options.buttonSpacing = 0;
        options.transitionStyle = .reveal;
        
        return options;
    }
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        let value = self.events.count;
        // #warning Incomplete implementation, return the number of sections
        /*switch self.groupingType{
         case .byName:
         value = filteredGroupsBySpell.count;
         break;
         case .byGroup:
         value = filteredGroups.count
         break;
         }*/
        
        return value;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var value = self.events[section].persons.count;
        // #warning Incomplete implementation, return the number of rows
        if !(self.eventExpanding[self.events[section].id] ?? true){
            value = 0;
        }
        
        //self.allHasLessRows &&
        return value;
        //return value + (self.needAds && (self.tableView.numberOfSections == 1 || value >= self.minimumRowsForAds || (self.tableView.numberOfSections - 1 == section)) ? 1 : 0);
        //return self.excelController.persons.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell?;
        var infoCell : DAInfoTableViewCell?;
        
        //has only one section or this is large section or this is last section
        //and this is last row
        //self.allHasLessRows &&
        /*if self.needAds && (self.tableView.numberOfSections == 1 || self.tableView.numberOfRows(inSection: indexPath.section) >= minimumRowsForAds || self.tableView.numberOfSections - 1 == indexPath.section)
            && indexPath.row == self.tableView.numberOfRows(inSection: indexPath.section) - 1{
            cell = tableView.dequeueReusableCell(withIdentifier: DAInfoTableViewController.CellIDs.BannerCell, for: indexPath) as? DABannerTableViewCell;
        }else{*/
            infoCell = tableView.dequeueReusableCell(withIdentifier: DAInfoTableViewController.CellIDs.InfoCell, for: indexPath) as? DAInfoTableViewCell;
            cell = infoCell;
            self.cellPreparingQueue.addOperation {
                /*guard (self.tableView.indexPathsForVisibleRows ?? []).contains(indexPath) else{
                 return;
                 }*/
                
                var person : DAPersonInfo?;
                let event = self.events[indexPath.section];
                person = event.persons[indexPath.row];
                DispatchQueue.main.sync {
                    guard (self.tableView.indexPathsForVisibleRows ?? []).contains(indexPath) else{
                        return;
                    }
                    
                    infoCell?.info = person;
                }
                infoCell?.delegate = self;
            }
        //}
        
        
        // Configure the cell...
        
        return cell!;
    }
    
    /*override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var values : [String] = [];
        //return ["abcde", "efghi"];
        switch self.groupingType{
        case .byName:
            values = self.groups.map({ (group) -> String in
                return group.title;
            });
            //tableView.scrollIndicatorInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16);
            break;
        case .byGroup:
            self.automaticallyAdjustsScrollViewInsets = true;
            break;
        default:
            self.automaticallyAdjustsScrollViewInsets = true;
            break;
        }
        
        return values.count > 1 ? values : [];
    }*/
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var value : String?;
        
        value = self.events[section].name;
        
        return value;
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var cell : DAGroupTableViewCell?;
        
        cell = tableView.dequeueReusableCell(withIdentifier: DAInfoTableViewController.CellIDs.GroupCell) as? DAGroupTableViewCell;
        cell?.group = self.events[section];
        cell?.delegate = self;
        
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var value : CGFloat = super.tableView(tableView, heightForHeaderInSection: section);
        
        //value = tableView.sectionHeaderHeight;
        value = 56.0;
        
        return value;
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return self.events.index(where: { (group) -> Bool in
            return group.name == title;
        }) ?? 0;
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return tue
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
        self.filter(searchText);
        
        self.refresh();
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar(searchBar, textDidChange: "");
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        switch self.searchingType{
        case .byAll:
            self.searchBar.placeholder = "검색할 이름이나 지역구 입력";
            break;
        case .byName:
            self.searchBar.placeholder = "검색할 이름 입력";
            break;
        case .byArea:
            self.searchBar.placeholder = "검색할 지역 입력";
            break;
        }
        
        self.searchBar(searchBar, textDidChange: searchBar.text ?? "");
    }
    
    // MARK: UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    // MARK: LSScrollButtonDelegate
    func titleForScrollButtonForSection(_ section: Int) -> String {
        return self.events[section].name;
    }
    
    // MARK: DAGroupTableViewCellDelegate
    func groupCellDidTap(_ cell: DAGroupTableViewCell) {
        self.eventExpanding[cell.group!.id] = !(self.eventExpanding[cell.group!.id] ?? true);
        
        //let section = self.events.index(of: cell.group!);
        self.refresh(false);
        /*return;
        self.tableView.beginUpdates();
        self.tableView.reloadSections(IndexSet(integer: (section)), with: .fade);
        self.tableView.endUpdates();*/
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
            
            manager.show(unit: .full) { [weak self](unit, ad) in
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
