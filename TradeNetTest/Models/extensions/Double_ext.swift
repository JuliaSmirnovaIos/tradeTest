//
//  Double_ext.swift
//  TradeNetTest
//
//  Created by Julia Smirnova on 19.12.2022.
//

extension Double {
    var percent: String {
        String(format: "%@%g%%", self >= 0 ? "+" : "", self )
    }
    
    func round(nearest: Double) -> Double {
        guard nearest != 0 else { return self }
        let n = 1/nearest
        let numberToRound = self * n
        return numberToRound.rounded() / n
    }
}
