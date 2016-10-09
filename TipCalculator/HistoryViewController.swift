//
//  HistoryViewController.swift
//  TipCalculator
//
//  Created by Liem Ly Quan on 9/29/16.
//  Copyright © 2016 liemlyquan. All rights reserved.
//
import CoreData
import UIKit

class HistoryViewController: UITableViewController {
    var billList = [NSManagedObject]()
    var managedContext: NSManagedObjectContext = NSManagedObjectContext()
    let formatter = NumberFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.numberStyle = .decimal
        initData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Bill")
        do {
            let results = try managedContext.fetch(fetchRequest)
            billList = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return billList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell", for: indexPath) as! HistoryTableViewCell
        let amount = billList[indexPath.row].value(forKey: "amount")
        guard let amountUnwrapped = amount as? Float else {
            return cell
        }
        let tipPercent = billList[(indexPath as NSIndexPath).row].value(forKey: "tipPercent")
        guard let tipPercentUnwrapped = tipPercent as? Float else {
            return cell
        }
        let numberOfPeople = billList[(indexPath as NSIndexPath).row].value(forKey: "numberOfPeople")
        guard let numberOfPeopleUnwrapped = numberOfPeople as? Int else {
            return cell
        }
        
        let total = amountUnwrapped * Float(1 + tipPercentUnwrapped / 100.0)
        
        let titleText = formatter.string(from: NSNumber(value: total))
        
        let amountText = formatter.string(from: NSNumber(value: amountUnwrapped))! as String
        print(amountText)
        let percent = Int(tipPercentUnwrapped)
        let subtitleText = "The bill amount is \(amountText)\n" +
                    "Tipped \(percent)%\n" +
                    "Shared by \(numberOfPeopleUnwrapped) people"
        
        cell.cellTitleLabel.text = titleText
        cell.cellSubtitleLabel.text = subtitleText
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete){
            managedContext.delete(billList[(indexPath as NSIndexPath).row])
            billList.remove(at: (indexPath as NSIndexPath).row)
            tableView.reloadData()
        }
    }
}
