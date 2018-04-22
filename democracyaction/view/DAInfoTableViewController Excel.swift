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

class DAInfoTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {
    static let CellID = "DAInfoTableViewCell";

    var excelController : DAExcelController{
        return DAExcelController.Default;
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
    
    enum GroupingType : Int{
        case byName = 0
        case byGroup = 1
    }
    
    var groupingType = GroupingType.byName;
    var groupingTypes = ["이름별", "정당별"];
    
    //var firstWords = Character.koreanChoSeongs;
    //var groupsBySpell : [DAExcelGroupInfo] = [];
    //var groupsBySpell : [DAPersonGroup] = [];
    var groups : [DAPersonGroup] = [];
    //var filteredGroupsBySpell : [DAExcelGroupInfo] = [];
    //var groupingPicker : UIDownPicker!;
    //var filteredGroups : [DAExcelGroupInfo] = [];
    //var filteredGroups : [DAPersonGroupInfo] = [];
    var isAscending = true;
    
    var endButton : UIButton!;
    var nextButton : UIButton!;
    @IBOutlet weak var groupingButton: UIButton!
    @IBOutlet weak var groupingSegment: UISegmentedControl!
    @IBOutlet weak var sortButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\("ㄱ".characters.first?.hashValue)");
        
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
        //DAExcelController.Default.loadFromFlie();
        
        //sync groups and persons to database
        //DAModelController.Default.sync(DAExcelController.Default);
        
        //convert to database
        //self.groupsBySpell = DAExcelController.Default.groupsBySpell();
        self.groups = self.modelController.loadGroupsBySpell(spells: Character.koreanChoSeongs);
        //self.filteredGroupsBySpell = self.groupsBySpell;
        //firstWords = groupsBySpell.keys.sorted();
        
        self.searchController = UISearchController(searchResultsController: nil);
        self.searchController.searchResultsUpdater = self;
        self.searchBar.delegate = self;
        self.definesPresentationContext = true;
        self.tableView.tableHeaderView = self.searchController.searchBar;
        self.searchBar.placeholder = "검색할 이름 입력";
        self.searchBar.returnKeyType = .done;
        //self.searchBar.tintColor = Color.yellow;
        
        //self.searchContainer = UISearchContainerViewController(searchController: self.searchController);
        //self.searchBar = SearchBar()
        self.searchController.hidesNavigationBarDuringPresentation = false;
        self.searchController.dimsBackgroundDuringPresentation = false;
        //self.navigationItem.titleView = self.searchController.searchBar;
        //self.searchBar.scopeButtonTitles = ["이름","정당","지역"];
        self.searchBar.selectedScopeButtonIndex = 0;
        //self.searchBar.showsSearchResultsButton = true;
        //self.searchBar.showsScopeBar = true;
        self.searchBar.sizeToFit();
        
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
        
        /*var congresses = DAExcelController.Default.loadCongresses();
        for congress in congresses{
            print("congress \(congress)");
        }*/
        
        //Notice
        if DADefaults.LastNotice < "2017-06-18".toDate("yyyy-MM-dd")!{
            self.showAlert(title: "공지", msg: "이제는 직접민주주의로 참여하는 시대입니다.\n지역구 의원이 무슨일을 하는지 확인하고 잘하면 칭찬하고 못하면 비판하며 때로는 토론도 해보세요.", actions: [UIAlertAction(title: "확인", style: .default, handler: nil)], style: .alert);
            
            DADefaults.LastNotice = Date();
            //\n\n'\(UIApplication.shared.displayName ?? "")'은 특정정당을 위해 개발한 어플이 아닙니다.
        }
    }
    
