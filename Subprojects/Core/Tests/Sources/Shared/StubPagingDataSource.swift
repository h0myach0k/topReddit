////////////////////////////////////////////////////////////////////////////////
//
//  StubPagingDataSource.swift
//  Core
//
//  Created by Iurii Khomiak on 8/25/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Core

////////////////////////////////////////////////////////////////////////////////
class StubPagingDataSource : DataSource<[String]>
{
    //! MARK: - Forward Declarations
    enum ErrorCode : Error
    {
        case cantLoadNext
        case cantLoadPrevious
        case unknownLoadOption
    }
    enum CodingKeys : CodingKey
    {
        case simulatedResult
        case currentStartIndex
        case currentEndIndex
        case initialIndex
    }
    
    //! MARK: - Properties
    let simulatedResult: [String]
    var currentStartIndex: Int
    var currentEndIndex: Int
    let initialIndex: Int
    
    //! MARK: - Init & Deinit
    init(simulatedResult: Value, currentIndex: Int)
    {
        self.simulatedResult = simulatedResult
        currentStartIndex = currentIndex
        currentEndIndex = currentIndex
        initialIndex = currentIndex
        super.init()
    }
    
    //! MARK: - As Codable
    required init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        simulatedResult = try container.decode([String].self, forKey:
            .simulatedResult)
        currentStartIndex = try container.decode(Int.self, forKey: .currentStartIndex)
        currentEndIndex = try container.decode(Int.self, forKey: .currentEndIndex)
        initialIndex = try container.decode(Int.self, forKey: .initialIndex)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws
    {
        try encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(simulatedResult, forKey: .simulatedResult)
        try container.encode(currentStartIndex, forKey: .currentStartIndex)
        try container.encode(currentEndIndex, forKey: .currentEndIndex)
        try container.encode(initialIndex, forKey: .initialIndex)
    }
    
    //! MARK: - Overrides
    override func main(options: LoadOption)
    {
        if options.contains(.initialLoad)
        {
            let metadata = getMetadata()
            finish(value: [simulatedResult[currentStartIndex]], metadata:
                metadata)
        }
        else if options.contains(.loadNext)
        {
            guard self.metadata.contains(.hasNext) else
            {
                finish(error: ErrorCode.cantLoadNext)
                return
            }
            
            currentEndIndex += 1
            
            let metadata = getMetadata()
            finish(loadOptions: options,
                items: [simulatedResult[currentEndIndex]],
                metadata: metadata)
        }
        else if options.contains(.loadPrevious)
        {
            guard self.metadata.contains(.hasPrevious) else
            {
                finish(error: ErrorCode.cantLoadPrevious)
                return
            }
            
            currentStartIndex -= 1
            let metadata = getMetadata()
            finish(loadOptions: options,
                items: [simulatedResult[currentStartIndex]],
                metadata: metadata)
        }
        else
        {
            finish(error: ErrorCode.unknownLoadOption)
        }
    }
    
    //! MARK: - Private
    private func hasNext(index: Int) -> Bool
    {
        return simulatedResult.indices.contains(index + 1)
    }
    
    private func hasPrevious(index: Int) -> Bool
    {
        return simulatedResult.indices.contains(index - 1)
    }
    
    private func getMetadata() -> Metadata
    {
        var metadata: Metadata = []
        if hasPrevious(index: currentStartIndex)
        {
            metadata.insert(.hasPrevious)
        }
        if hasNext(index: currentEndIndex)
        {
            metadata.insert(.hasNext)
        }
        return metadata
    }
}
