import Foundation

struct Device: Decodable {
    var id: String
    var initialInterestSet: Array<String>?

    static func persist(_ deviceId: String) {
        UserDefaults(suiteName: "PushNotifications")?.set(deviceId, forKey: "com.pusher.sdk.deviceId")
    }

    static func getDeviceId() -> String? {
        return UserDefaults(suiteName: "PushNotifications")?.string(forKey: "com.pusher.sdk.deviceId")
    }

    static func idAlreadyPresent() -> Bool {
        return self.getDeviceId() != nil
    }
}