    func refresh(_ needToScrollTop : Bool = false){
        self.tableView.reloadData();
        self.updateNextButton();
        if needToScrollTop && self.tableView.numberOfSections > 0 && self.tableView.numberOfRows(inSection: 0) > 0{
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false);
        }
    }
    
    func updateNextButton(){
        var maxSection = self.tableView.numberOfSections - 1;
        var lastIndexPath = self.tableView.indexPathsForVisibleRows?.last;
        
        self.nextButton.isHidden = false;
        guard lastIndexPath != nil else{
            self.nextButton.isHidden = true;
            return;
        }
        
        guard maxSection > lastIndexPath!.section else{
            self.nextButton.isHidden = true;
            return;
        }

        var nextSection = lastIndexPath!.section + 1;
        
        switch self.groupingType{
        case .byName:
            self.nextButton.setTitle(self.filteredGroupsBySpell[nextSection].title, for: .normal);
            //self.nextButton.widthAnchor.constraint(equalToConstant: 44 * 2).isActive = true;
            self.nextButton.frame.size.width = 44 + 8;
            break;
        case .byGroup:
            self.nextButton.setTitle(self.filteredGroups[nextSection].title, for: .normal);
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
    
    @IBAction func onGoNextSection(_ button: UIButton) {
        var section = self.tableView(self.tableView, sectionForSectionIndexTitle: button.title(for: .normal) ?? "", at: 0);
        var indexPath = IndexPath(row: 0, section: section);
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: false);
        //self.updateNextButton();
    }
    
    @IBAction func onGoEndRow(_ button: UIButton) {
        //self._onSendMessage(allowAll: false);
        var section = self.tableView.numberOfSections - 1;
        guard section >= 0 else{
            return;
        }
        
        var row = self.tableView.numberOfRows(inSection: section) - 1;
        guard row >= 0 else{
            return;
        }
        
        var indexPath = IndexPath(row: row, section: section);
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false);
    }
    
    func layoutEndButton(_ button : UIButton){
        //button.frame.origin.x = self.view.bounds.maxX - button.bounds.width - 16;
        //button.frame.origin.x = 16;
        button.frame.origin.y = self.view.bounds.maxY - button.bounds.height * 1.5;
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.layoutEndButton(self.endButton);
        self.layoutEndButton(self.nextButton);
        //self.tableView.flashScrollIndicators();
        
        self.endButton.isHidden = true;
        print("scroll content offset[\(scrollView.contentOffset)] size[\(scrollView.contentSize)] height[\(scrollView.height)] tableOffset[\(self.tableView.contentOffset)]");
        if scrollView.contentSize.height - self.tableView.contentOffset.y > scrollView.height * 2{
            self.endButton.isHidden = false;
        }
        
        self.updateNextButton();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                self.filteredGroupsBySpell = self.sortPersonsByName(groups: self.filteredGroupsBySpell, needToOrderGroups: true);
                break;
            case .byGroup:
                self.sortPersonsByName(groups: self.filteredGroups, needToOrderGroups: true);
                self.filteredGroups.sort(by: { (left, right) -> Bool in
                    //return (self.isAscending && left.persons.count < right.persons.count) || (!self.isAscending && left.persons.count > right.persons.count);
                    return left.persons.count > right.persons.count;
                })
                break;
        }
        
        self.refresh();
    }

    @IBAction func onGroupingChanged(_ segment: UISegmentedControl) {
        self.groupingType = GroupingType(rawValue: segment.selectedSegmentIndex)!;
        switch self.groupingType{
            case .byName:
                //self.tableView.style = UITableViewStyle.plain;
                self.filterByName(self.searchBar.text ?? "")
                break;
            case .byGroup:
                //self.tableView.style = UITableViewStyle.grouped;
                self.filterByGroup(self.searchBar.text ?? "");
                break;
        }
        
        self.refresh(true);
    }
    
    func filterByName(_ keyword : String){
        self.filteredGroupsBySpell = [];
        //var keywordChoSeongs = keyword.getKoreanChoSeongs(true);
        for group in self.groupsBySpell{
            var newGroup = DAExcelGroupInfo();
            newGroup.id = group.id;
            newGroup.title = group.title;
            
            newGroup.persons = group.persons.filter({ (person) -> Bool in
                return keyword.isEmpty || person.name.hasPrefix(keyword) || person.name.getKoreanChoSeongs()?.hasPrefix(keyword ?? "") ?? false;
            });
            
            guard !newGroup.persons.isEmpty else{
                continue;
            }
            
            self.filteredGroupsBySpell.append(newGroup);
        }
        
        self.filteredGroupsBySpell = self.sortPersonsByName(groups: self.filteredGroupsBySpell, needToOrderGroups: true);
    }
    
    func filterByGroup(_ keyword : String){
        self.filteredGroups = [];
        //var keywordChoSeongs = keyword.getKoreanChoSeongs(true);
        /*for group in self.groupsBySpell{
            var newGroup = DAExcelGroupInfo();
            newGroup.id = group.id;
            newGroup.title = group.title;
            
            newGroup.persons = group.persons.filter({ (person) -> Bool in
                return keyword.isEmpty || person.name.getKoreanChoSeongs()?.hasPrefix(keywordChoSeongs ?? "") ?? false;
            });
            
            guard !newGroup.persons.isEmpty else{
                continue;
            }
            
            self.filteredGroupsBySpell.append(newGroup);
        }*/
        
        self.filteredGroups = DAExcelController.Default.groups.map({ (group) -> DAExcelGroupInfo in
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
        
        self.sortPersonsByName(groups: self.filteredGroups, needToOrderGroups: false);
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
        self.groupingType = GroupingType(rawValue: picker.selectedIndex)!;
        self.groupingButton.setTitle(self.groupingTypes[self.groupingType.rawValue], for: .normal);
        //self.refreshInfos();
    }

    @IBAction func onGrouping(_ sender: UIButton) {
        //self.groupingPicker.becomeFirstResponder();
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        var value = groupsBySpell.count;
        // #warning Incomplete implementation, return the number of sections
        switch self.groupingType{
            case .byName:
                value = filteredGroupsBySpell.count;
                break;
            case .byGroup:
                value = filteredGroups.count
                break;
        }
        
        return value;
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var value = 0;
        // #warning Incomplete implementation, return the number of rows
        switch self.groupingType{
        case .byName:
            //var key = self.groupsBySpell.keys.sorted()[section];
            var group = self.filteredGroupsBySpell[section]
            value = group.persons.count;
            break;
        case .byGroup:
            var group = self.filteredGroups[section];
            value = self.filteredGroups[section].persons.count;
            break;
        }
        
        return value;
        //return self.excelController.persons.count;
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DAInfoTableViewController.CellID, for: indexPath) as? DAInfoTableViewCell;
        
        var person : DAExcelPersonInfo?;
        switch self.groupingType{
        case .byName:
            var group = self.filteredGroupsBySpell[indexPath.section]
            person = group.persons[indexPath.row];
            break;
        case .byGroup:
            var group = self.filteredGroups[indexPath.section];
            person = group.persons[indexPath.row];
            break;
        }
        //var person = self.excelController.persons[indexPath.row];
        
        if person != nil{
            DAExcelController.Default.loadCongress(person!);
        }
        cell?.info = person;
        // Configure the cell...

        return cell!;
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var values : [String] = [];
        //return ["abcde", "efghi"];
        switch self.groupingType{
        case .byName:
            for group in self.filteredGroupsBySpell{
                values.append(group.title);
            }
            //tableView.scrollIndicatorInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16);
            break;
        case .byGroup:
            self.automaticallyAdjustsScrollViewInsets = true;
          break;
        }
        
        return values.count > 1 ? values : [];
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        var value = 0;
        
        switch self.groupingType{
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
        }
        
        return value;
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var value : String?;
        
        switch self.groupingType{
        case .byName:
            //value = Character.koreanChoSeongs.index(of: title) ?? 0;
            break;
        case .byGroup:
            value = self.filteredGroups[section].title;
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
        }
        
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
