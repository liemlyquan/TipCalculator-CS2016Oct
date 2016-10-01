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

    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func toggleThousandSeparator(){
        
    }
    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        if indexPath.row == 1 {
//            
//        }
//    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                return 2
            case 1:
                return 1
            default:
                return 0
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 1 {
                let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet )
                for (key, _) in Constants.themes {
                    let displayName = key.capitalizedString
                    let languageAction = UIAlertAction(title: displayName, style: .Default, handler: {
                        (alert: UIAlertAction!) -> Void in
                            self.setThemeColor(alert.title?.lowercaseString)
                    })
                    actionSheet.addAction(languageAction)
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
                    (alert: UIAlertAction) -> Void in
                })
                actionSheet.addAction(cancelAction)
                self.presentViewController(actionSheet, animated: true, completion: nil)
            }
        }
    }
    
    func setThemeColor(themeName: String?){
        if let themeName = themeName as String! {
            NSUserDefaults.standardUserDefaults().setValue(themeName, forKey: "theme")
            themeIndicatorLabel.text = themeName.capitalizedString
        }
    }
}


