# Uncomment the next line to define a global platform for your project
 platform :ios, '10.0'

target 'democracyaction' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings!
  
  pod 'XlsxReaderWriter'
  pod 'DownPicker'
  pod 'Firebase/Messaging'
  pod 'Firebase/RemoteConfig'
  
  pod 'KakaoOpenSDK'
  
  # Add the pod for Firebase Crashlytics
  pod 'Firebase/Crashlytics'

  # Recommended: Add the Firebase pod for Google Analytics
  pod 'Firebase/Analytics'
  
  pod 'Material'
  pod 'FBSDKCoreKit'
  pod 'SwipeCellKit', '~> 2.5.1'
  pod 'MBProgressHUD'
  
  #pod 'JSQWebViewController'
  #pod 'JBWebViewController'
  pod 'LProgressWebViewController'
  
  pod 'CryptoSwift'
  #pod 'GoogleAPIClientForREST/Drive', '~> 1.2.1'
  pod 'LSExtensions' #, :path => '~/Projects/leesam/pods/LSExtensions/src/LSExtensions'
  pod 'GADManager' #, :path => '~/Projects/leesam/pods/GADManager/src/GADManager'
  pod 'Alamofire'
  #pod 'LSExtensions'
  pod 'SDWebImage'
  
  # Pods for democracyaction

    #script to do after install pod projects
    post_install do |installer|
        #find target name of "XlsxReaderWriter" from targets in Pods
        XlsxReaderWriter = installer.pods_project.targets.find{ |t| t.name == "XlsxReaderWriter" }
        #puts "capture #{XlsxReaderWriter}";
        #find target name of "XMLDictionary" from targets in Pods
        XMLDictionary = installer.pods_project.targets
            .find{ |t| t.name == "XMLDictionary" }
        #puts "capture #{XMLDictionary}";
        #find file reference for "XMLDictionary.h" of a Project "XMLDictionary"
        XMLDictionaryHeader = XMLDictionary.headers_build_phase.files
            .find{ |b| b.file_ref.name == "XMLDictionary.h" }.file_ref
        
        #add reference for "XMLDictionary.h" into project "XlsxReaderWriter"
        XMLDictionaryHeaderBuild = XlsxReaderWriter.headers_build_phase.add_file_reference(XMLDictionaryHeader, avoid_duplicates = true);
        #make new file appended public
        XMLDictionaryHeaderBuild.settings = { "ATTRIBUTES" => ["Public"] }
        puts "add #{XMLDictionaryHeader} into XlsxReaderWriter";
    end
end
