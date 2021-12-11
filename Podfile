# Uncomment the next line to define a global platform for your project

platform :ios, '10.0'
target 'MijnBewijsstukken' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  #pod 'mp3lame-for-ios'
  pod "MBCircularProgressBar"
  pod 'Floaty'
  pod 'Alamofire', '~> 4.9'
  pod 'AlamofireImage'
  pod 'AlamofireObjectMapper'
  pod 'ObjectMapper'
  pod "SwiftyCam"
  pod 'QRCodeReader.swift'


  pod 'Bugsnag'
  # Pods for MijnBewijsstukken
#   pod 'SnapKit'
  #  pod 'Hero'
 
# pod 'Agrume', '4.0.1'
pod 'Agrume'
#pod 'SCLAlertView'
pod 'SCLAlertView' , :git => 'https://github.com/vikmeup/SCLAlertView-Swift.git'

#pod 'PushNotifications'

  # Xcode Beta fix
#  post_install do |installer|
#      installer.pods_project.targets.each do |target|
##          if target.name == 'MijnBewijsstukken'
#              target.build_configurations.each do |config|
#                  config.build_settings['SWIFT_VERSION'] = '4.0'
#              end
##          end
#      end
#  end

post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
end

fork do
    Process.setsid
    STDIN.reopen("/dev/null")
    STDOUT.reopen("/dev/null", "a")
    STDERR.reopen("/dev/null", "a")
    
    require 'shellwords'
    
    Dir["#{ENV["DWARF_DSYM_FOLDER_PATH"]}/*/Contents/Resources/DWARF/*"].each do |dsym|
        system("curl -F apiKey=bbc4a06b4ab711b7a79e7bd667b45026 -F dsym=@#{Shellwords.escape(dsym)} -F projectRoot=#{Shellwords.escape(ENV["PROJECT_DIR"])} https://upload.bugsnag.com/")
    end
end


end
