//
//  AppDelegate.swift
//  cryptoalat
//
//  Created by Neo Ighodaro on 22/06/2018.
//  Copyright © 2018 TapSharp Interactive. All rights reserved.
//

import UIKit
import PushNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        PushNotifications.shared.start(instanceId: AppConstants.PUSHER_INSTANCE_ID)
        PushNotifications.shared.registerForRemoteNotifications()

        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        PushNotifications.shared.registerDeviceToken(deviceToken) {
            if let deviceID = AppConstants.deviceIDFormatted {
                try? PushNotifications.shared.subscribe(interest: "\(deviceID)_eth_changed")
                try? PushNotifications.shared.subscribe(interest: "\(deviceID)_btc_changed")
            }
        }
    }

}
