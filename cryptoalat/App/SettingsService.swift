//
//  SettingsService.swift
//  cryptoalat
//
//  Created by Neo Ighodaro on 22/06/2018.
//  Copyright © 2018 TapSharp Interactive. All rights reserved.
//

import Foundation
import Alamofire
import NotificationBannerSwift

struct Settings: Codable {
    var btc_min_notify: Int?
    var btc_max_notify: Int?
    var eth_min_notify: Int?
    var eth_max_notify: Int?
    
    func toParams() -> Parameters {
        var params: Parameters = [:]
        
        if let btcMin = btc_min_notify { params["btc_min_notify"] = btcMin }
        if let btcMax = btc_max_notify { params["btc_max_notify"] = btcMax }
        if let ethMin = eth_min_notify { params["eth_min_notify"] = ethMin }
        if let ethMax = eth_max_notify { params["eth_max_notify"] = ethMax }

        return params
    }
}

class SettingsService {
    
    static let key = "CryptoAlat"
    
    static let shared = SettingsService()
    
    var settings: Settings? {
        get {
            return self.getCachedSettings()
        }
        set(settings) {
            if let settings = settings {
                self.updateCachedSettings(settings)
            }
        }
    }
    
    private init() {}
    
    /// Load the settings
    func loadSettings(completion: @escaping() -> Void) {
        fetchRemoteSettings { settings in
            guard let settings = settings else {
                return self.saveSettings(self.defaultSettings()) { _ in
                    completion()
                }
            }
            
            self.updateCachedSettings(settings)
            completion()
        }
    }
    
    /// Return the default settings
    fileprivate func defaultSettings() -> Settings {
        return Settings(btc_min_notify: 0, btc_max_notify: 0, eth_min_notify: 0, eth_max_notify: 0)
    }
    
    /// Save the settings
    func saveSettings(_ settings: Settings, completion: @escaping(Bool) -> Void) {
        updateRemoteSettings(settings, completion: { saved in
            if saved {
                self.updateCachedSettings(settings)
            }
            
            completion(saved)
        })
    }
    
    /// Fetches the settings from the remote API
    fileprivate func fetchRemoteSettings(completion: @escaping (Settings?) -> Void) {
        guard let deviceID = AppConstants.deviceIDFormatted else {
            return completion(nil)
        }

        let url = "\(AppConstants.API_URL)?u=\(deviceID)"
        Alamofire.request(url).validate().responseJSON { resp in
            if let data = resp.data, resp.result.isSuccess {
                let decoder = JSONDecoder()
                if let settings = try? decoder.decode(Settings.self, from: data) {
                    return completion(settings)
                }
            }
            
            completion(nil)
        }
    }
    
    /// Update the remote settings
    fileprivate func updateRemoteSettings(_ settings: Settings, completion: @escaping(Bool) -> Void) {
        guard let deviceID = AppConstants.deviceIDFormatted else {
            return completion(false)
        }
        
        let url = "\(AppConstants.API_URL)?u=\(deviceID)"
        
        Alamofire.request(url, method: .post, parameters: settings.toParams()).validate().responseJSON { resp in
            guard resp.result.isSuccess, let res = resp.result.value as? [String: String] else {
                return StatusBarNotificationBanner(title: "Failed to update settings.", style: .danger).show()
            }
            
            completion((res["status"] == "success"))
        }
    }
    
    /// Update the cache
    fileprivate func updateCachedSettings(_ settings: Settings) {
        if let encodedSettings = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encodedSettings, forKey: SettingsService.key)
        }
    }
    
    /// Fetches the settings from the user defaults
    fileprivate func getCachedSettings() -> Settings? {
        let defaults = UserDefaults.standard
        if let data = defaults.object(forKey: SettingsService.key) as? Data {
            let decoder = JSONDecoder()
            if let decodedSettings = try? decoder.decode(Settings.self, from: data) {
                return decodedSettings
            }
        }
        
        return nil
    }
}
