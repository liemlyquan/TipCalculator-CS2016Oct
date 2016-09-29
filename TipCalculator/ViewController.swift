//
//  ViewController.swift
//  TipCalculator
//
//  Created by Liem Ly Quan on 9/22/16.
//  Copyright © 2016 liemlyquan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var billAmountTextField: UITextField!
    @IBOutlet weak var numberOfPeopleTextField: UITextField!
    @IBOutlet weak var tipPercentTextField: UITextField!
    
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var eachPersonLabel: UILabel!
    
    var amount: Float = 0
    var numberOfPeople: Int = 1
    var tipPercent: Float = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard(){
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onEditBillAmountField(sender: UITextField) {
        updateBill()
    }
    
    @IBAction func onTapIncreaseNumberOfPeopleButton(sender: UIButton){
        increaseNumberOfPeople()
        updateNumberOfPeopleTextField()
    }
    
    @IBAction func onTapDecreaseNumberOfPeople(sender: UIButton){
        decreaseNumberOfPeople()
        updateNumberOfPeopleTextField()
    }
    
    @IBAction func onTapIncreaseTipPercent(sender: UIButton){
        increaseTipPercent()
        updateTipPercentTextField()
    }
    
    @IBAction func onTapDecreaseTipPercent(sender: UIButton){
        decreaseTipPercent()
        updateTipPercentTextField()

    }
    
    
    func saveBill(){
        
    }
    
    func updateBill(){
        updateBillAmount()
        updateTotalLabel(getTotal())
        updateEachPersonLabel(getTotalEachPerson())
    }
    
    func updateTotalLabel(amount: Float){
        totalLabel.text = "\(amount)"
    }
    
    func updateEachPersonLabel(amount: Float){
        eachPersonLabel.text = "\(amount)"
    }
    
    func updateNumberOfPeopleTextField(){
        numberOfPeopleTextField.text = "\(numberOfPeople)"
    }
    
    func updateTipPercentTextField(){
        tipPercentTextField.text = "\(tipPercent)"
    }
    
    func getTotalEachPerson() -> Float {
        return getTotal() / Float(numberOfPeople)
    }
    
    func getTotal() -> Float {
        return (amount * (1 + tipPercent))
    }
    
    func updateBillAmount(){
        guard let billAmountText = billAmountTextField.text as String! else {
            return
        }
        let billAmount = Float(billAmountText)
        guard let billAmountUnwrapped = billAmount as Float! else {
            return
        }
        amount = billAmountUnwrapped
    }
    
    func getTipPercent() -> Float{
        return 1
    }
    
    func increaseTipPercent(increaseAmount: Float = 1.0) {
        tipPercent += increaseAmount
    }
    
    func decreaseTipPercent(decreaseAmount: Float = 1.0) {
        tipPercent -= decreaseAmount
    }

    func increaseNumberOfPeople(increaseAmount: Int = 1) {
        numberOfPeople += increaseAmount
    }
    
    func decreaseNumberOfPeople(decreaseAmount: Int = 1) {
        if (numberOfPeople - decreaseAmount > 0){
            numberOfPeople -= decreaseAmount
        }
    }
    
}

