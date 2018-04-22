//
//  DAUpdateManager.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 7. 27..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import UIKit

class DAUpdateManger{
    static let shared = DAUpdateManger();
    //live
    private let infoFileID = "0B05rDBrnJN-ua2ZNM1NLb0stRDQ";
    private let dataFileID = "0B05rDBrnJN-uTHpmcFBUNlliYXM";
    private let verFileID = "1kOGTyfYoaQ2UsV0N4yK8MSX1Rb1E9JSl";
    //test
    //private let infoFileID = "0B05rDBrnJN-uc01nNldFQ0ZkR0E";
    //https://drive.google.com/open?id=0B05rDBrnJN-uc01nNldFQ0ZkR0E
    //private let dataFileID = "0B05rDBrnJN-uaG9zSVZyVlNGNTA";
    //https://drive.google.com/open?id=0B05rDBrnJN-uaG9zSVZyVlNGNTA
    //private let verFileID = "0B05rDBrnJN-uMTJ5VVJ4U2g5WEk";
    //https://drive.google.com/open?id=0B05rDBrnJN-uMTJ5VVJ4U2g5WEk
    
    //private var dataUrl : URL?;
    
    enum UpdateState : String{
        case checkingVer = "앱 버전 확인 중";
        case checkingInfo = "데이터 버전 확인 중";
        case upToDate = "이미 최신 데이터 사용 중";
        case downloadingData = "최신 데이터 다운로드 중";
        case updatingData = "데이터 업데이트 중";
        case completed = "업데이트 완료";
    }
    
    var state : UpdateState = .checkingInfo;
    
    func update(progress : ((UpdateState, Error?) -> Void)?, completion: @escaping (Bool) -> Void){
        let updateProgress = {(state: UpdateState, error: Error?) -> Void in
            self.state = state;
            progress?(self.state, error);
        }
        updateProgress(.checkingVer, nil);
        self.verFileID.downloadSharedGoogle(destinationUrl: nil) { (verData, verError) in
            guard verError == nil else{
                print("minimum version file download has been failed. error[\(verError.debugDescription)]");
                if DADefaults.DataVersion.isEmpty{
                    updateProgress(.updatingData, nil);
                    DispatchQueue.main.sync {
                        DAModelController.Default.sync(DAExcelController.shared);
                    }
                    updateProgress(.completed, nil);
                    completion(true);
                }else{
                    progress?(self.state, verError);
                    completion(false);
                }
                return;
            }
            
            let newVersion = String.init(data: verData!, encoding: String.Encoding.utf8) ?? "";
            //|| DAExcelController.shared.version > DADefaults.DataVersion
            guard UIApplication.shared.version >= newVersion
                else{
                    //already last update
                    UIApplication.shared.windows.first?.rootViewController?.showAlert(title: "앱 업데이트", msg: "신규 기능 사용을 위해 앱 업데이트가 필요합니다.", actions: [UIAlertAction(title: "업데이트", style: .default, handler: { (act) in
                            //self.updateData(progress: progress, completion: completion);
                        UIApplication.shared.openReview();
                        completion(false);
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                            assert(false, "updating");
                        })
                    }), UIAlertAction(title: "업데이트 안함", style: .cancel, handler: { (act) in
                        self.updateData(progress: progress, completion: completion);
                    })], style: .alert);
                    //print("data is already up to date. version[\(newVersion)]");
                    //updateProgress(.upToDate, verError);
                    //completion(false);
                    return;
            }
            
            self.updateData(progress: progress, completion: completion);
        }
    }
    func updateData(progress : ((UpdateState, Error?) -> Void)?, completion: @escaping (Bool) -> Void){
        let updateProgress = {(state: UpdateState, error: Error?) -> Void in
            self.state = state;
            progress?(self.state, error);
        }
        updateProgress(.checkingInfo, nil);
        self.infoFileID.downloadSharedGoogle(destinationUrl: nil) { (infoData, infoError) in
            guard infoError == nil else{
                //failed to download
                print("downloading info file download has been failed");
                
                if DADefaults.DataVersion.isEmpty{
                    updateProgress(.updatingData, nil);
                    DispatchQueue.main.sync {
                        DAModelController.Default.sync(DAExcelController.shared);
                    }
                    updateProgress(.completed, nil);
                    completion(true);
                }else{
                    progress?(self.state, infoError);
                    completion(false);
                }
                return;
            }
            
            //"1.0.9";
            let newVersion = String.init(data: infoData!, encoding: String.Encoding.utf8) ?? "";
            guard DADefaults.DataVersion < newVersion
                || DAExcelController.shared.version > DADefaults.DataVersion else{
                //already last update
                print("data is already up to date. version[\(newVersion)]");
                updateProgress(.upToDate, infoError);
                completion(false);
                return;
            }
            
            //self.dataUrl = URL(string: NSTemporaryDirectory())?.appendingPathComponent("democracyaction").appendingPathExtension("xlsx");
            if DAExcelController.shared.version > newVersion
                || (!DADefaults.DataVersion.isEmpty && DADefaults.DataVersion < DAExcelController.shared.version){
                updateProgress(.updatingData, nil);
                DispatchQueue.main.sync {
                    DAModelController.Default.sync(DAExcelController.shared);
                }
                updateProgress(.completed, nil);
                completion(true);
            }else{
                updateProgress(.downloadingData, nil);
                self.dataFileID.downloadSharedGoogle(destinationUrl: DAExcelController.localUrl, completion: { (fileData, dataError) in
                    guard dataError == nil else{
                        //failed to download
                        print("downloading data file download has been failed");
                        updateProgress(self.state, dataError);
                        completion(false);
                        return;
                    }
                    
                    DADefaults.DataDownloaded = true;
                    let excelController = DAExcelController(DAExcelController.localUrl!);
                    DAExcelController.shared = excelController
                    updateProgress(.updatingData, nil);
                    DispatchQueue.main.sync {
                        DAModelController.Default.sync(excelController);
                    }
                    updateProgress(.completed, nil);
                    completion(true);
                })
            }
        }
    }
}
