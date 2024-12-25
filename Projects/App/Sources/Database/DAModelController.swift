//
//  DAModelController.swift
//  democracyaction
//
//  Created by 영준 이 on 2017. 6. 24..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import CoreData

class DAModelController : NSObject{
    struct EntityNames{
        static let DAGroupInfo = "DAGroupInfo";
        static let DAPersonInfo = "DAPersonInfo";
        static let DAPhoneInfo = "DAPhoneInfo";
        static let DAMessageToolInfo = "DAMessageToolInfo";
        static let DAWebInfo = "DAWebInfo";
        
        static let DAEventGroupInfo = "DAEventGroupInfo";
        static let DAEventInfo = "DAEventInfo";
        static let DAEventPersonInfo = "DAEventPersonInfo";
        
        static let DAFavoriteInfo = "DAFavoriteInfo";
    }
    
    static let ModelName = "DAModel"
    
    static let FileName = "democracyaction";
    
    lazy var storeUrl: URL! = {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last?
            .appendingPathComponent(Self.FileName)
            .appendingPathExtension("sqlite")
    }()
    
    lazy var modelUrl: URL! = {
        Bundle.main.url(forResource: Self.ModelName, withExtension: "momd")
    }()
    
    lazy var model = {
        NSManagedObjectModel(contentsOf: modelUrl)
    }()
    
    internal static let dispatchGroupForInit = DispatchGroup();
    //    var SingletonQ = DispatchQueue(label: "DAModelController.shared");
    private static var _instance = DAModelController();
    static var shared : DAModelController{
        get{
            //var timeout = DispatchTime.now() + DispatchTimeInterval.seconds(3);
            //print("enter \(self) instance - \(self) - \(Thread.current)");
            let value = _instance;
            //            value.waitInit();
            //print("wait \(self) instance - \(self) - \(Thread.current)");
            self.dispatchGroupForInit.wait();
            //print("exit \(self) instance - \(self) - \(Thread.current)");
            
            return value;
        }
    }
    
    lazy var context : NSManagedObjectContext = {
        NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    }()
    
    internal override init(){
        super.init()
        
        //load model from model file
        guard let model else {
            fatalError("Can not load Model from File");
        }
        
        if isMigrationNeeded {
            // TODO: migrate
        }
        
        //create store controller??
        let psc = NSPersistentStoreCoordinator(managedObjectModel: model);
        
        //create data context
//        self.context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType);
        //set store controller??
        self.context.persistentStoreCoordinator = psc;
        
        DispatchQueue.global(qos: .background).async(group: DAModelController.dispatchGroupForInit) {
            print("begin init DAModelController");
            
            do {
                //set store type?
                try psc.addPersistentStore(ofType: NSSQLiteStoreType, 
                                           configurationName: nil,
                                           at: self.storeUrl,
                                           options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]);
            } catch {
                
            }
            
            print("end init RSModelController");
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var isMigrationNeeded : Bool {
        guard let metadata = try? NSPersistentStoreCoordinator.metadataForPersistentStore(
            ofType: NSSQLiteStoreType,
            at: storeUrl,
            options: nil
        ) else {
            return false
        }
        
        let isConfiguration = model?.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata) ?? false
        
        return !isConfiguration
    }
    
    func waitInit(){
        //        dispatchPrecondition(condition: .notOnQueue(<#T##DispatchQueue#>))
        while self.context.persistentStoreCoordinator?.persistentStores.isEmpty ?? false{
            sleep(1);
        }
    }
    
    func reset(){
        self.context.reset();
    }
    
    var isSaved : Bool{
        return !self.context.hasChanges;
    }
    
    func saveChanges(){
        do{
            try self.context.save();
            print("save data model");
        } catch {
            fatalError("Save failed Error(\(error))");
        }
    }
    
    /// MARK : support transaction
    func beginTransaction(transactionName name : String){
        if self.context.undoManager == nil {
            self.context.undoManager = UndoManager();
        }
        
        print("begin transaction. name[\(name)] context[\(self.context)]");
        self.context.undoManager?.beginUndoGrouping();
        self.context.undoManager?.setActionName(name);
    }
    
    func endTransaction(){
        print("end transaction. name[\(self.context.undoManager?.undoActionName ?? "")] context[\(self.context.description)]");
        self.context.undoManager?.endUndoGrouping();
    }
    
    func undo(){
        print("undo. name[\(self.context.undoManager?.undoActionName ?? "")] context[\(self.context.description)]");
        self.context.undoManager?.undo();
    }
    
    func rollback(){
        print("rollback. context[\(self.context)]");
        self.context.rollback();
    }
}

