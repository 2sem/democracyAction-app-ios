//
//  DAInfoTableViewController.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 6. 8..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit
import Material
import DownPicker
import SwipeCellKit
import KakaoLink
import MBProgressHUD
import LSExtensions


class DAInfoTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating, SwipeTableViewCellDelegate, DAGroupTableViewCellDelegate {
    class Segues{
        static let personView = "person";
    }
    
    class CellIDs{
        static let InfoCell = "DAInfoTableViewCell";
        static let GroupCell = "DAGroupTableViewCell";
        static let ads = "ads";
    }

    fileprivate static var _shared : DAInfoTableViewController?;
    static var shared : DAInfoTableViewController?{
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
    
    // = URL(string: "kakaolink://test?name=손혜원&area=호호".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "")
    static var startingQuery : URL?{
        didSet{
            guard let tabs = UIApplication.shared.keyWindow?
                .rootViewController as? UITabBarController else{
                return;
            }
            
            if let nav = tabs.selectedViewController as? UINavigationController{
                if let infoTable = nav.viewControllers.first as? DAInfoTableViewController{
                    if infoTable.isViewLoaded{
                        //query by kakao link
                        infoTable.searchByLaunchQuery();
                    }
                }else if (tabs.viewControllers?.count ?? 0) > 0{
                    tabs.selectedIndex = 0;
                }
            }
        }
    }
    
    enum GroupingType : Int{
        case byName = 0
        case byGroup = 1
        case byArea = 2
    }
    
    var groupingType : GroupingType{
        get{
            return GroupingType(rawValue: self.groupingSegment.selectedSegmentIndex)!;
        }
    };
    var groupingTypes = ["이름별", "정당별", "지역별"];
    
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
    
    var groups : [DAPersonGroup] = [];
    var groupExpanding : [Int:Bool] = [:];
    
    var areas = ["서울", "경남", "경북", "제주", "비례대표",  "충남", "충북", "대전", "대구", "강원", "광주", "대전", "경기", "부산", "전북", "인천" , "전남", "세종", "울산"];
    var isAscending = true;
    var cellPreparingQueue = OperationQueue();
    
    var beginButton : UIButton!;
    var endButton : UIButton!;
    var beforeButton : UIButton!;
    var nextButton : UIButton!;
    
    var needAds = true{
        didSet{
            if self.isViewLoaded && !self.isMovingToParent && self.navigationController?.topViewController === self{
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
                value = value && self.groups[section].persons.count <= self.minimumRowsForAds;
            }
            
            return value;
        }
    }
    
    func isAdsCell(_ indexPath: IndexPath) -> Bool{
//        switch self.groupingType{
//            case.byName:
//                return indexPath.section == 0;
//            default:
//                break;
//        }
        
        return indexPath.section == 0;
    }
    
    func isAdsSection(_ section: Int) -> Bool{
//        switch self.groupingType{
//            case.byName:
//                return section == 0;
//            default:
//                break;
//        }
        
        return section == 0;
    }
    
    var needAdsCell : Bool{
        get{
//            switch self.groupingType{
//                case.byName:
//                    return true;
//                default:
//                    break;
//            }
            
            return true;
        }
    }
    
    func realGroup(section: Int) -> DAPersonGroup{
        return self.needAdsCell ? self.groups[section.advanced(by: -1)] : self.groups[section];
    }
    
    @IBOutlet weak var groupingButton: UIButton!
    @IBOutlet weak var groupingSegment: UISegmentedControl!
    @IBOutlet weak var sortButton: UIBarButtonItem!
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil);
        
        self.searchByLaunchQuery();
        if #available(iOS 11.0, *) {
            self.navigationItem.hidesSearchBarWhenScrolling = false;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if DAInfoTableViewController._shared == nil{
            DAInfoTableViewController._shared = self;
        }
        
        var hub : MBProgressHUD?;
        DAUpdateManger.shared.update(progress: { (state, error) in
            DispatchQueue.main.syncInMain{
                if hub == nil{
                    hub = MBProgressHUD.showAdded(to: self.view, animated: true);
                    hub?.mode = .indeterminate;
                    //hub?.dimBackground = true;
                }
                hub?.label.text = state.rawValue;
                self.blockInterface(block: true);
            }
        }, completion: { (result) in
            //end update
            guard result else{
                DispatchQueue.main.async{
                    MBProgressHUD.hide(for: self.view, animated: true);
                    self.searchBar(self.searchBar, textDidChange: self.searchBar.text ?? "");
                    self.blockInterface(block: false);
                    self.refresh();
                    GADInterstialManager.shared?.show();
                }
                return;
            }
            
            DispatchQueue.main.async{
                MBProgressHUD.hide(for: self.view, animated: true);
                self.searchBar(self.searchBar, textDidChange: self.searchBar.text ?? "");
                self.blockInterface(block: false);
                self.showNotice();
                //GADInterstialManager.shared?.show();
            }
        })
        
