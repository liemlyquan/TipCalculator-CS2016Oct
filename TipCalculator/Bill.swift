//
//  Bill.swift
//  TipCalculator
//
//  Created by Liem Ly Quan on 9/24/16.
//  Copyright © 2016 liemlyquan. All rights reserved.
//

import Foundation

class Bill {
    let amount: Float
    let numberOfPeople: Int
    let tipPercent: Float
    
    init(amount: Float, numberOfPeople: Int, tipPercent: Float){
        self.amount = amount
        self.numberOfPeople = numberOfPeople
        self.tipPercent = tipPercent
    }
}