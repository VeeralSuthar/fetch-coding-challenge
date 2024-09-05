//
//  HomeView.swift
//  fetch
//
//  Created by Veeral Suthar on 9/5/24.
//

import SwiftUI

struct MealDetailView: View {
  @State var meal: MealDetailModel? = nil
  @State private var tabSelection: MealDetailTab = .ingredients
  init(meal: MealModel) {
    _meal = State(initialValue: MealDetailModel(overview: meal))
  }

  private enum MealDetailTab: String, CaseIterable {

    case ingredients = "Ingredients"
    case instructions = "Instructions"
  }
  var body: some View {
      VStack {
        if let meal {
          Text("\(meal.overview.name)")
            .font(.title2)
          AppAsyncImage(url: meal.overview.thumbnailURL, width: 300, height: 300)
            .frame(width: 300, height: 300)
          Picker("", selection: $tabSelection) {
            ForEach(MealDetailTab.allCases, id: \.self) { tab in
              Text("\(tab.rawValue)")
            }
          }
          .pickerStyle(.segmented)
          Spacer()
          switch tabSelection {
          case .ingredients:
            IngredientList(ingredients: meal.ingredients)
          case .instructions:
            InstructionView(meal: meal)
          }
        }
      }
    .task {
      let api = ApiManager()
      guard let url = MealDB.lookup.byId(meal?.overview.mealID ?? "") else { return }
      print("\(url)")
      do {
        if let container: MealDetailContainer = try await api.fetchData(url: url),
           let meal: MealDetailModel = container.meals.first {
          self.meal = meal
        }
      }
      catch {
        print("\(error)")
      }
    }
  }

  struct IngredientList: View {
    var ingredients: [Ingredient]
    var body: some View {
      VStack {
        Text("Ingredients")
          .font(.title3)
          .padding(.top, 5)
        ScrollView {
          ForEach(ingredients, id: \.name) { ingredient in
            IngredientCell(ingredient: ingredient)
          }
        }
      }
    }

    struct IngredientCell: View {
      var ingredient: Ingredient
      var body: some View {
        HStack {
          Text("\(ingredient.name)")
            .bold()
            .padding(.leading, 20)
          Text("  -  \(ingredient.measurement)")
        }
        .frame(maxWidth: .infinity, idealHeight: 30, alignment: .leading)
        .border(.black)
        .padding(.horizontal, 10)
      }
    }
  }
  struct InstructionView: View {
    var meal: MealDetailModel
    var body: some View {
      VStack {
        Text("Instructions")
          .font(.title3)
          .padding(.top, 5)
        ScrollView {
          ForEach(meal.instructions.indices, id: \.self) { index in
              VStack {
                HStack {
                  Text("Step \(index + 1)")
                    .fontWeight(.semibold)
                  Spacer()
                }
                Text(meal.instructions[index])
                  .font(.footnote)
                  .multilineTextAlignment(.leading)
                  .lineLimit(10)
              }
              .padding(2.5)
              .border(.black)
            }
        }
        if let videoURL = meal.videoURL {
          Link("Instructional Video", destination: videoURL)
        }
      }
      .padding(.horizontal, 10)
    }
  }
}