        //convert to database
        //self.groupsBySpell = DAExcelController.Default.groupsBySpell();
        if !DADefaults.DataDownloaded{
        }
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
        self.searchBar.scopeButtonTitles = ["모두", "이름", "지역"];
        self.searchBar.selectedScopeButtonIndex = 0;
        //self.searchBar.showsSearchResultsButton = true;
        //self.searchBar.showsScopeBar = true;
        self.searchBar.sizeToFit();
        
        self.beginButton = UIButton();
        self.view.addSubview(self.beginButton);
        self.beginButton.backgroundColor = "#78909c".toUIColor();
        self.beginButton.setImage(UIImage(named: "icon_up.png"), for: .normal);
        self.beginButton.widthAnchor.constraint(equalToConstant: 44).isActive = true;
        self.beginButton.heightAnchor.constraint(equalToConstant: 44).isActive = true;
        self.beginButton.frame.size = CGSize(width: 44, height: 44);
        self.beginButton.frame.origin.x = 16;
        self.beginButton.layer.cornerRadius = 5.0;
        self.beginButton.addTarget(self, action: #selector(self.onGoBeginRow(_:)), for: .touchUpInside);
        self.layoutBeginButton(self.beginButton);
        self.beginButton.isHidden = true;

        self.endButton = UIButton();
        self.view.addSubview(self.endButton);
        self.endButton.backgroundColor = "#78909c".toUIColor();
        self.endButton.setImage(UIImage(named: "icon_down.png"), for: .normal);
        self.endButton.widthAnchor.constraint(equalToConstant: 44).isActive = true;
        self.endButton.heightAnchor.constraint(equalToConstant: 44).isActive = true;
        self.endButton.frame.size = CGSize(width: 44, height: 44);
        self.endButton.frame.origin.x = 16;
        self.endButton.leadingAnchor.constraint(equalTo: self.tableView.leadingAnchor, constant: 16).isActive = true;
        self.endButton.layer.cornerRadius = 5.0;
        self.endButton.addTarget(self, action: #selector(self.onGoEndRow(_:)), for: .touchUpInside);
        self.layoutEndButton(self.endButton);
        
        self.nextButton = UIButton();
        self.view.addSubview(self.nextButton);
        self.nextButton.backgroundColor = "#78909c".toUIColor();
        self.nextButton.setImage(UIImage(named: "icon_down.png"), for: .normal);
        self.nextButton.setTitle("ㄱ", for: .normal)
        self.nextButton.widthAnchor.constraint(equalToConstant: 44 * 2).isActive = true;
        self.nextButton.heightAnchor.constraint(equalToConstant: 44).isActive = true;
        self.nextButton.frame.size = CGSize(width: 44, height: 44);
        self.nextButton.frame.origin.x = 16 + 44 + 8;
        self.nextButton.leadingAnchor.constraint(equalTo: self.tableView.leadingAnchor, constant: 16 + 44 + 8).isActive = true;
        self.nextButton.layer.cornerRadius = 5.0;
        self.nextButton.addTarget(self, action: #selector(self.onGoNextSection(_:)), for: .touchUpInside);
        self.layoutEndButton(self.nextButton);
        
        self.needAds = GADInterstialManager.shared?.canShow ?? true;
        
//        self.tableView.contentInset.bottom = self.tableView.rowHeight;
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
    
    func blockInterface(block : Bool){
        self.view.isUserInteractionEnabled = !block;
        self.navigationController?.navigationBar.isUserInteractionEnabled = !block;
        self.tabBarController?.tabBar.isUserInteractionEnabled = !block;
    }
    
    func showNotice(){
        if DAInfoTableViewController.startingQuery == nil && DADefaults.LastNotice < self.excelController.noticeDate{
            let noticeView : DANoticeViewController! = DANoticeViewController.instantiate();
            //noticeView.modalPresentationStyle = .formSheet;
            noticeView.text = self.excelController.notice + "\n\n[\(self.excelController.version) 패치 내용]\n" + self.excelController.patch;
            self.present(noticeView, animated: true, completion: nil);
            
            DADefaults.LastNotice = Date();
            //\n\n'\(UIApplication.shared.displayName ?? "")'은 특정정당을 위해 개발한 어플이 아닙니다.
        }
    }
    
    func refresh(_ needToScrollTop : Bool = false){
        self.cellPreparingQueue.cancelAllOperations();
        self.tableView.reloadData();
        self.updateMoveButtons(self.tableView);
        self.updateNextButton();
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
        var queryMobile = urlComponents?.queryItems?.first(where: { (query) -> Bool in
            return query.name == "mobile";
        })
        
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
        self.groupingSegment.selectedSegmentIndex = GroupingType.byGroup.rawValue;
        
        self.searchBar(self.searchBar, textDidChange: queryName?.value?.trim() ?? "");
        self.searchBar.becomeFirstResponder();
        
        DAInfoTableViewController.startingQuery = nil;
    }
    
    func updateMoveButtons(_ scrollView : UIScrollView){
        self.updateBeginButton(scrollView);
        self.updateEndButton(scrollView);
        self.updateNextButton();
    }
    
    func updateBeginButton(_ scrollView : UIScrollView){
        self.beginButton.isHidden = true;
        if self.tableView.contentOffset.y > scrollView.height * 0.5{
            self.beginButton.isHidden = (false || self.isDragging) && self.isScrollingToUp;
        }
    }
    
    func updateEndButton(_ scrollView : UIScrollView){
        self.endButton.isHidden = true;
        if self.tableView.contentOffset.y < scrollView.contentSize.height.advanced(by: -scrollView.height * 1.33){
            self.endButton.isHidden = (false || self.isDragging) && !self.isScrollingToUp;
        }
    }
    
    func updateNextButton(){
        let maxSection = self.tableView.numberOfSections - 1;
        
        self.nextButton.isHidden = (false || self.isDragging) && !self.isScrollingToUp;
        if !self.nextButton.isHidden{
//            self.endButton.isHidden = false;
        }
        guard let lastIndexPath = self.tableView.indexPathsForVisibleRows?.last else{
            self.nextButton.isHidden = true;
            return;
        }
        
        guard maxSection > lastIndexPath.section else{
            self.nextButton.isHidden = true;
            return;
        }

        let nextSection = lastIndexPath.section.advanced(by: 1);
        guard let group = self.groups[safe: nextSection] else{
            return;
        }
    
        self.nextButton.setTitle(group.name, for: .normal);
        switch self.groupingType{
        case .byName:
            self.nextButton.setTitle(group.name, for: .normal);
            
            self.nextButton.frame.size.width = 44 + 8;
            break;
        case .byGroup, .byArea:
            self.nextButton.sizeToFit();
    
            self.nextButton.frame.size.width += 8;
            self.nextButton.frame.size.height = 44;
            self.nextButton.frame.origin.x = 16;
            if !self.endButton.isHidden{
                self.nextButton.frame.origin.x += 44 + 8;
            }
            break;
        }
    }
    
    @IBAction func onGoBeginRow(_ button: UIButton) {
        let section = 0;
        guard self.tableView.numberOfSections > 0 else{
            return;
        }
        
        let row = 0;
        guard self.tableView.numberOfRows(inSection: section) > 0 else{
            return;
        }
        
        let indexPath = IndexPath(row: row, section: section);
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: false);
    }
    
    @IBAction func onGoNextSection(_ button: UIButton) {
        let section = self.tableView(self.tableView, sectionForSectionIndexTitle: button.title(for: .normal) ?? "", at: 0);
        let indexPath = IndexPath(row: 0, section: section);
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: false);
    }
    
    @IBAction func onGoEndRow(_ button: UIButton) {
        let section = self.tableView.numberOfSections - 1;
        guard section >= 0 else{
            return;
        }
        
        let row = self.tableView.numberOfRows(inSection: section) - 1;
        guard row >= 0 else{
            return;
        }
        
        let indexPath = IndexPath(row: row, section: section);
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false);
    }
    
