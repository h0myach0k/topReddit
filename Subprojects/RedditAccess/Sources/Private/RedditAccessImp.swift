////////////////////////////////////////////////////////////////////////////////
//
//  RedditAccessImp.swift
//  RedditAccess
//
//  Created by Iurii Khomiak on 8/25/18.
//  Copyright © 2018 Iurii Khomiak. All rights reserved.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
import Foundation
import URLAccess

////////////////////////////////////////////////////////////////////////////////
class RedditAccessImp : RedditAccess
{
    //! MARK: - Properties
    /// URL access responsible for loading data
    let urlAccess: URLAccess
    let parameters: RedditAccessParameters
    
    //! MARK: - Init & Deinit
    /// Initializes new instance with given url access
    init(urlAccess: URLAccess, parameters: RedditAccessParameters)
    {
        self.urlAccess = urlAccess
        self.parameters = parameters
    }
    
    //! MARK: - As RedditAccess
    func run(query: ListingQuery, completionQueue: DispatchQueue? = nil,
        completion: @escaping (Result<ListingResult>) -> Void) -> Task
    {
        let completionQueue = completionQueue ?? .main
        do
        {
            let urlRequest = try self.urlRequest(for: query)
            return urlAccess.peform(request: urlRequest).responseDecodable(
                decoder: jsonDecoder(), queue: completionQueue)
            { (response: DataResponse<RedditListingResponse>) in
                let result: Result<ListingResult> = response.result.map
                    {ListingResultImp(query: query, response: $0)}
                completion(result)
            }
        }
        catch
        {
            completionQueue.async {completion(.failure(error))}
            return VoidTask()
        }
    }
    
    //! MARK: - Private
    private func urlRequest(for query: ListingQuery) throws -> URLRequest
    {
        let builder = URLBuilder(query: query, parameters: parameters)
        let url = try builder.build()
        return URLRequest(url: url)
    }
    
    private func jsonDecoder() -> JSONDecoder
    {
        let result = JSONDecoder()
        result.dateDecodingStrategy = .secondsSince1970
        return result
    }
}
