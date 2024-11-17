//
//  LSRemoteConfig.swift
//  democracyaction
//
//  Created by 영준 이 on 28/08/2019.
//  Copyright © 2019 leesam. All rights reserved.
//

import UIKit
import FirebaseRemoteConfig

class LSRemoteConfig: NSObject {
    class ConfigNames{
        #if DEBUG
        static let maxVersion = "test_max_version";
        static let minVersion = "test_min_version";
        static let dataVersion = "test_data_version";
        #else
        static let maxVersion = "max_version";
        static let minVersion = "min_version";
        static let dataVersion = "data_version";
        #endif
        
    }
    
    static let shared = LSRemoteConfig();
    
    var isServerAlive : Bool = true;
    lazy var firebaseConfig : RemoteConfig = {
        var value = RemoteConfig.remoteConfig();
        let settings = RemoteConfigSettings();
        settings.minimumFetchInterval = 0;
        value.configSettings = settings;
        
        return value;
    }()
    
    var minVersion : String?{
        //#if DEBUG
        //    return "1.3.17";
        //#endif
        return self.firebaseConfig.configValue(forKey: ConfigNames.minVersion).stringValue;
    }
    
    var maxVersion : String?{
        return self.firebaseConfig.configValue(forKey: ConfigNames.maxVersion).stringValue;
    }
    
    var dataVersion : String?{
        return self.firebaseConfig.configValue(forKey: ConfigNames.dataVersion).stringValue;
    }
    
    override init() {
        super.init();

        self.firebaseConfig.setDefaults([ConfigNames.minVersion : UIApplication.shared.version as NSObject,
        ConfigNames.maxVersion : UIApplication.shared.version as NSObject,
        ConfigNames.dataVersion : "9.9.9" as NSObject]);
    }
    
    func fetch(_ timeout: TimeInterval = 3.0, completion: @escaping (LSRemoteConfig, Error?) -> Void){
        //SWToast.activity("버전 정보 확인 중");
        /*self.firebaseConfig.fetchAndActivate { [unowned self](status, error) in
         SWToast.hideActivity();
         completion(self, error);
         }*/
        self.firebaseConfig.fetch(withExpirationDuration: timeout) { [weak self](status, error_fetch) in
            guard let rcerror = error_fetch else{
                self?.firebaseConfig.activate(completion: { [weak self](result, error) in
                    guard let self = self else{
                        return;
                    }
                    //SWToast.hideActivity();
                    completion(self, error);
                })
                return;
            }
            
            guard let self = self else{
                return;
            }
            
            //SWToast.hideActivity();
            completion(self, rcerror);
        }
    }
}
