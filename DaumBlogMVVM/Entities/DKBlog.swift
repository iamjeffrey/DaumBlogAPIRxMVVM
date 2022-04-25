//
//  DKBlog.swift
//  RxSwiftPractice2
//
//  Created by Seonghwan on 2022/02/03.
//

import Foundation

struct DKBlog: Decodable {
    let documents: [DKDocument]
}

struct DKDocument: Decodable {
    let title: String?
    let name: String?
    let thumbnail: String?
    let datetime: Date?
    
    enum Codingkeys: String, CodingKey {
        case title, thumbnail, datetime
        case name = "blogname"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: Codingkeys.self)
        self.title = try? values.decode(String?.self, forKey: .title)?
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
            .replacingOccurrences(of: "&[^;]+;", with: "", options: .regularExpression, range: nil)
        self.name = try? values.decode(String?.self, forKey: .name)
        self.thumbnail = try? values.decode(String?.self, forKey: .thumbnail)
        self.datetime = Date.parse(values, key: .datetime)
    }
}

extension Date {
    static func parse<T: CodingKey>(_ values: KeyedDecodingContainer<T>, key: T) -> Date? {
        guard let dateString = try? values.decode(String?.self, forKey: key),
              let date = from(dateString: dateString) else {
                  return nil
              }
        return date
    }
    
    static func from(dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX" //Kakao datetime format
        dateFormatter.locale = Locale(identifier: "ko_kr")
        if let date = dateFormatter.date(from: dateString) {
            return date
        }
        return nil
    }
    
}
