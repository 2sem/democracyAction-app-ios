//
//  DAUpdateManager.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 7. 27..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class DAUpdateManger{
    static let shared = DAUpdateManger();
    
    //private var dataUrl : URL?;
    let plistName = "300korea";//
    lazy var plist : [String : String] = {
        guard let plist = Bundle.main.path(forResource: self.plistName, ofType: "plist") else{
            preconditionFailure("Please create plist file named of \(plistName). file[\(self.plistName).plist]");
        }
        
        guard let dict = NSDictionary.init(contentsOfFile: plist) as? [String : String] else{
            preconditionFailure("Please \(self.plistName).plist is not Property List.");
        }
        
        return dict;
    }()
    
    private lazy var appServerUrl : URL = {
        let pname = "Server URL";
        guard let value = self.plist[pname] else{
            preconditionFailure("Please add \(pname) into \(self.plistName).plist.");
        }
        
        return URL(string: value)!;
    }()
    
    /*private var infoFileID : String{
        let pname = "Info File ID";
        guard let value = self.plist[pname] else{
            preconditionFailure("Please add \(pname) into \(self.plistName).plist.");
        }
        
        return value;
    }
    
    private var verFileID : String{
        let pname = "Version File ID";
        guard let value = self.plist[pname] else{
            preconditionFailure("Please add \(pname) into \(self.plistName).plist.");
        }
        
        return value;
    }*/
    
    private var dataFileID : String{
        let pname = "Data File ID";
        guard let value = self.plist[pname] else{
            preconditionFailure("Please add \(pname) into \(self.plistName).plist.");
        }
        
        return value;
    }
    
    enum UpdateState : String{
        case checkingVer = "앱 버전 확인 중";
        case checkingInfo = "데이터 버전 확인 중";
        case upToDate = "이미 최신 데이터 사용 중";
        case downloadingData = "최신 데이터 다운로드 중";
        case updatingData = "데이터 업데이트 중";
        case completed = "업데이트 완료";
    }
    
    var state : UpdateState = .checkingInfo;
    let updateQueue = DispatchQueue.init(label: "update", qos: .background);
    func update(progress : ((UpdateState, Error?) -> Void)?, completion: @escaping (Bool) -> Void){
        let updateProgress = {(state: UpdateState, error: Error?) -> Void in
            self.state = state;
            progress?(self.state, error);
        }
        updateProgress(.checkingVer, nil);
        Alamofire.request(self.appServerUrl.appendingPathComponent("versions")).responseJSON { [weak self](response) in
            guard let data = response.data else{
                print("getting versions has been failed. error[\(response.error.debugDescription)]");
                if DADefaults.DataVersion.isEmpty{
                    updateProgress(.updatingData, nil);
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        DAModelController.shared.sync(DAExcelController.shared);
                        updateProgress(.completed, nil);
                        completion(true);
                    }
                }else{
                    progress?(self!.state, response.error);
                    completion(false);
                }
                return;
            }
            
            do{
                let res = try JSONDecoder().decode(DAAppVersionResponse.self, from: data);
                print("app server response - \(res)");
                let newRequiredVersion = res.requiredVersion;
                let newDataVersion = res.dataVersion;

                guard UIApplication.shared.version >= newRequiredVersion
                    else{
                        //already last update
                        UIApplication.shared.windows.first?.rootViewController?.showAlert(title: "앱 업데이트", msg: "신규 기능 사용을 위해 앱 업데이트가 필요합니다.", actions: [UIAlertAction(title: "업데이트", style: .default, handler: { (act) in
                            //self.updateData(progress: progress, completion: completion);
                            UIApplication.shared.openItunes();
                            completion(false);
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                                assert(false, "updating");
                            })
                        }), UIAlertAction(title: "업데이트 안함", style: .cancel, handler: { (act) in
                            if DAExcelController.shared.version > newDataVersion{
                                self?.updateData(progress: progress, completion: completion);
                            }else{
                                updateProgress(.completed, nil);
                                completion(true);
                            }
                        })], style: .alert);
                        return;
                }
                
                //"1.0.9";
                guard DADefaults.DataVersion < newDataVersion
                    || DAExcelController.shared.version > DADefaults.DataVersion else{
                        //already last update
                        print("data is already up to date. version[\(newDataVersion)]");
                        updateProgress(.upToDate, nil);
                        completion(false);
                        return;
                }
                
                //self.dataUrl = URL(string: NSTemporaryDirectory())?.appendingPathComponent("democracyaction").appendingPathExtension("xlsx");
                if DAExcelController.shared.version >= newDataVersion
                    || (!DADefaults.DataVersion.isEmpty && DADefaults.DataVersion < DAExcelController.shared.version){
                    updateProgress(.updatingData, nil);
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        DAModelController.shared.sync(DAExcelController.shared);
                        updateProgress(.completed, nil);
                        completion(true);
                    }
                }else{
                    self?.updateData(progress: progress, completion: completion);
                }
            }catch let error{
                print("json parse error[\(error)]");
                completion(false);
            }
        }
    }
    
    func updateData(progress : ((UpdateState, Error?) -> Void)?, completion: @escaping (Bool) -> Void){
        let updateProgress = {(state: UpdateState, error: Error?) -> Void in
            self.state = state;
            progress?(self.state, error);
        }
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)  {
                DAModelController.shared.sync(excelController);
            }
            updateProgress(.completed, nil);
            completion(true);
        });
    }
}
