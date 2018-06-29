//
//  CoinsTableViewController.swift
//  cryptoalat
//
//  Created by Neo Ighodaro on 23/06/2018.
//  Copyright © 2018 TapSharp Interactive. All rights reserved.
//

import UIKit
import PusherSwift
import NotificationBannerSwift

struct Coin {
    let name: String
    let rate: Float
}

class CoinsTableViewController: UITableViewController {

    var pusher: Pusher!

    var coins: [Coin] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        pusher = Pusher(key: AppConstants.PUSHER_APP_KEY, options: PusherClientOptions(host: .cluster(AppConstants.PUSHER_APP_CLUSTER)))

        let channel = pusher.subscribe("currency-update")

        let _ = channel.bind(eventName: "currency.updated") { data in
            if let data = data as? [String: [String: [String: Float]]] {
                guard let payload = data["payload"] else { return }

                self.coins = []

                for (coin, deets) in payload {
                    guard let currentPrice = deets["current"] else { return }
                    self.coins.append(Coin(name: coin, rate: currentPrice))
                }

                Dispatch.main.async {
                    self.tableView.reloadData()
                }
            }
        }

        pusher.connect()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coins.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let coin = coins[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "coin", for: indexPath) as! CoinTableViewCell

        cell.name.text = "1 \(coin.name) ="
        cell.amount.text = "$\(String(coin.rate))"

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let coin = coins[indexPath.row]

        var minTextField: UITextField?
        var maxTextField: UITextField?

        let title = "Manage \(coin.name) alerts"
        let message = "Notification will be sent to you when price exceeds or goes below minimum and maximum price. Set to zero to turn off notification."

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addTextField { textfield in
            minTextField = textfield
            textfield.placeholder = "Alert when price is below"
        }

        alert.addTextField { textfield in
            maxTextField = textfield
            textfield.placeholder = "Alert when price is above"
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { action in
            guard let minPrice = minTextField?.text, let maxPrice = maxTextField?.text else {
                return StatusBarNotificationBanner(title: "Invalid min or max price", style: .danger).show()
            }

            var btcMin: Int?, btcMax: Int?, ethMin: Int?, ethMax: Int?

            switch coin.name {
            case "BTC":
                btcMin = Int(minPrice)
                btcMax = Int(maxPrice)
            case "ETH":
                ethMin = Int(minPrice)
                ethMax = Int(maxPrice)
            default:
                return
            }


            let settings = Settings(
                btc_min_notify: btcMin,
                btc_max_notify: btcMax,
                eth_min_notify: ethMin,
                eth_max_notify: ethMax
            )

            SettingsService.shared.saveSettings(settings, completion: { saved in
                if saved {
                    StatusBarNotificationBanner(title: "Saved successfully").show()
                }
            })
        }))

        present(alert, animated: true, completion: nil)
    }
}
