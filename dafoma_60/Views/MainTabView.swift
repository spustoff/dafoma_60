//
//  MainTabView.swift
//  FortGourmetMuse
//
//  Created by Вячеслав on 10/9/25.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var recipeViewModel = RecipeViewModel()
    @StateObject private var mealPlannerViewModel = MealPlannerViewModel()
    @StateObject private var restaurantViewModel = RestaurantExplorerViewModel()
    @StateObject private var challengeViewModel = ChallengeViewModel()
    
    var body: some View {
        TabView {
            RecipeDiscoveryView()
                .environmentObject(recipeViewModel)
                .environmentObject(challengeViewModel)
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Recipes")
                }
            
            MealPlannerView()
                .environmentObject(mealPlannerViewModel)
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Meal Plan")
                }
            
            RestaurantExplorerView()
                .environmentObject(restaurantViewModel)
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Explore")
                }
            
            ChallengeView()
                .environmentObject(challengeViewModel)
                .tabItem {
                    Image(systemName: "trophy.fill")
                    Text("Challenges")
                }
            
            SettingsView()
                .environmentObject(challengeViewModel)
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
        }
        .accentColor(.primaryRed)
    }
}

