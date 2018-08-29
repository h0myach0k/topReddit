////////////////////////////////////////////////////////////////////////////////
//
//  IntExtensions.swift
//  TopReddit
//
//  Created by Iurii Khomiak on 8/26/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
extension Int
{
    //! MARK: - Forward Declarations
    fileprivate typealias Abbreviation = (threshold: Double, divisor: Double,
        suffix: String)
    fileprivate static let abbreviations: [Abbreviation] =
    {
        return [
            (0, 1, ""),
            (1000, 1000, "K".localized),
            (100_000, 1_000_000, "M".localized),
            (100_000_000, 1_000_000_000, "B".localized)
        ]
    }()
    
    //! MARK: - Properties
    var abbreviated: String
    {
        let numberFormatter = NumberFormatter()

        let absValue = Double(abs(self))
        let abbreviation = self.abbreviation(for: absValue)
        let value = Double(self) / abbreviation.divisor
        
        numberFormatter.positiveSuffix = abbreviation.suffix
        numberFormatter.negativeSuffix = abbreviation.suffix
        numberFormatter.minimumIntegerDigits = 1
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 1

        return numberFormatter.string(for: value) ?? ""
    }
    
    //! MARK: - Private
    fileprivate func abbreviation(for value: Double) -> Abbreviation
    {
        let abbreviations = type(of: self).abbreviations
        
        var result = abbreviations[0]
        for abbreviation in abbreviations
        {
            if value < abbreviation.threshold
            {
                break
            }
            result = abbreviation
        }
        return result
    }
}
