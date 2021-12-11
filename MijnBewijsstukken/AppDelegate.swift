//
//  AppDelegate.swift
//  MijnBewijsstukken
//
//  Created by Wijnand Boerma on 24-01-17.
//  Copyright © 2017 Wndworks. All rights reserved.
//

import UIKit
import AlamofireObjectMapper
import Alamofire
import Foundation
import Bugsnag
//import PushNotifications
import SCLAlertView

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Bugsnag.start(withApiKey: "bbc4a06b4ab711b7a79e7bd667b45026")
        
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
        }else{
            print("Internet Connection not Available AppDel")
//            SCLAlertView().showError("Geen internet", subTitle: "We kunnen de App niet starten, omdat er geen werkende WiFiverbinding is.")
        }
        
        let defaults = UserDefaults.standard
        if let token = defaults.string(forKey: "user_token")
        {
            print(token)
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let innerPage: MainNavigationVC = mainStoryboard.instantiateViewController(withIdentifier: "mainBoardId") as! MainNavigationVC
            self.window?.rootViewController = innerPage
        }
        if let userName = defaults.string(forKey: "user_name") {
            Bugsnag.configuration()?.setUser("userId", withName: userName, andEmail: userName+"@mbs.nl")
            Bugsnag.leaveBreadcrumb(withMessage: "Logged in: "+userName)
        }
        

        return true
    }
    
//    let pushNotifications = PushNotifications.shared
//
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//        self.pushNotifications.start(instanceId: "1dad8f4f-35c2-4756-8b98-7e96747bf649")
//        self.pushNotifications.registerForRemoteNotifications()
//        try? self.pushNotifications.subscribe(interest: "Hoi")
//
//        return true
//    }
//
//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        self.pushNotifications.registerDeviceToken(deviceToken)
//    }
//
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        self.pushNotifications.handleNotification(userInfo: userInfo)
//    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        print("url \(url)")
        print("url host :\(url.host!)")
        print("url path :\(url.path)")
        
        let urlPath : String = url.path as String
        let urlHost : String = url.host! as String
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        if(urlHost != "login")
        {
            print("Host is not correct")
            return false
        }
        
        if(urlHost == "login"){
            var token = urlPath.replace(target: "/", withString:"")
            
            let fullQR: String = token
            let fullQrArr = fullQR.components(separatedBy: "_")
            if fullQR.range(of:"_") != nil {
                token = fullQrArr[1]
            } else {
                token = fullQrArr[0]
            }
            
            let parameters: Parameters = ["api_token": token]
            let URL = "https://beheer.mijnbewijsstukken.nl/api/swift/qr"
            Alamofire.request(URL, parameters: parameters).responseObject { (response: DataResponse<UserResponse>) in
                switch response.result {
                case .success:
                    let userResponse = response.result.value
                    print("LoginSuccess")
                    let defaults = UserDefaults.standard
                    defaults.set((userResponse?.name)!, forKey: "user_name")
                    defaults.set((userResponse?.token)!, forKey: "user_token")
                    defaults.set((userResponse?.photo)!, forKey: "user_photo")
                    defaults.set((userResponse?.has_notification)!, forKey: "has_notification")
                    
                    let innerPage: MainNavigationVC = mainStoryboard.instantiateViewController(withIdentifier: "mainBoardId") as! MainNavigationVC
                    self.window?.rootViewController = innerPage
                case .failure:
                    print("No User")
                }
            }
        }
        self.window?.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
//    func application(_application: UIApplication, sourceApplication: String?, annotation: AnyObject) -> Bool {
//
//    }

}

extension String
{
    func replace(target: String, withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
}
