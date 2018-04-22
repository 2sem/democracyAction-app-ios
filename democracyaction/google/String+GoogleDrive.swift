//
//  String+GoogleDrive.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 7. 27..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import UIKit

extension String{
    func downloadSharedGoogle(destinationUrl url : URL?, completion: ((Data?, Error?) -> Void)?){
        //0B05rDBrnJN-ua2ZNM1NLb0stRDQ
        let urlRequest = URL(string: "https://drive.google.com/uc?id=\(self)&export=download");
        DispatchQueue.main.syncOrNot {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true;
        }
        URLSession.shared.dataTask(with: urlRequest!) { (data, res, error) in
            guard error == nil else{
                print("google drive download error[\(error.debugDescription)]");
                completion?(nil, error);
                DispatchQueue.main.syncOrNot {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false;
                }
                return;
            }
            
            if url != nil{
                do{
                    try data?.write(to: url!, options: NSData.WritingOptions.atomicWrite);
                    DispatchQueue.main.syncOrNot {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false;
                    }
                    completion?(data, nil);
                    print("download google drive file. res[\(res?.description ?? "")]");
                }catch let writingError{
                    DispatchQueue.main.syncOrNot {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false;
                    }
                    completion?(data, writingError);
                }
            }else{
                DispatchQueue.main.syncOrNot {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false;
                }
                completion?(data, nil);
            }
        }.resume();
        
        /*URLSession.shared.downloadTask(with: urlRequest!) { (url, res, error) in
            guard error == nil else{
                print("google drive download error[\(error)]");
                return;
            }
            print("download google drive file. res[\(res)]");
            
            do{
                var data = try Data(contentsOf: res!.url!);
                print("google data - \(data)");
            }catch{
                
            }
        }.resume();*/
    }
}
