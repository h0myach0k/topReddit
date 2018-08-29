////////////////////////////////////////////////////////////////////////////////
//
//  RelativeTimeFormatter.swift
//  TopReddit
//
//  Created by Iurii Khomiak on 8/29/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

/// Formatter that formats date relative to current one.
class RelativeTimeFormatter : Formatter
{
    /// Suffix that will be added to result in case if date is in the past
    var beforeSuffix: String?
    /// Suffix that will be added to result in case if date is in the future
    var afterSuffix: String?
    /// String will be returned for current date
    var nowString: String = "now".localized
    /// Calendar
    var calendar: Calendar = .current
    /// Components that is used to check
    let components: [Calendar.Component] = [.year, .month, .weekOfMonth,
        .day, .hour, .minute, .second]
    
    /// Returns formatted string from given date
    func string(from date: Date) -> String
    {
        return string(for: date) ?? ""
    }
    
    /// Returns formatted string from given date
    override func string(for obj: Any?) -> String?
    {
        guard let date = obj as? Date else { return nil }

        let components = Set(self.components)
        let dateComponents = calendar.dateComponents(components, from: date,
            to: Date())

        guard let (component, value) = componentValue(from: dateComponents)
            else { return nowString }
        
        let suffix = (value < 0 ? afterSuffix : beforeSuffix) ?? ""
        let format = localizableFormat(for: component)
        return String.localizedStringWithFormat(format, abs(value), suffix)
    }

    //! MARK: - Private
    private func componentValue(from dateComponents: DateComponents) ->
        (component: Calendar.Component, value: Int)?
    {
        var result: (component: Calendar.Component, value: Int)!
        for component in self.components
        {
            guard let value = dateComponents.value(for: component), value != 0
                else { continue }
            result = (component, value)
            break
        }
        if nil == result
        {
            return nil
        }
        
        if let value = componentValue(after: result.component, in: dateComponents)
        {
            result.value = roundedComponentValue(result, nextValue: value).value
        }
        
        return result
    }

    private func componentValue(after component: Calendar.Component, in
        dateComponents: DateComponents) -> (component: Calendar.Component, value: Int)?
    {
        guard let index = components.index(of: component) else { return nil }
        let nextIndex = components.index(after: index)
        guard components.indices.contains(nextIndex) else { return nil }
        let component = components[nextIndex]
        return (component, dateComponents.value(for: component) ?? 0)
    }
    
    private func roundThreshold(for component: Calendar.Component) -> Int?
    {
        //! TODO: Rounding rules
        switch component
        {
            case .day: return 10
            case .month: return 10
            default: return nil
        }
    }
    
    private func roundedComponentValue(_ value: (component: Calendar.Component,
        value: Int), nextValue: (component: Calendar.Component, value: Int)) ->
        (component: Calendar.Component, value: Int)
    {
        guard let threshold = roundThreshold(for: nextValue.component) else
            { return value }
        guard nextValue.value > threshold else { return value }
        return (value.component, value.value + 1)
    }

    private func localizableFormat(for component: Calendar.Component) -> String
    {
        return "RelativeTimeFormatter.\(component)".localized
    }
}
