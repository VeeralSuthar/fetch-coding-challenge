//
//  fetchApp.swift
//  fetch
//
//  Created by Veeral Suthar on 9/3/24.
//

import SwiftUI

@main
struct fetchApp: App {
    var body: some Scene {
        WindowGroup {
          NavigationStack {
            MealListView(category: "Dessert")
          }
          .navigationTitle("MealDB")
        }
    }
}
