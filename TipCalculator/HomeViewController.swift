//
//  HomeViewController.swift
//  TipCalculator
//
//  Created by Liem Ly Quan on 9/30/16.
//  Copyright © 2016 liemlyquan. All rights reserved.
//

import UIKit

class HomeViewController: UITableViewController {
    let labelList = ["Bill", "Tip percent", "Number of people", "Total", "Each person"]
    enum CellEnumeration {
        case amount, tip, numberOfPeople,total, each
    }
    
    var amount: Float = 0
    var numberOfPeople: Int = 1
    var tipPercent: Int = 0
 
    override func viewDidLoad(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(animated: Bool) {
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: CellEnumeration.amount.hashValue, inSection: 0)) as! HomeTableViewCell
        cell.cellTextField.becomeFirstResponder()
    }

    func dismissKeyboard(){
        self.view.endEditing(true)
    }

    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("HomeTableViewCell", forIndexPath: indexPath) as! HomeTableViewCell
        cell.cellLabel.text = labelList[indexPath.row]
        var themeName = NSUserDefaults.standardUserDefaults().stringForKey("theme") as String!
        themeName = themeName == nil ? "white" : themeName
        if let theme = Constants.themes[themeName], color = theme[indexPath.row] as Int! {
            cell.backgroundColor = getColorFromHex(color)
            if themeName == "black" {
                cell.cellLabel.textColor = UIColor.whiteColor()
                cell.cellTextField.textColor = UIColor.whiteColor()
            } else {
                cell.cellLabel.textColor = UIColor.blackColor()
                cell.cellTextField.textColor = UIColor.blackColor()
            }
        }
        
        if CellEnumeration.amount.hashValue == indexPath.row {
            cell.cellTextField.enabled = true
            cell.cellTextField.addTarget(self, action: #selector(updateBill), forControlEvents: .EditingChanged)
        } else if CellEnumeration.tip.hashValue == indexPath.row {
            let pan = UIPanGestureRecognizer(target: self, action: #selector(adjustTipPercent))
            cell.addGestureRecognizer(pan)
            cell.cellTextField.text = "\(tipPercent)%"
        } else if CellEnumeration.numberOfPeople.hashValue == indexPath.row {
            let pan = UIPanGestureRecognizer(target: self, action: #selector(adjustNumberOfPeople))
            cell.addGestureRecognizer(pan)
            cell.cellTextField.text = "1"
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return (UIScreen.mainScreen().bounds.size.height - 64) / 5
    }
    
    func getColorFromHex(hex: Int) -> UIColor {
        // http://stackoverflow.com/questions/24263007/how-to-use-hex-colour-values-in-swift-ios
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        return UIColor(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }
    
    func adjustTipPercent(sender: UIPanGestureRecognizer){
        tipPercent += Int(sender.translationInView(self.view!).x / 20)
        if tipPercent < 0 {
            tipPercent = 0
        } else if tipPercent > 100 {
            tipPercent = 100
        }
        updateTipPercentTextField()
        updateBill()
    }
    
    func adjustNumberOfPeople(sender: UIPanGestureRecognizer){
        numberOfPeople += Int(sender.translationInView(self.view!).x / 40)
        if numberOfPeople < 1 {
            numberOfPeople = 1
        } else if numberOfPeople > 50 {
            numberOfPeople = 50
        }
        updateNumberOfPeopleTextField()
        updateBill()
    }
    

    func updateBill(){
        updateBillAmount(CellEnumeration.amount.hashValue)
        updateTotalLabel()
        updateEachPersonLabel()
    }
    
    func updateTotalLabel(){
        let cell = getCellFromIndex(CellEnumeration.total.hashValue)
        cell.cellTextField.text = String(getTotal())
    }
    
    func updateEachPersonLabel(){
        let cell = getCellFromIndex(CellEnumeration.each.hashValue)
        cell.cellTextField.text = String(getTotalEachPerson())
    }

    func updateNumberOfPeopleTextField(){
        let cell = getCellFromIndex(CellEnumeration.numberOfPeople.hashValue)
        cell.cellTextField.text = "\(numberOfPeople)"
    }
    
    func updateTipPercentTextField(){
        let cell = getCellFromIndex(CellEnumeration.tip.hashValue)
        cell.cellTextField.text = "\(tipPercent)%"
    }

    func getTotalEachPerson() -> Float {
        return getTotal() / Float(numberOfPeople)
    }
    
    func getTotal() -> Float {
        return (amount * Float(1 + tipPercent))
    }
    
    func updateBillAmount(index: Int){
        let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as! HomeTableViewCell
        guard let billAmountText = cell.cellTextField .text as String! else {
            return
        }
        let billAmount = Float(billAmountText)
        guard let billAmountUnwrapped = billAmount as Float! else {
            return
        }
        amount = billAmountUnwrapped
    }

    func getCellFromIndex(index: Int) -> HomeTableViewCell{
        return self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as! HomeTableViewCell
    }
}
