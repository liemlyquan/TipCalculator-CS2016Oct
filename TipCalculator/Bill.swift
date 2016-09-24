//
//  Bill.swift
//  TipCalculator
//
//  Created by Liem Ly Quan on 9/24/16.
//  Copyright © 2016 liemlyquan. All rights reserved.
//

import Foundation

class Bill {
    let amount: Int
    let numberOfPeople: Int
    let tipPercent: Int
    
    init(amount: Int, numberOfPeople: Int, tipPercent: Int){
        self.amount = amount
        self.numberOfPeople = numberOfPeople
        self.tipPercent = tipPercent
    }
}