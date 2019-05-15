//
//  UITableViewController+ScrollButton.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 7. 20..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import UIKit
import LSExtensions

protocol LSScrollButtonDelegate : NSObjectProtocol{
    func titleForScrollButtonForSection(_ section : Int) -> String;
}

class LSScrollButton : NSObject{
    var topScrollButton : UIButton!;
    var bottomScrollButton : UIButton!;
    var nextSectionButton : UIButton!;
    var tableController : UITableViewController;
    
    var isDragging = false;
    var isScrollingToUp = false;

    var delegate : LSScrollButtonDelegate?;
    
    init(_ tableController : UITableViewController) {
        self.tableController = tableController;
        super.init();
        self.createButtons();
    }
    
    private func createButtons(){
        self.topScrollButton = UIButton();
        tableController.view.addSubview(self.topScrollButton);
        self.topScrollButton.backgroundColor = "#78909c".toUIColor();
        self.topScrollButton.setImage(UIImage(named: "icon_up.png"), for: .normal);
        self.topScrollButton.widthAnchor.constraint(equalToConstant: 44).isActive = true;
        self.topScrollButton.heightAnchor.constraint(equalToConstant: 44).isActive = true;
        self.topScrollButton.frame.size = CGSize(width: 44, height: 44);
        self.topScrollButton.frame.origin.x = 16;
        self.topScrollButton.layer.cornerRadius = 5.0;
        self.topScrollButton.addTarget(self, action: #selector(self.onGoFirstRow(_:)), for: .touchUpInside);
        self.layoutBeginButton(self.topScrollButton);
        self.topScrollButton.isHidden = true;
        
        self.bottomScrollButton = UIButton();
        tableController.view.addSubview(self.bottomScrollButton);
        self.bottomScrollButton.backgroundColor = "#78909c".toUIColor();
        self.bottomScrollButton.setImage(UIImage(named: "icon_down.png"), for: .normal);
        self.bottomScrollButton.widthAnchor.constraint(equalToConstant: 44).isActive = true;
        self.bottomScrollButton.heightAnchor.constraint(equalToConstant: 44).isActive = true;
        self.bottomScrollButton.frame.size = CGSize(width: 44, height: 44);
        self.bottomScrollButton.frame.origin.x = 16;
        
        self.bottomScrollButton.leadingAnchor.constraint(equalTo: tableController.tableView.leadingAnchor, constant: 16).isActive = true;
        self.bottomScrollButton.layer.cornerRadius = 5.0;
        self.bottomScrollButton.addTarget(self, action: #selector(self.onGoEndRow(_:)), for: .touchUpInside);
        self.layoutEndButton(self.bottomScrollButton);
        
        self.nextSectionButton = UIButton();
        tableController.view.addSubview(self.nextSectionButton);
        self.nextSectionButton.backgroundColor = "#78909c".toUIColor();
        self.nextSectionButton.setImage(UIImage(named: "icon_down.png"), for: .normal);
        self.nextSectionButton.setTitle("ㄱ", for: .normal)
        self.nextSectionButton.widthAnchor.constraint(equalToConstant: 44 * 2).isActive = true;
        self.nextSectionButton.heightAnchor.constraint(equalToConstant: 44).isActive = true;
        self.nextSectionButton.frame.size = CGSize(width: 44, height: 44);
        self.nextSectionButton.frame.origin.x = 16 + 44 + 8;
        
        self.nextSectionButton.leadingAnchor.constraint(equalTo: tableController.tableView.leadingAnchor, constant: 16 + 44 + 8).isActive = true;
        self.nextSectionButton.layer.cornerRadius = 5.0;
        self.nextSectionButton.addTarget(self, action: #selector(self.onGoNextSection(_:)), for: .touchUpInside);
        self.layoutEndButton(self.nextSectionButton);
    }
    
    //MARK: handle top button
    @IBAction func onGoFirstRow(_ button: UIButton) {
        //self._onSendMessage(allowAll: false);
        let section = 0;
        guard tableController.tableView.numberOfSections > 0 else{
            return;
        }
        
        let row = 0;
        guard tableController.tableView.numberOfRows(inSection: section) > 0 else{
            return;
        }
        
        let indexPath = IndexPath(row: row, section: section);
        self.tableController.tableView.scrollToRow(at: indexPath, at: .top, animated: false);
    }
    
    func layoutBeginButton(){
        self.layoutBeginButton(self.topScrollButton);
    }
    
    func layoutBeginButton(_ button : UIButton){
        let heightMultiply : CGFloat = 2.9;
        
        button.frame.origin.y = self.tableController.tableView.contentOffset.y + button.bounds.height * heightMultiply;
    }
    
    //MARK: handle bottom button
    @IBAction func onGoEndRow(_ button: UIButton) {
        let section = self.tableController.tableView.numberOfSections - 1;
        guard section >= 0 else{
            return;
        }
        
        let row = self.tableController.tableView.numberOfRows(inSection: section) - 1;
        guard row >= 0 else{
            return;
        }
        
        let indexPath = IndexPath(row: row, section: section);
        self.tableController.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false);
    }
    
    func layoutEndButton(){
        self.layoutEndButton(self.nextSectionButton);
        self.layoutEndButton(self.bottomScrollButton);
    }
    
    func layoutEndButton(_ button : UIButton){
        button.frame.origin.y = self.tableController.view.bounds.maxY - button.bounds.height * 1.2;
    }
    
    func updateMoveButtons(_ scrollView : UIScrollView){
        self.updateBeginButton(scrollView);
        self.updateEndButton(scrollView);
        self.updateNextButton();
    }
    
    func updateBeginButton(_ scrollView : UIScrollView){
        self.topScrollButton.isHidden = true;
        if self.tableController.tableView.contentOffset.y > scrollView.height * 2{
            self.topScrollButton.isHidden = (false || self.isDragging) && self.isScrollingToUp;
        }
    }
    
    func updateEndButton(_ scrollView : UIScrollView){
        self.bottomScrollButton.isHidden = true;
        if scrollView.contentSize.height - self.tableController.tableView.contentOffset.y > scrollView.height * 2{
            self.bottomScrollButton.isHidden = (false || self.isDragging) && !self.isScrollingToUp;
        }
    }
    
    func updateNextButton(){
        let maxSection = self.tableController.tableView.numberOfSections - 1;
        var lastIndexPath = self.tableController.tableView.indexPathsForVisibleRows?.last;
        
        self.nextSectionButton.isHidden = (false || self.isDragging) && !self.isScrollingToUp;
        guard lastIndexPath != nil else{
            self.nextSectionButton.isHidden = true;
            return;
        }
        
        guard maxSection > lastIndexPath!.section else{
            self.nextSectionButton.isHidden = true;
            return;
        }
        
        let nextSection = lastIndexPath!.section + 1;
        
        self.nextSectionButton.setTitle(self.delegate?.titleForScrollButtonForSection(nextSection), for: .normal);
        self.nextSectionButton.sizeToFit();
        //self.nextButton.widthAnchor.constraint(equalToConstant:  + 8).isActive = true;
        self.nextSectionButton.frame.size.width += 16;
        self.nextSectionButton.frame.size.height = 44;
        self.nextSectionButton.frame.origin.x = 16;
        if !self.bottomScrollButton.isHidden{
            self.nextSectionButton.frame.origin.x += 44 + 8;
        }
    }
    
    @IBAction func onGoNextSection(_ button: UIButton) {
        let section = self.tableController.tableView(self.tableController.tableView, sectionForSectionIndexTitle: button.title(for: .normal) ?? "", at: 0);
        let indexPath = IndexPath(row: 0, section: section);
        self.tableController.tableView.scrollToRow(at: indexPath, at: .top, animated: false);
        //self.updateNextButton();
    }
}
