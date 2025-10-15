//
//  RecipeDiscoveryView.swift
//  FortGourmetMuse
//
//  Created by Вячеслав on 10/9/25.
//

import SwiftUI

struct RecipeDiscoveryView: View {
    @EnvironmentObject var viewModel: RecipeViewModel
    @EnvironmentObject var challengeViewModel: ChallengeViewModel
    @State private var showingFilters = false
    @State private var selectedRecipe: Recipe?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                SearchBar(text: $viewModel.searchText)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                if viewModel.isLoading {
                    LoadingView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            // Quick categories
                            QuickCategoriesView()
                                .environmentObject(viewModel)
                            
                            // Featured recipes
                            FeaturedRecipesSection()
                                .environmentObject(viewModel)
                            
                            // All recipes
                            RecipeListSection()
                                .environmentObject(viewModel)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingFilters = true }) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.primaryRed)
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                RecipeFiltersView()
                    .environmentObject(viewModel)
            }
            .sheet(item: $selectedRecipe) { recipe in
                RecipeDetailView(recipe: recipe)
                    .environmentObject(viewModel)
                    .environmentObject(challengeViewModel)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowRecipeDetail"))) { notification in
            if let recipe = notification.object as? Recipe {
                selectedRecipe = recipe
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.textSecondary)
            
            TextField("Search recipes, ingredients...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.textSecondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.cardBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct QuickCategoriesView: View {
    @EnvironmentObject var viewModel: RecipeViewModel
    
    private let categories = [
        ("Quick", "clock.fill", Color.successGreen),
        ("Popular", "star.fill", Color.accentYellow),
        ("Healthy", "leaf.fill", Color.successGreen),
        ("Asian", "globe.asia.australia.fill", Color.primaryRed)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Access")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories, id: \.0) { category in
                        CategoryCard(
                            title: category.0,
                            icon: category.1,
                            color: category.2
                        ) {
                            handleCategoryTap(category.0)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    private func handleCategoryTap(_ category: String) {
        switch category {
        case "Quick":
            viewModel.maxCookingTime = 30
        case "Popular":
            viewModel.clearFilters()
        case "Healthy":
            viewModel.searchText = "healthy"
        case "Asian":
            viewModel.selectedCuisine = "Thai"
        default:
            break
        }
    }
}

struct CategoryCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
            }
            .frame(width: 80, height: 80)
            .background(Color.cardBackground)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FeaturedRecipesSection: View {
    @EnvironmentObject var viewModel: RecipeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Featured Recipes")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Button("See All") {
                    viewModel.clearFilters()
                }
                .font(.subheadline)
                .foregroundColor(.primaryRed)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.getPopularRecipes(), id: \.id) { recipe in
                        FeaturedRecipeCard(recipe: recipe)
                            .environmentObject(viewModel)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
}

struct FeaturedRecipeCard: View {
    let recipe: Recipe
    @EnvironmentObject var viewModel: RecipeViewModel
    
    var body: some View {
        Button(action: {
            NotificationCenter.default.post(name: NSNotification.Name("ShowRecipeDetail"), object: recipe)
        }) {
            VStack(alignment: .leading, spacing: 8) {
                // Image placeholder
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient.primaryGradient)
                    .frame(width: 200, height: 120)
                    .overlay(
                        VStack {
                            Image(systemName: "fork.knife")
                                .font(.title)
                                .foregroundColor(.white)
                            Text(recipe.cuisine)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                        .lineLimit(2)
                    
                    HStack {
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                        Text("\(recipe.cookingTime) min")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                        
                        Spacer()
                        
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.accentYellow)
                            Text(String(format: "%.1f", recipe.rating))
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
            .frame(width: 200)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RecipeListSection: View {
    @EnvironmentObject var viewModel: RecipeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("All Recipes")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Text("\(viewModel.filteredRecipes.count) recipes")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(viewModel.filteredRecipes, id: \.id) { recipe in
                    RecipeRowCard(recipe: recipe)
                        .environmentObject(viewModel)
                }
            }
        }
    }
}

struct RecipeRowCard: View {
    let recipe: Recipe
    @EnvironmentObject var viewModel: RecipeViewModel
    
    var body: some View {
        Button(action: {
            NotificationCenter.default.post(name: NSNotification.Name("ShowRecipeDetail"), object: recipe)
        }) {
            HStack(spacing: 12) {
                // Image placeholder
                RoundedRectangle(cornerRadius: 8)
                    .fill(LinearGradient.primaryGradient)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "fork.knife")
                            .font(.title2)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Text(recipe.description)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        DifficultyBadge(difficulty: recipe.difficulty)
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            HStack(spacing: 2) {
                                Image(systemName: "clock")
                                    .font(.caption)
                                Text("\(recipe.cookingTime)m")
                                    .font(.caption)
                            }
                            .foregroundColor(.textSecondary)
                            
                            HStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .font(.caption)
                                    .foregroundColor(.accentYellow)
                                Text(String(format: "%.1f", recipe.rating))
                                    .font(.caption)
                                    .foregroundColor(.textSecondary)
                            }
                        }
                    }
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.toggleFavorite(recipe)
                }) {
                    Image(systemName: viewModel.isFavorite(recipe) ? "heart.fill" : "heart")
                        .font(.title3)
                        .foregroundColor(viewModel.isFavorite(recipe) ? .dangerRed : .textSecondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(12)
            .background(Color.cardBackground)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DifficultyBadge: View {
    let difficulty: Recipe.DifficultyLevel
    
    var body: some View {
        Text(difficulty.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(Color(hex: difficulty.color))
            .cornerRadius(4)
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.primaryRed)
            
            Text("Loading delicious recipes...")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    RecipeDiscoveryView()
        .environmentObject(RecipeViewModel())
}