    func layoutBeginButton(_ button : UIButton){
        var heightMultiply : CGFloat = 0.0;
        switch self.groupingType{
        case .byName:
            heightMultiply = 1.5;
            break;
        case .byGroup:
            heightMultiply = 2.9;
            break;
        case .byArea:
            heightMultiply = 2.2;
            break;
        }
        
        button.frame.origin.y = self.tableView.contentOffset.y + button.bounds.height * heightMultiply;
    }
    
    func layoutEndButton(_ button : UIButton){
        button.frame.origin.y = self.view.bounds.maxY - button.bounds.height * 1.2;
    }
    
    var isDragging = false;
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isDragging = true;
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        isDragging = false;

        self.updateMoveButtons(scrollView);
    }
    
    var isScrollingToUp = false;
    var beforeContentOffset : CGFloat = -100;
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.layoutBeginButton(self.beginButton);
        self.layoutEndButton(self.endButton);
        self.layoutEndButton(self.nextButton);
        
        self.isScrollingToUp = self.tableView.contentOffset.y < self.beforeContentOffset;
        self.beforeContentOffset = self.tableView.contentOffset.y;

        self.updateMoveButtons(scrollView);
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
        
        switch self.groupingType{
            case .byName:
                self.filterByName(self.searchBar.text ?? "");
                break;
            case .byGroup:
                self.filterByGroup(self.searchBar.text ?? "");
                break;
            case .byArea:
                self.filterByArea(self.searchBar.text ?? "");
                break;
        }
        
        self.refresh();
    }

    @IBAction func onGroupingChanged(_ segment: UISegmentedControl) {
        switch self.groupingType{
            case .byName:
                self.filterByName(self.searchBar.text ?? "")
                break;
            case .byGroup:
                self.filterByGroup(self.searchBar.text ?? "");
                break;
            case .byArea:
                self.filterByArea(self.searchBar.text ?? "");
                break;
        }
        
        self.refresh(true);
    }
    
    func filterByName(_ keyword : String){
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
        
        self.groups = self.modelController.loadGroupsBySpell(self.isAscending, name: name, area: area);
    }
    
    func filterByGroup(_ keyword : String){
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

        self.groups = self.modelController.loadGroups(self.isAscending, name: name, area: area);
    }
    
    func filterByArea(_ keyword : String){
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
        
        
        self.groups = self.modelController.loadGroupsByArea(self.isAscending, areas: self.areas, name: name, area: area);
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
    
    func onGroupingSelected(_ picker: DownPicker){
        print("selected \(picker)");
        self.groupingButton.setTitle(self.groupingTypes[self.groupingType.rawValue], for: .normal);
    }

    @IBAction func onGrouping(_ sender: UIButton) {
        //self.groupingPicker.becomeFirstResponder();
    }
    
    let favOnImage = UIImage(named: "icon_favor_on")?.withRenderingMode(.alwaysTemplate);
    let favOffImage = UIImage(named: "icon_favor_off")?.withRenderingMode(.alwaysTemplate);
    
    // MARK: SwipeTableViewCellDelegate
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .left, !self.isAdsCell(indexPath) else{
            return nil;
        }
        
        var values : [SwipeAction] = [];
        
        let favAction = SwipeAction.init(style: .default, title: nil) { (act, indexPath) in
            guard let cell = self.tableView.cellForRow(at: indexPath) as? DAInfoTableViewCell else{
                return;
            }
            
            if let favor = self.modelController.findFavorite(cell.info!){
                self.modelController.removeFavorite(favor);
                act.image = self.favOffImage;
            }
            else{
                self.modelController.createFavorite(person: cell.info!);
                act.image = self.favOnImage;
            }
         
            self.modelController.saveChanges();
            //cell.hideSwipe(animated: true);
        }
        favAction.hidesWhenSelected = true;
        
        guard let cell = self.tableView.cellForRow(at: indexPath) as? DAInfoTableViewCell, let info = cell.info else{
            return nil;
        }
        
        if self.modelController.findFavorite(info) != nil{
            favAction.image = favOnImage;
        }else{
            favAction.image = favOffImage;
        }
        let shareAction = SwipeAction.init(style: .default, title: nil) { (act, indexPath) in
            guard let cell = self.tableView.cellForRow(at: indexPath) as? DAInfoTableViewCell else{
                return;
            }
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
        let value =  self.groups.count;
        
        return value.advanced(by: self.needAdsCell ? 1 : 0);
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        guard !self.isAdsSection(section) else{
            return 1;
        }
        
        var value = self.realGroup(section: section).persons.count;
        // #warning Incomplete implementation, return the number of rows
        switch self.groupingType{
        case .byName:
            return value;
        case .byGroup:
            if !(self.groupExpanding[self.realGroup(section: section).id] ?? true){
                value = 0;
            }
            break;
        default:
            break;
        }
        
        return value;
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell!;
        var infoCell : DAInfoTableViewCell?;
        
        guard !self.isAdsCell(indexPath) else{
            if let adsCell = tableView.dequeueReusableCell(withIdentifier: CellIDs.ads, for: indexPath) as? GADNativeTableViewCell{
                cell = adsCell;
                adsCell.rootViewController = self;
                adsCell.loadAds();
            }
            return cell;
        }
        //has only one section or this is large section or this is last section
        //and this is last row
        //self.allHasLessRows &&
        /*if self.needAds && (self.tableView.numberOfSections == 1 || self.tableView.numberOfRows(inSection: indexPath.section) >= minimumRowsForAds || self.tableView.numberOfSections - 1 == indexPath.section)
            && indexPath.row == self.tableView.numberOfRows(inSection: indexPath.section) - 1{
            cell = tableView.dequeueReusableCell(withIdentifier: DAInfoTableViewController.CellIDs.BannerCell, for: indexPath) as? DABannerTableViewCell;
        }else{*/
            infoCell = tableView.dequeueReusableCell(withIdentifier: DAInfoTableViewController.CellIDs.InfoCell, for: indexPath) as? DAInfoTableViewCell;
            cell = infoCell;
            //self.cellPreparingQueue.addOperation{
                var person : DAPersonInfo?;
        let group = self.realGroup(section: indexPath.section);
                person = group.persons[indexPath.row];
                //DispatchQueue.main.sync {
                    /*guard (self.tableView.indexPathsForVisibleRows ?? []).contains(indexPath) else{
                         return;
                    }*/

                    infoCell?.info = person;
                //}
                infoCell?.delegate = self;
            //}
        //}
        
        return cell;
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var values : [String] = [];
        //return ["abcde", "efghi"];
        switch self.groupingType{
        case .byName:
            values = self.groups.map({ (group) -> String in
                return group.name;
            });
//            if self.needAdsCell{
//                values.insert("", at: 0);
//            }
            break;
        case .byGroup:
            self.automaticallyAdjustsScrollViewInsets = true;
          break;
        default:
            self.automaticallyAdjustsScrollViewInsets = true;
            break;
        }
        
        return values.count > 1 ? values : [];
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        let value = self.groups.index(where: { (group) -> Bool in
            return group.name == title;
        }) ?? ( self.needAdsCell ? 1 : 0);
        
        return value;
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var value : String?;
        
        switch self.groupingType{
        case .byName:
            break;
        case .byGroup:
            break;
        case .byArea:
            value = self.groups[section].name;
            break;
        }
        
        return value;
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var cell : DAGroupTableViewCell?;
        
        guard !isAdsSection(section) else {
            return nil;
        }
        
        switch self.groupingType{
        case .byName:
            break;
        case .byGroup:
            cell = tableView.dequeueReusableCell(withIdentifier: DAInfoTableViewController.CellIDs.GroupCell) as? DAGroupTableViewCell;
            cell?.group = self.groups[safe: section.advanced(by: -1)];
            cell?.delegate = self;
            break;
        case .byArea:
            break;
        }
        
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var value : CGFloat = super.tableView(tableView, heightForHeaderInSection: section);
        
        guard !isAdsSection(section) else {
            return value;
        }
        
        switch self.groupingType{
        case .byName:
            break;
        case .byGroup:
            value = 56.0;
            break;
        case .byArea:
            value = tableView.sectionHeaderHeight;
            break;
        }
        
        return value;
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
    
    @objc func keyboardWillShow(notification: NSNotification){
        let keyboardHeight = notification.keyboardFrame.height;
        self.tableView.contentInset.bottom = keyboardHeight;
        print("keyboard will show");
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        //self.updateBottomContraint(false, notification: notification);
        self.tableView.contentInset.bottom = 0;
        print("keyboard will hide");
    }

    // MARK: UISearchBarDelegate
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //searchBar.sizeToFit();
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //searchBar.sizeToFit();
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("search keyword changed. keyword[\(searchText)]");
        switch self.groupingType{
            case .byName:
                self.filterByName(searchText);
                break;
            case .byGroup:
                self.filterByGroup(searchText);
                break;
            case .byArea:
                self.filterByArea(searchText);
                break;
        }
        
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
    
    // MARK: DAGroupTableViewCellDelegate
    func groupCellDidTap(_ cell: DAGroupTableViewCell) {
        self.groupExpanding[cell.group!.id] = !(self.groupExpanding[cell.group!.id] ?? true);
        
        //let section = self.groups.index(of: cell.group!) ?? 0;
        self.refresh(false);
        /*self.tableView.beginUpdates();
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
        if let personView = segue.destination as?DAPersonViewController, let cell = sender as? DAInfoTableViewCell{
            personView.info = cell.info;
        }
    }
}
