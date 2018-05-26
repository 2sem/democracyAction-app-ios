# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'democracyaction' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings!
  
  pod 'XlsxReaderWriter'
  pod 'DownPicker'
  pod 'Google-Mobile-Ads-SDK'
  pod 'Firebase/Core'
  pod 'KakaoOpenSDK'
  
  pod 'Material'
  pod 'FBSDKCoreKit'
  pod 'SwipeCellKit'
  pod 'MBProgressHUD'
  
  #pod 'JSQWebViewController'
  #pod 'JBWebViewController'
  pod 'ProgressWebViewController'
  
  pod 'CryptoSwift'
  #pod 'GoogleAPIClientForREST/Drive', '~> 1.2.1'
  pod 'LSExtensions', :path => '~/Projects/leesam/pods/LSExtensions/src/LSExtensions'
  #pod 'LSExtensions'
  
  # Pods for democracyaction

  target 'democracyactionTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'democracyactionUITests' do
    inherit! :search_paths
    # Pods for testing
  end

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
