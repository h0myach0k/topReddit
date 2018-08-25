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
class StubDataSource<Value> : DataSource<Value>
{
    enum SimulatedResult<Value>
    {
        case value(Value)
        case error(Error)
    }
    
    let simulatedResult: SimulatedResult<Value>
    
    init(simulatedResult: SimulatedResult<Value>)
    {
        self.simulatedResult = simulatedResult
        super.init()
    }
    
    override func main(options: LoadOption)
    {
        switch simulatedResult
        {
            case .error(let error):
                finish(error: error)
            case .value(let value):
                finish(value: value, metadata: [])
        }
    }
}
