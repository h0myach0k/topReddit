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
import Foundation

////////////////////////////////////////////////////////////////////////////////
class StubPagingDataSource : DataSource<[String]>
{
    enum ErrorCode : Error
    {
        case cantLoadNext
        case cantLoadPrevious
        case unknownLoadOption
    }
    
    let simulatedResult: [String]
    var currentStartIndex: Int
    var currentEndIndex: Int
    let initialIndex: Int
    
    init(simulatedResult: Value, currentIndex: Int)
    {
        self.simulatedResult = simulatedResult
        currentStartIndex = currentIndex
        currentEndIndex = currentIndex
        initialIndex = currentIndex
    }
    
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
