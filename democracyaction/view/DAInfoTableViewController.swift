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

class DAInfoTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating, SwipeTableViewCellDelegate, DAGroupTableViewCellDelegate {
    class CellIDs{
        static let InfoCell = "DAInfoTableViewCell";
        static let BannerCell = "DABannerTableViewCell";
        static let GroupCell = "DAGroupTableViewCell";
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
        return DAModelController.Default;
    }
    
    var searchController : UISearchController!;
    //var searchContainer : UISearchContainerViewController!;
    var searchBar : UISearchBar{
        get{
            return self.searchController.searchBar;
        }
    };
    
    // = URL(string: "kakaolink://test?name=손혜원&area=호호".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? "")
    static var startingQuery : URL?{
        didSet{
            let tabs = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController;
            guard tabs != nil else{
                return;
            }
            
            if let nav = tabs?.selectedViewController as? UINavigationController{
                if let infoTable = nav.viewControllers.first as? DAInfoTableViewController{
                    if infoTable.isViewLoaded{
                        infoTable.searchByLaunchQuery();
                    }
                    //infoTable.presentingViewController
                }else if (tabs?.viewControllers?.count ?? 0) > 0{
                    tabs?.selectedIndex = 0;
                }
            }
        }
    }
    
    enum GroupingType : Int{
        case byName = 0
        case byGroup = 1
        case byArea = 2
    }
    
    //var groupingType = GroupingType.byName;
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
    
    //var firstWords = Character.koreanChoSeongs;
    //var groupsBySpell : [DAExcelGroupInfo] = [];
    //var groupsBySpell : [DAPersonGroup] = [];
    var groups : [DAPersonGroup] = [];
    var groupExpanding : [Int:Bool] = [:];
    
    var areas = ["서울", "경남", "경북", "제주", "비례대표",  "충남", "충북", "대구", "강원", "광주", "대전", "경기", "부산", "전북", "인천" , "전남", "세종", "울산"];
    //var filteredGroupsBySpell : [DAExcelGroupInfo] = [];
    //var groupingPicker : UIDownPicker!;
    //var filteredGroups : [DAExcelGroupInfo] = [];
    //var filteredGroups : [DAPersonGroupInfo] = [];
    var isAscending = true;
    var cellPreparingQueue = OperationQueue();
    
