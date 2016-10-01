//
//  HomeViewController.swift
//  TipCalculator
//
//  Created by Liem Ly Quan on 9/30/16.
//  Copyright © 2016 liemlyquan. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UITableViewController {
    let labelList = ["Bill", "Tip percent", "Number of people", "Total", "Each"]
    enum CellEnumeration {
        case amount, tip, numberOfPeople,total, each
    }
    
    var amount: Float = 0
    var numberOfPeople: Int = 1
    var tipPercent: Float = 0
    
    var billList = [NSManagedObject]()
    
    let formatter = NSNumberFormatter()
    
    var didReturnFromSettingsViewController = false

 
    override func viewDidLoad(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        let defaultTipRate = NSUserDefaults.standardUserDefaults().floatForKey("defaultTipPercent")
        tipPercent = defaultTipRate
    }
    
    override func viewDidAppear(animated: Bool) {
        if (didReturnFromSettingsViewController == true){
            updateBillAmountTextField()
            updateTotalLabel()
            updateEachPersonLabel()
        } else {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: CellEnumeration.amount.hashValue, inSection: 0)) as! HomeTableViewCell
            cell.cellTextField.becomeFirstResponder()
        }
    }
    
    func dismissKeyboard(){
        self.view.endEditing(true)
    }

    override func viewWillAppear(animated: Bool) {
        if (NSUserDefaults.standardUserDefaults().boolForKey("thousandSeparator") == true){
            formatter.numberStyle = .DecimalStyle
        } else {
            formatter.numberStyle = .NoStyle
        }

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
            cell.cellTextField.addTarget(self, action: #selector(editBillAmount), forControlEvents: .EditingChanged)
        } else if CellEnumeration.tip.hashValue == indexPath.row {
            let pan = UIPanGestureRecognizer(target: self, action: #selector(adjustTipPercent))
            cell.addGestureRecognizer(pan)
            let percent = Int(tipPercent)
            cell.cellTextField.text = "\(percent)%"
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
    
    @IBAction func prepareForUnwind(sender: UIStoryboardSegue){
        didReturnFromSettingsViewController = true
    }
    
    @IBAction func onTapSaveButton(sender: UIButton){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity =  NSEntityDescription.entityForName("Bill", inManagedObjectContext:managedContext)
        let bill = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        bill.setValue(amount, forKey: "amount")
        bill.setValue(tipPercent, forKey: "tipPercent")
        bill.setValue(numberOfPeople, forKey: "numberOfPeople")
        do {
            try managedContext.save()
            billList.append(bill)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
        let alert = UIAlertController(title: "Saved", message: "Your bill is saved. You can check back later from Settings -> View history", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Close", style: .Default, handler: nil)
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
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
    
    func editBillAmount(sender: UITextField){
        getBillAmount()
        updateBillAmountTextField()
        updateBill()
    }
    
    func adjustTipPercent(sender: UIPanGestureRecognizer){
        tipPercent += Float(Int(sender.translationInView(self.view!).x / 20))
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
        updateTotalLabel()
        updateEachPersonLabel()
    }
    
    func updateBillAmountTextField(){
        let cell = getCellFromIndex(CellEnumeration.amount.hashValue)
        cell.cellTextField.text = formatter.stringFromNumber(amount)
    }
    
    func updateTotalLabel(){
        let cell = getCellFromIndex(CellEnumeration.total.hashValue)
        cell.cellTextField.text = formatter.stringFromNumber(getTotal())
    }
    
    func updateEachPersonLabel(){
        let cell = getCellFromIndex(CellEnumeration.each.hashValue)
        cell.cellTextField.text = formatter.stringFromNumber(getTotalEachPerson())
    }

    func updateNumberOfPeopleTextField(){
        let cell = getCellFromIndex(CellEnumeration.numberOfPeople.hashValue)
        cell.cellTextField.text = "\(numberOfPeople)"
    }
    
    func updateTipPercentTextField(){
        let cell = getCellFromIndex(CellEnumeration.tip.hashValue)
        let percent = Int(tipPercent)
        cell.cellTextField.text = "\(percent)%"
    }
    


    func getTotalEachPerson() -> Float {
        return getTotal() / Float(numberOfPeople)
    }
    
    func getTotal() -> Float {
        return (amount * Float(1 + tipPercent / 100))
    }
    
    func getBillAmount(){
        let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: CellEnumeration.amount.hashValue, inSection: 0)) as! HomeTableViewCell
        guard var billAmountText = cell.cellTextField .text as String! else {
            return
        }
        billAmountText = billAmountText.stringByReplacingOccurrencesOfString(",", withString: "")
        let billAmount = Float(billAmountText)
        guard let billAmountUnwrapped = billAmount as Float! else {
            amount = 0
            return
        }
        amount = billAmountUnwrapped
    }

    func getCellFromIndex(index: Int) -> HomeTableViewCell{
        return self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as! HomeTableViewCell
    }
}
