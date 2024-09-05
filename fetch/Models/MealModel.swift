//
//  MealModel.swift
//  fetch
//
//  Created by Veeral Suthar on 9/3/24.
//

import Foundation

// MARK: MODEL NOTES
/// Ignoring the following Response values:
///   - "strSource"
///   - "strImageSource"
///   - "strCreativeCommonsConfirmed"
///   - "dateModified"

public struct MealContainer: Decodable {
  var meals: [MealModel]
}

public struct MealDetailContainer: Decodable {
  var meals: [MealDetailModel]
}

public typealias Ingredient = (name: String, measurement: String)
struct MealModel {

  var mealID: String
  var name: String

  public var thumbnailURL: URL?

  init(mealID: String, name: String, thumbnailURLString: String) {
    self.mealID = mealID
    self.name = name
    self.thumbnailURL = URL(string: thumbnailURLString)
  }

}

extension MealModel: Decodable {
  enum CodingKeys: String, CodingKey {
    case mealID = "idMeal"
    case name = "strMeal"
    case thumbnailURLString = "strMealThumb"
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.mealID = try container.decode(String.self, forKey: .mealID)
    self.name = try container.decode(String.self, forKey: .name)
    let thumbnailStr: String = try container.decode(String.self, forKey: .thumbnailURLString)
    self.thumbnailURL = URL(string: thumbnailStr)
  }
}

struct MealDetailModel {
  var overview: MealModel

  var category: String = ""
  var area: String = ""
  var instructions: [String] = []
  public var tags: [String] = []
  public var videoURL: URL?
  public var ingredients: [Ingredient] = []
}

extension MealDetailModel: Decodable {

  enum CodingKeys: String, CodingKey {
    case strDrinkAlternate
    case category = "strCategory"
    case area = "strArea"
    case instructionString = "strInstructions"
    case tagsString = "strTags"
    case videoURLString = "strYoutube"
    
  }

  struct DynamicCodingKeys: CodingKey {

    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
      self.stringValue = stringValue
      self.intValue = nil
    }

    init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }

    init?(prefix: String, intValue: Int) {
        self.stringValue = "\(prefix)\(intValue)"
        self.intValue = intValue
    }
  }

  func decodeDynamicKeys(from decoder: Decoder, prefix: String, count: Int) throws -> [String] {
          var results: [String] = []
          let container = try decoder.container(keyedBy: DynamicCodingKeys.self)

          for i in 1...count {
            if let key = DynamicCodingKeys(prefix: prefix, intValue: i),
                 let value = try? container.decodeIfPresent(String.self, forKey: key) ?? "" {
                  results.append(value)
              }
          }
          return results
      }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.overview = try MealModel(from: decoder)
    self.category = try container.decode(String.self, forKey: .category)
    self.area = try container.decode(String.self, forKey: .area)
    let videoURLString = try container.decode(String.self, forKey: .videoURLString)
    self.videoURL = URL(string: videoURLString)
    let names = try decodeDynamicKeys(from: decoder, prefix: "strIngredient", count: 20)
    let measurements = try decodeDynamicKeys(from: decoder, prefix: "strMeasure", count: 20)
    for (name, measurement) in zip(names, measurements) {
      if (!name.isEmpty && !measurement.isEmpty) {
        if !self.ingredients.contains(where: { $0.name == name }) {
          self.ingredients.append((name: name, measurement: measurement))
        }
      }
    }
    let instructions = try container.decode(String.self, forKey: .instructionString)
    self.instructions = instructions.components(separatedBy: "\r\n")
}

}
