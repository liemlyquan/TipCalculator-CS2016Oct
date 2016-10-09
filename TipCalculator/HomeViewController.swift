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
    
    let formatter = NumberFormatter()
    
    var didReturnFromSettingsViewController = false

 
    override func viewDidLoad(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        let defaultTipRate = UserDefaults.standard.float(forKey: "defaultTipPercent")
        tipPercent = defaultTipRate
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (didReturnFromSettingsViewController == true){
            updateBillAmountTextField()
            updateTotalLabel()
            updateEachPersonLabel()
        } else {
            let cell = tableView.cellForRow(at: IndexPath(row: CellEnumeration.amount.hashValue, section: 0)) as! HomeTableViewCell
            cell.cellTextField.becomeFirstResponder()
        }
    }
    
    func dismissKeyboard(){
        self.view.endEditing(true)
    }

    override func viewWillAppear(_ animated: Bool) {
        if (UserDefaults.standard.bool(forKey: "thousandSeparator") == true){
            formatter.numberStyle = .decimal
        } else {
            formatter.numberStyle = .none
        }

        self.tableView.reloadData()

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell", for: indexPath) as! HomeTableViewCell
        cell.cellLabel.text = labelList[(indexPath as NSIndexPath).row]
        var themeName = UserDefaults.standard.string(forKey: "theme") as String!
        themeName = themeName == nil ? "white" : themeName
        if let theme = Constants.themes[themeName!], let color = theme[(indexPath as NSIndexPath).row] as Int! {
            cell.backgroundColor = getColorFromHex(color)
            if themeName == "black" {
                cell.cellLabel.textColor = UIColor.white
                cell.cellTextField.textColor = UIColor.white
            } else {
                cell.cellLabel.textColor = UIColor.black
                cell.cellTextField.textColor = UIColor.black
            }
        }
        
        if CellEnumeration.amount.hashValue == (indexPath as NSIndexPath).row {
            cell.cellTextField.isEnabled = true
            cell.cellTextField.addTarget(self, action: #selector(editBillAmount), for: .editingChanged)
        } else if CellEnumeration.tip.hashValue == (indexPath as NSIndexPath).row {
            let pan = UIPanGestureRecognizer(target: self, action: #selector(adjustTipPercent))
            cell.addGestureRecognizer(pan)
            let percent = Int(tipPercent)
            cell.cellTextField.text = "\(percent)%"
        } else if CellEnumeration.numberOfPeople.hashValue == (indexPath as NSIndexPath).row {
            let pan = UIPanGestureRecognizer(target: self, action: #selector(adjustNumberOfPeople))
            cell.addGestureRecognizer(pan)
            cell.cellTextField.text = "1"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (UIScreen.main.bounds.size.height - 64) / 5
    }
    
    @IBAction func prepareForUnwind(_ sender: UIStoryboardSegue){
        didReturnFromSettingsViewController = true
    }
    
    @IBAction func onTapSaveButton(_ sender: UIButton){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity =  NSEntityDescription.entity(forEntityName: "Bill", in:managedContext)
        let bill = NSManagedObject(entity: entity!, insertInto: managedContext)
        bill.setValue(amount, forKey: "amount")
        bill.setValue(tipPercent, forKey: "tipPercent")
        bill.setValue(numberOfPeople, forKey: "numberOfPeople")
        do {
            try managedContext.save()
            print(bill)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
        let alert = UIAlertController(title: "Saved", message: "Your bill is saved. You can check back later from Settings -> View history", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Close", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func getColorFromHex(_ hex: Int) -> UIColor {
        // http://stackoverflow.com/questions/24263007/how-to-use-hex-colour-values-in-swift-ios
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        return UIColor(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }
    
    func editBillAmount(_ sender: UITextField){
        getBillAmount()
        updateBillAmountTextField()
        updateBill()
    }
    
    func adjustTipPercent(_ sender: UIPanGestureRecognizer){
        tipPercent += Float(Int(sender.translation(in: self.view!).x / 20))
        if tipPercent < 0 {
            tipPercent = 0
        } else if tipPercent > 100 {
            tipPercent = 100
        }
        updateTipPercentTextField()
        updateBill()
    }
    
    func adjustNumberOfPeople(_ sender: UIPanGestureRecognizer){
        numberOfPeople += Int(sender.translation(in: self.view!).x / 40)
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
        cell.cellTextField.text = formatter.string(from: NSNumber(value: amount))
    }
    
    func updateTotalLabel(){
        let cell = getCellFromIndex(CellEnumeration.total.hashValue)
        cell.cellTextField.text = formatter.string(from: NSNumber(value: getTotal()))
    }
    
    func updateEachPersonLabel(){
        let cell = getCellFromIndex(CellEnumeration.each.hashValue)
        cell.cellTextField.text = formatter.string(from: NSNumber(value: getTotalEachPerson()))
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
        let cell = self.tableView.cellForRow(at: IndexPath(row: CellEnumeration.amount.hashValue, section: 0)) as! HomeTableViewCell
        guard var billAmountText = cell.cellTextField .text as String! else {
            return
        }
        billAmountText = billAmountText.replacingOccurrences(of: ",", with: "")
        let billAmount = Float(billAmountText)
        guard let billAmountUnwrapped = billAmount as Float! else {
            amount = 0
            return
        }
        amount = billAmountUnwrapped
    }

    func getCellFromIndex(_ index: Int) -> HomeTableViewCell{
        return self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as! HomeTableViewCell
    }
}
