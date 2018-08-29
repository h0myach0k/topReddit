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
import Core

////////////////////////////////////////////////////////////////////////////////
class StubDataSource<Value> : DataSource<Value> where Value : Codable
{
    //! MARK: - Forward Declarations
    enum SimulatedResult<Value>
    {
        case value(Value)
        case error(Error)
    }
    enum CodingKeys : CodingKey
    {
        case simulatedResult
    }
    
    //! MARK: - Properties
    let simulatedResult: SimulatedResult<Value>
    
    //! MARK: - Init & Deinit
    init(simulatedResult: SimulatedResult<Value>)
    {
        self.simulatedResult = simulatedResult
        super.init()
    }
    
    //! MARK: - Overrides
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
    
    //! MARK: - As Codable
    required init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        simulatedResult = try container.decode(SimulatedResult.self, forKey:
            .simulatedResult)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws
    {
        try super.encode(to: encoder)
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(simulatedResult, forKey: .simulatedResult)
    }
}

////////////////////////////////////////////////////////////////////////////////
//! MARK: - SimulatedResult as Codable
extension StubDataSource.SimulatedResult : Codable where Value : Codable
{
    enum Keys : CodingKey { case value, error }
    
    init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: Keys.self)
        if let value = try container.decodeIfPresent(Value.self, forKey: .value)
        {
            self = .value(value)
        }
        else if let box = try container.decodeIfPresent(ErrorCodingBox.self,
            forKey: .error)
        {
            self = .error(box.error)
        }
        else
        {
            throw NSError(domain: "Result must be error or value", code: 0,
                userInfo: nil)
        }
    }
    
    func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: Keys.self)
        switch self
        {
            case let .value(value):
                try container.encode(value, forKey: .value)
            case let .error(error):
                try container.encode(ErrorCodingBox(error: error), forKey: .error)
        }
    }
}
