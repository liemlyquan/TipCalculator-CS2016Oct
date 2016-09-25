//
//  BillViewModel.swift
//  TipCalculator
//
//  Created by Liem Ly Quan on 9/24/16.
//  Copyright © 2016 liemlyquan. All rights reserved.
//

import Foundation

class BillViewModel {
    let amount: Float
    let numberOfPeople: Int
    let tipPercent: Float
    let total: Float
    let totalPerPerson: Float
    
    init(bill: Bill){
        amount = bill.amount
        numberOfPeople = bill.numberOfPeople
        tipPercent = bill.tipPercent
        total = amount * (1 + tipPercent / 100)
        totalPerPerson = total / Float(numberOfPeople)
    }
    
    
    
}