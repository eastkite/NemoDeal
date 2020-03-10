# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'modoohotdeal' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for modoohotdeal

  pod 'Moya/RxSwift'
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'Alamofire'
  pod 'AlamofireImage'
  
  # UI
  pod 'BonMot'
  pod 'Cartography',  '< 4.0.0'
  pod 'SideMenu'
  
  # firebase
  pod 'Firebase/Analytics'
  pod 'Firebase/Messaging'
  pod 'Firebase/AdMob'
  
  #keychain
  pod 'KeychainSwift', '~> 13.0'
  
  pod 'Toaster'
  
  #license
  pod 'Carte'
  
 
  
end

post_install do |installer|
  pods_dir = File.dirname(installer.pods_project.path)
  at_exit { `ruby #{pods_dir}/Carte/Sources/Carte/carte.rb configure` }
  end
