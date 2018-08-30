////////////////////////////////////////////////////////////////////////////////
//
//  ErrorCodingBox.swift
//  Core
//
//  Created by Iurii Khomiak on 8/27/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation

////////////////////////////////////////////////////////////////////////////////
/// Codable wrapper around Error
public class ErrorCodingBox : Codable
{
    public let error: Error
    public init(error: Error)
    {
        self.error = error
    }
    
    private enum Keys : CodingKey
    {
        case domain
        case code
        case localizedDescription
    }
    
    public required init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: Keys.self)
        let domain = try container.decode(String.self, forKey: .domain)
        let code = try container.decode(Int.self, forKey: .code)
        let localizedDescription = try container.decode(String.self, forKey:
            .localizedDescription)
        self.error = NSError(domain: domain , code: code, userInfo:
            [NSLocalizedDescriptionKey : localizedDescription])
    }
    
    public func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: Keys.self)
        let nsError = error as NSError
        try container.encode(nsError.domain, forKey: .domain)
        try container.encode(nsError.code, forKey: .code)
        try container.encode(error.localizedDescription, forKey:
            .localizedDescription)
    }
}
