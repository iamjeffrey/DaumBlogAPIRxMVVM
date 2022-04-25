//
//  SearchBlogNetwork.swift
//  RxSwiftPractice2
//
//  Created by Seonghwan on 2022/02/03.
//

import Foundation
import RxSwift

enum SearchNetworkError: Error {
    case invalidURL
    case invalidJSON
    case networkError
}

class SearchBlogNetwork {
    private let session: URLSession
    let api = SearchBlogAPI()
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    //return Result<Succcess, Failure> type : swift에서 제공
    /*
     enum Result<Success, Failure>
         case success(Success)
         case failure(Failure)
     */
    func searchBlog(query: String) -> Single<Result<DKBlog, SearchNetworkError>> {
        guard let url = api.searchBlog(query: query).url else {
            return .just(.failure(.invalidURL))
        }
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("KakaoAK --------------------------",
                         forHTTPHeaderField: "Authorization")
        return session.rx.data(request: request as URLRequest)
            .map { data in
                do {
                    let blogData = try JSONDecoder().decode(DKBlog.self, from: data)
                    return .success(blogData)
                } catch {
                    return .failure(.invalidJSON)
                }
            }
            .catch { _ in
                .just(.failure(.networkError))
            } //<- 여기까지는 Observable
            .asSingle()
        
    }
}