    var beginButton : UIButton!;
    var endButton : UIButton!;
    var beforeButton : UIButton!;
    var nextButton : UIButton!;
    
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
                value = value && self.groups[section].persons.count <= self.minimumRowsForAds;
            }
            
            return value;
        }
    }
    
    @IBOutlet weak var groupingButton: UIButton!
    @IBOutlet weak var groupingSegment: UISegmentedControl!
    @IBOutlet weak var sortButton: UIBarButtonItem!
    
    override func viewWillAppear(_ animated: Bool) {
        self.searchByLaunchQuery();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if DAInfoTableViewController._shared == nil{
            DAInfoTableViewController._shared = self;
        }
        //DownPicker
        /*
         UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneClicked:)];
         
         UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelClicked:)];
         */
        
        /*self.groupingPicker = UIDownPicker(data: groupingTypes);
        self.groupingPicker.downPicker.setToolbarDoneButtonText("완료");
        self.groupingPicker.downPicker.setToolbarCancelButtonText("취소");
        self.groupingPicker.downPicker.selectedIndex = self.groupingType.rawValue;
        self.groupingButton.setTitle(self.groupingPicker.text, for: .normal);
        self.groupingPicker.downPicker.addTarget(self, action: #selector(onGroupingSelected(_:)), for: .valueChanged);
        self.view.addSubview(self.groupingPicker);*/
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        //developer mode - upgrade database
        //load groups & persons from excel
        /*if DADefaults.DataVersion.isEmpty{
            //&& DAExcelController.shared.needToUpdate{
            //sync groups and persons to database
            DAModelController.Default.sync(DAExcelController.shared);
            self.groups = self.modelController.loadGroupsBySpell(self.isAscending);
            self.showNotice();
        }else{*/
            //var hub = MBProgressHUD.showAdded(to: self.view, animated: true);
            //hub.mode = .indeterminate;
            //hub.dimBackground = true;
            //hub.label.text = "데이터 업데이트 중";
            var hub : MBProgressHUD?;
            DAUpdateManger.shared.update(progress: { (state, error) in
                DispatchQueue.main.syncOrNot{
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
                    }
                    return;
                }
                
                DispatchQueue.main.async{
                    MBProgressHUD.hide(for: self.view, animated: true);
                    self.searchBar(self.searchBar, textDidChange: self.searchBar.text ?? "");
                    self.blockInterface(block: false);
                    self.showNotice();
                }
            })
        //}
        
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
        //self.endButton.frame.origin.x = self.view.frame.maxX - self.endButton.frame.width - 16;
        //self.endButton.frame.origin.y = self.view.frame.maxY - self.endButton.frame.width - 8;
        //self.endButton.trailingAnchor.constraint(equalTo: self.tableView.trailingAnchor, constant: -16).isActive = true;
        self.endButton.leadingAnchor.constraint(equalTo: self.tableView.leadingAnchor, constant: 16).isActive = true;
        //self.endButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -16).isActive = true;
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
        //self.endButton.frame.origin.x = self.view.frame.maxX - self.endButton.frame.width - 16;
        //self.endButton.frame.origin.y = self.view.frame.maxY - self.endButton.frame.width - 8;
        //self.endButton.trailingAnchor.constraint(equalTo: self.tableView.trailingAnchor, constant: -16).isActive = true;
        self.nextButton.leadingAnchor.constraint(equalTo: self.tableView.leadingAnchor, constant: 16 + 44 + 8).isActive = true;
        //self.endButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -16).isActive = true;
        self.nextButton.layer.cornerRadius = 5.0;
        self.nextButton.addTarget(self, action: #selector(self.onGoNextSection(_:)), for: .touchUpInside);
        self.layoutEndButton(self.nextButton);
        
        self.needAds = GADInterstialManager.shared?.canShow ?? true;

        /*var congresses = DAExcelController.Default.loadCongresses();
        for congress in congresses{
            print("congress \(congress)");
        }*/
        
        //Notice
        //if DADefaults.LastNotice < "2017-06-18".toDate("yyyy-MM-dd")!{
        
        //download from google
        /*var googleQuery = GTLRDriveQuery_FilesExport.queryForMedia(withFileId: "0B05rDBrnJN-ua2ZNM1NLb0stRDQ", mimeType: "text/plain");
        var googleService = GTLRDriveService();
        googleService.executeQuery(googleQuery) { (ticket, data, error) in
            guard error == nil else{
                print("google drive error[\(error)]");
                return;
            }
            
            print("download google file. data[\(data)]");
        }*/
        
        /*var googleQuery = GTLRDriveQuery_FilesGet.queryForMedia(withFileId: "0B05rDBrnJN-ua2ZNM1NLb0stRDQ");
            //.query(withFileId: "0B05rDBrnJN-ua2ZNM1NLb0stRDQ");
        var googleService = GTLRDriveService();
        
        let googleRequest = googleService.request(for: googleQuery);
        var googleFetcher = googleService.fetcherService.fetcher(with: googleRequest as URLRequest);
        googleFetcher.beginFetch { (data, error) in
            guard error == nil else{
                print("google drive error[\(error)]");
                return;
            }
            
            print("download google file. data[\(data?.count)]");
        }*/
        //var googleRequest = googleService.;
        
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
            let noticeView : DANoticeViewController! = self.storyboard?.instantiateViewController(withIdentifier: "DANoticeViewController") as? DANoticeViewController;
            //noticeView.modalPresentationStyle = .formSheet;
            noticeView.text = self.excelController.notice + "\n\n[\(self.excelController.version) 패치 내용]\n" + self.excelController.patch;
            self.present(noticeView, animated: true, completion: nil);
            //noticeView.popOver(inView: self, viewToShow: self.view, rectToShow: self.view.frame, permittedArrowDirections: .any, animated: true);
            //self.showAlert(title: "공지", msg: self.excelController.notice, actions: [UIAlertAction(title: "확인", style: .default, handler: nil)], style: .alert)
            
            DADefaults.LastNotice = Date();
            //\n\n'\(UIApplication.shared.displayName ?? "")'은 특정정당을 위해 개발한 어플이 아닙니다.
        }
    }
    
    func refresh(_ needToScrollTop : Bool = false){
        self.cellPreparingQueue.cancelAllOperations();
        self.tableView.reloadData();
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
        self.groupingSegment.selectedSegmentIndex = GroupingType.byGroup.rawValue;
        //self.groupingType = .byGroup;
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
        if self.tableView.contentOffset.y > scrollView.height * 2{
            self.beginButton.isHidden = (false || self.isDragging) && self.isScrollingToUp;
        }
    }
    
    func updateEndButton(_ scrollView : UIScrollView){
        self.endButton.isHidden = true;
        if scrollView.contentSize.height - self.tableView.contentOffset.y > scrollView.height * 2{
            self.endButton.isHidden = (false || self.isDragging) && !self.isScrollingToUp;
        }
    }
    
    func updateNextButton(){
        let maxSection = self.tableView.numberOfSections - 1;
        var lastIndexPath = self.tableView.indexPathsForVisibleRows?.last;
        
        self.nextButton.isHidden = (false || self.isDragging) && !self.isScrollingToUp;
        if !self.nextButton.isHidden{
            self.endButton.isHidden = false;
        }
        guard lastIndexPath != nil else{
            self.nextButton.isHidden = true;
            return;
        }
        
        guard maxSection > lastIndexPath!.section else{
            self.nextButton.isHidden = true;
            return;
        }

        let nextSection = lastIndexPath!.section + 1;
        
        self.nextButton.setTitle(self.groups[nextSection].name, for: .normal);
        switch self.groupingType{
        case .byName:
            self.nextButton.setTitle(self.groups[nextSection].name, for: .normal);
            //self.nextButton.widthAnchor.constraint(equalToConstant: 44 * 2).isActive = true;
            self.nextButton.frame.size.width = 44 + 8;
            break;
        case .byGroup, .byArea:
            self.nextButton.sizeToFit();
            //self.nextButton.widthAnchor.constraint(equalToConstant:  + 8).isActive = true;
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
        //self._onSendMessage(allowAll: false);
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
        //self.updateNextButton();
    }
    
    @IBAction func onGoEndRow(_ button: UIButton) {
        //self._onSendMessage(allowAll: false);
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
        //button.frame.origin.x = self.view.bounds.maxX - button.bounds.width - 16;
        //button.frame.origin.x = 16;
        //self.view.bounds.maxY -
        
        //[GroupingType]([.byGroup, .byArea]).contains(groupingType)
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
        //button.frame.origin.x = self.view.bounds.maxX - button.bounds.width - 16;
        //button.frame.origin.x = 16;
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
        //self.tableView.flashScrollIndicators();
        
        self.isScrollingToUp = self.tableView.contentOffset.y < self.beforeContentOffset;
        self.beforeContentOffset = self.tableView.contentOffset.y;
        
        //self.endButton.isHidden = true;
        //print("scroll content offset[\(scrollView.contentOffset)] size[\(scrollView.contentSize)] height[\(scrollView.height)] tableOffset[\(self.tableView.contentOffset)]");

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
                /*self.sortPersonsByName(groups: self.filteredGroups, needToOrderGroups: true);
                self.filteredGroups.sort(by: { (left, right) -> Bool in
                    //return (self.isAscending && left.persons.count < right.persons.count) || (!self.isAscending && left.persons.count > right.persons.count);
                    return left.persons.count > right.persons.count;
                })*/
                break;
            case .byArea:
                self.filterByArea(self.searchBar.text ?? "");
                break;
        }
        
        self.refresh();
    }

    @IBAction func onGroupingChanged(_ segment: UISegmentedControl) {
        //self.groupingType = GroupingType(rawValue: segment.selectedSegmentIndex)!;
        switch self.groupingType{
            case .byName:
                //self.tableView.style = UITableViewStyle.plain;
                self.filterByName(self.searchBar.text ?? "")
                break;
            case .byGroup:
                //self.tableView.style = UITableViewStyle.grouped;
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
        
        //self.filteredGroupsBySpell = self.sortPersonsByName(groups: self.filteredGroupsBySpell, needToOrderGroups: true);
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
        //var keywordChoSeongs = keyword.getKoreanChoSeongs(true);
        
        /*self.filteredGroups = DAExcelController.Default.groups.map({ (group) -> DAExcelGroupInfo in
            var newGroup = DAExcelGroupInfo();
            newGroup.id = group.value.id;
            newGroup.title = group.value.title;
            
            newGroup.persons = group.value.persons.filter({ (person) -> Bool in
                return keyword.isEmpty || person.name.hasPrefix(keyword) || person.name.getKoreanChoSeongs()?.hasPrefix(keyword) ?? false;
            });
            
            return newGroup;
        }).filter({ (group) -> Bool in
            return !group.persons.isEmpty;
        }).sorted(by: { (left, right) -> Bool in
            //return (!self.isAscending && left.persons.count < right.persons.count) || (self.isAscending && left.persons.count > right.persons.count);
            return left.persons.count > right.persons.count;
        });
        
        /*self.filteredGroups = DAExcelController.Default.groups.values.sorted(by: { (left, right) -> Bool in
            return left.id < right.id;
        });*/
        
        self.sortPersonsByName(groups: self.filteredGroups, needToOrderGroups: false);*/
    }
    
    func filterByArea(_ keyword : String){
        self.groups = self.modelController.loadGroupsByArea(self.isAscending, areas: self.areas, name: keyword);
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
//        guard self.groupingType != nil else{
//            self.typeButton.setTitle(picker.text, for: .normal);
//            self.typeButton.setImage(nil, for: .normal);
//            self.refreshInfos();
//            return;
//        }
        
        print("selected \(picker)");
        //self.typeButton.setImage(self.currentType?.image, for: .normal);
        //self.groupingType = GroupingType(rawValue: picker.selectedIndex)!;
        self.groupingButton.setTitle(self.groupingTypes[self.groupingType.rawValue], for: .normal);
        //self.refreshInfos();
    }

    @IBAction func onGrouping(_ sender: UIButton) {
        //self.groupingPicker.becomeFirstResponder();
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
            cell.hideSwipe(animated: true);
        }
        
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
        let value = self.groups.count;
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
        var value = self.groups[section].persons.count;
        // #warning Incomplete implementation, return the number of rows
        switch self.groupingType{
        case .byName:
            //var key = self.groupsBySpell.keys.sorted()[section];
            //var group = self.filteredGroupsBySpell[section]
            //value = group.persons.count;
            break;
        case .byGroup:
            //var group = self.filteredGroups[section];
            //value = self.filteredGroups[section].persons.count;
            if !(self.groupExpanding[self.groups[section].id] ?? true){
                value = 0;
            }
            break;
        default:
            break;
        }
        
        return value;
        //self.allHasLessRows &&
        //return value + (self.needAds && (self.tableView.numberOfSections == 1 || value >= self.minimumRowsForAds || (self.tableView.numberOfSections - 1 == section)) ? 1 : 0);
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell?;
        var infoCell : DAInfoTableViewCell?;
        
        /*switch self.groupingType{
        case .byName:
            var group = self.groups[indexPath.section]
            person = group.persons[indexPath.row];
            break;
        case .byGroup:
            var group = self.filteredGroups[indexPath.section];
            person = group.persons[indexPath.row];
            break;
        }*/
        //var person = self.excelController.persons[indexPath.row];
        
        /*if person != nil{
            DAExcelController.Default.loadCongress(person!);
        }*/
        
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
                let group = self.groups[indexPath.section];
                person = group.persons[indexPath.row];
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
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var values : [String] = [];
        //return ["abcde", "efghi"];
        switch self.groupingType{
        case .byName:
            values = self.groups.map({ (group) -> String in
                return group.name;
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
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        let value = self.groups.index(where: { (group) -> Bool in
            return group.name == title;
        }) ?? 0;
        
        /*switch self.groupingType{
        case .byName:
            value = self.filteredGroupsBySpell.index(where: { (group) -> Bool in
                return group.title == title;
            }) ?? 0;
            break;
        case .byGroup:
            value = self.filteredGroups.index(where: { (group) -> Bool in
                return group.title == title;
            }) ?? 0;
            break;
        }*/
        
        return value;
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var value : String?;
        
        switch self.groupingType{
        case .byName:
            //value = Character.koreanChoSeongs.index(of: title) ?? 0;
            break;
        case .byGroup:
            break;
        case .byArea:
            value = self.groups[section].name;
            //            for (i, group) in self.filteredGroups.enumerated(){
            //                if title == group.title{
            //                    value = i;
            //                    break;
            //                }
            //            }
            break;
        }
        
        return value;
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var cell : DAGroupTableViewCell?;
        
        switch self.groupingType{
        case .byName:
            //value = Character.koreanChoSeongs.index(of: title) ?? 0;
            break;
        case .byGroup:
            cell = tableView.dequeueReusableCell(withIdentifier: DAInfoTableViewController.CellIDs.GroupCell) as? DAGroupTableViewCell;
            /*if cell?.group === self.groups[section]{
                cell = nil;
            }*/
            cell?.group = self.groups[section];
            cell?.delegate = self;
            //            for (i, group) in self.filteredGroups.enumerated(){
            //                if title == group.title{
            //                    value = i;
            //                    break;
            //                }
            //            }
            break;
        case .byArea:
            break;
        }
        
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var value : CGFloat = super.tableView(tableView, heightForHeaderInSection: section);
        
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
