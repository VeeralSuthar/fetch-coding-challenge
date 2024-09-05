//
//  ContentView.swift
//  fetch
//
//  Created by Veeral Suthar on 9/3/24.
//

import SwiftUI

struct MealListView: View {
  var category: String
  @State var meals: [MealModel] = []
  @State var meal: MealModel? = nil
  var body: some View {
    VStack {
      Text("\(category) List")
        .font(.title2)
      ScrollView {
        ForEach(meals.indices, id: \.self) { i in
          NavigationLink(destination: MealDetailView(meal: meals[i])) {
            MealListCell(meal: meals[i])
              .foregroundStyle(.black)
          }
        }
      }
      .padding()
    }
    .padding()
    .task {
      let api = ApiManager()
      guard let url = MealDB.filter.byCategory("\(category)") else { return }
      if let response: MealContainer = try? await api.fetchData(url: url) {
        self.meals = response.meals
      }
    }
  }

// MARK: Meal List Cell

  /// Contains a hack around the NSURLErrorCancelled issue that happens if you 
  /// navigate away to a cell before all of the Images properly load.
  ///
  ///       AsyncImage(url: url) { phase in
  ///         case .failure(let error):
  ///          if error._code: == -999 { //NSURLErrorCancelled
  ///           // recall AsyncImage here
  ///          }
  ///       }
  ///

  struct MealListCell: View {
    var meal: MealModel
    var body: some View {
      HStack {
        AppAsyncImage(url: meal.thumbnailURL, width: 100, height: 100)
        .frame(width: 100, height: 100)
        Spacer()
        VStack {
          Text("\(meal.name)")
            .font(.title3)
            .multilineTextAlignment(.center)
            .padding(.top, 5)
          Spacer()
          HStack {
            Spacer()
            VStack {
              Image(systemName: "arrowshape.right.circle.fill")
                .resizable()
                .frame(width: 15, height: 15)
                .foregroundStyle(.gray)
              Text("\(meal.mealID)")
                .font(.footnote)
                .foregroundStyle(.black.opacity(0.75))
                .padding(.bottom, 2.5)
            }
          }
        }
      }
      .padding(.horizontal, 2.5)
      .frame(maxWidth: .infinity)
      .frame(height: 110)
      .border(.black)
      .padding(.horizontal, 2.5)
    }
  }
}

#Preview {
  MealListView(category: "Dessert")
}


