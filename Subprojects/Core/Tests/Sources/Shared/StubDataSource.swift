////////////////////////////////////////////////////////////////////////////////
//
//  StubDataSource.swift
//  Core
//
//  Created by Iurii Khomiak on 8/25/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
class StubDataSource<Value> : DataSourceProtocol
{
    enum SimulateResult<Value>
    {
        case value(Value)
        case error(Error)
    }
    
    var delegate: DataSourceDelegate?    
    let simulatedResult: SimulateResult<Value>
    var lastUpdateDate: Date?
    var lastError: Error?
    var value: Value?
    var isEmpty = false
    var isLoading = false
    var metadata: DataSourceMetadata = []
    
    init(simulatedResult: SimulateResult<Value>)
    {
        self.simulatedResult = simulatedResult
    }
    
    func loadData(options: DataSourceLoadOptions, completion:
        ((DataSourceChangeRequest<Value>?, Error?) -> Void)?) {
    }
    
    func cancel()
    {
    }
    
    func clean()
    {
    }
    
    func changeRequestToCleanValue() -> DataSourceChangeRequest<Value>
    {
        fatalError("Not implemented")
    }
    
    func changeRequest(toReplaceValue value: Value?) -> DataSourceChangeRequest<Value>
    {
        fatalError("Not implemented")
    }
    
    func performChangeRequest(_ changeRequest: DataSourceChangeRequest<Value>)
    {
        
    }
}
