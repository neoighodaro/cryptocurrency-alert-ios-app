//
//  AppConstants.swift
//  cryptoalat
//
//  Created by Neo Ighodaro on 22/06/2018.
//  Copyright © 2018 TapSharp Interactive. All rights reserved.
//

import UIKit

struct AppConstants {

    static let API_URL = "http://30b7197a.ngrok.io/api/settings"

    static let deviceID = UIDevice.current.identifierForVendor?.uuidString

    static let deviceIDFormatted = AppConstants.deviceID?.replacingOccurrences(of: "-", with: "_").lowercased()

    static let PUSHER_INSTANCE_ID = "PUSHER_BEAMS_INSTANCE_ID"

    static let PUSHER_APP_KEY = "PUSHER_APP_KEY"

    static let PUSHER_APP_CLUSTER = "PUSHER_APP_CLUSTER"
}
