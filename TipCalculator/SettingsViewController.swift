//
//  SettingsViewController.swift
//  TipCalculator
//
//  Created by Liem Ly Quan on 9/29/16.
//  Copyright © 2016 liemlyquan. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    @IBOutlet weak var themeIndicatorLabel: UILabel!
    @IBOutlet weak var defaultTipPercentLabel: UILabel!
    @IBOutlet weak var thousandSeparatorSwitch: UISwitch!
    @IBOutlet weak var defaultTipPercentSlider: UISlider!



    override func viewDidLoad() {
        super.viewDidLoad()
        let themeName = UserDefaults.standard.string(forKey: "theme")
        if let themeName = themeName as String! {
            themeIndicatorLabel.text = themeName.capitalized
        }
        let didEnabledthousandSeparator = UserDefaults.standard.bool(forKey: "thousandSeparator")
        if let didEnabledthousandSeparator = didEnabledthousandSeparator as Bool! {
            thousandSeparatorSwitch.setOn(didEnabledthousandSeparator, animated: false)
        }
        let defaultTipPercent = UserDefaults.standard.float(forKey: "defaultTipPercent")
        if let defaultTipPercent = defaultTipPercent as Float! {
            defaultTipPercentSlider.setValue(defaultTipPercent, animated: false)
            let percent = Int(defaultTipPercent)
            defaultTipPercentLabel.text = "\(percent)%"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onToggleThousandSeparator(_ sender: UISwitch){
        var value: Bool
        if sender.isOn == true {
            value = true
        } else {
            value = false
        }
        UserDefaults.standard.set(value, forKey: "thousandSeparator")
    }
    @IBAction func onChangeTipPercent(_ sender: UISlider){
        let value = Int(sender.value)
        defaultTipPercentLabel.text = "\(value)%"
        UserDefaults.standard.set(Int(value), forKey: "defaultTipPercent")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                return 2
            case 1:
                return 2
            default:
                return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 0 {
            if (indexPath as NSIndexPath).row == 1 {
                let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet )
                for (key, _) in Constants.themes {
                    let displayName = key.capitalized
                    let languageAction = UIAlertAction(title: displayName, style: .default, handler: {
                        (alert: UIAlertAction!) -> Void in
                            self.setThemeColor(alert.title?.lowercased())
                    })
                    actionSheet.addAction(languageAction)
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                    (alert: UIAlertAction) -> Void in
                })
                actionSheet.addAction(cancelAction)
                self.present(actionSheet, animated: true, completion: nil)
            }
        }
    }
    
    func setThemeColor(_ themeName: String?){
        if let themeName = themeName as String! {
            UserDefaults.standard.setValue(themeName, forKey: "theme")
            themeIndicatorLabel.text = themeName.capitalized
        }
    }
}


