//
//  File.swift
//  fetch
//
//  Created by Veeral Suthar on 9/3/24.
//

import Foundation

/// API Class to easily access the endpoints.
/// Would ideally be better fleshed out, but the API docs weren't that much to work with.
public protocol API: RawRepresentable {
  static var baseURL: URL { get }
}

public enum MealDB: API {
  
  public static let baseURL = URL(string: "https://themealdb.com/api/json/v1/1")!
  // ^^ Developer ID would not be hard coded into the domain string
  public var tst: URL {
    MealDB.baseURL.appending(queryItems: [URLQueryItem(name: "c", value: "PUTHERE")])
  }
  case search
  case filter
  case random
  case lookup



  public var rawValue: String {
    switch self {
    case .filter:
      return "filter.php"
    case .search:
      return "search.php"
    case .random:
      return "random.php"
    case .lookup:
      return "lookup.php"
    }
  }

  public func byCategory(_ category: String) -> URL? {
    let query = URLQueryItem(name: "c", value: "\(category)")

    return self.url.appending(queryItems: [query])
  }

  public func byId(_ id: String) -> URL? {
    let query = URLQueryItem(name: "i", value: id)
    return self.url.appending(queryItems: [query])
  }

}

public class ApiManager {

  public func fetchData<T: Decodable>(url: URL) async throws -> T? {
    do {
      let (data, response) = try await URLSession.shared.data(from: url)
//      if let json = String(data: data, encoding: .utf8) {
//        print("\(json)")
//      }
      guard let response = response as? HTTPURLResponse else {
        throw ApiError.badResponse
      }
      guard response.statusCode >= 200, response.statusCode < 300 else {
        throw ApiError.badStatus
      }
      return await decodeDataIntoModel(data: data)
    }
    catch ApiError.badResponse {
      print("Bad response.")
    }
    catch ApiError.badStatus {
      print("Bad HTTP status.")
    }
    return nil
  }

  private func decodeDataIntoModel<T: Decodable>(data: Data) async -> T? {
    do {
      guard let decodedResponse = try? JSONDecoder().decode(T.self, from: data) else {
        throw ApiError.failedToDecode
      }
      return decodedResponse
    }
    catch ApiError.failedToDecode {
      print("Failed to decode the response.")
    }
    catch {
      print("Unknown Error: \(error.localizedDescription)")
    }
    return nil
  }
}


extension ApiManager {
  enum ApiError: Error {
    case badResponse, badStatus, failedToDecode
  }
}


extension RawRepresentable where RawValue == String, Self: API {
  public var url: URL { Self.baseURL.appendingPathComponent(rawValue) }

  public init?(rawValue: String) { nil }
}
