//
//  RecipeViewModel.swift
//  FortGourmetMuse
//
//  Created by Вячеслав on 10/9/25.
//

import Foundation
import Combine

@MainActor
class RecipeViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var filteredRecipes: [Recipe] = []
    @Published var searchText: String = ""
    @Published var selectedCuisine: String = "All"
    @Published var selectedDifficulty: Recipe.DifficultyLevel?
    @Published var maxCookingTime: Int = 120
    @Published var isLoading: Bool = false
    @Published var favoriteRecipes: Set<UUID> = []
    
    private var cancellables = Set<AnyCancellable>()
    
    let cuisines = ["All", "Thai", "Mediterranean", "Japanese", "Indian", "Italian", "Mexican", "Chinese", "French", "American"]
    
    init() {
        loadRecipes()
        setupSearchAndFilters()
        loadFavorites()
    }
    
    private func setupSearchAndFilters() {
        Publishers.CombineLatest4($searchText, $selectedCuisine, $selectedDifficulty, $maxCookingTime)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] searchText, cuisine, difficulty, maxTime in
                self?.filterRecipes(searchText: searchText, cuisine: cuisine, difficulty: difficulty, maxTime: maxTime)
            }
            .store(in: &cancellables)
    }
    
    private func loadRecipes() {
        isLoading = true
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.recipes = Recipe.sampleRecipes
            self.filteredRecipes = self.recipes
            self.isLoading = false
        }
    }
    
    private func filterRecipes(searchText: String, cuisine: String, difficulty: Recipe.DifficultyLevel?, maxTime: Int) {
        var filtered = recipes
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { recipe in
                recipe.name.localizedCaseInsensitiveContains(searchText) ||
                recipe.description.localizedCaseInsensitiveContains(searchText) ||
                recipe.ingredients.contains { $0.name.localizedCaseInsensitiveContains(searchText) } ||
                recipe.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // Filter by cuisine
        if cuisine != "All" {
            filtered = filtered.filter { $0.cuisine == cuisine }
        }
        
        // Filter by difficulty
        if let difficulty = difficulty {
            filtered = filtered.filter { $0.difficulty == difficulty }
        }
        
        // Filter by cooking time
        filtered = filtered.filter { $0.cookingTime <= maxTime }
        
        filteredRecipes = filtered
    }
    
    func toggleFavorite(_ recipe: Recipe) {
        if favoriteRecipes.contains(recipe.id) {
            favoriteRecipes.remove(recipe.id)
        } else {
            favoriteRecipes.insert(recipe.id)
        }
        saveFavorites()
    }
    
    func isFavorite(_ recipe: Recipe) -> Bool {
        favoriteRecipes.contains(recipe.id)
    }
    
    private func saveFavorites() {
        let favoriteIds = Array(favoriteRecipes).map { $0.uuidString }
        UserDefaults.standard.set(favoriteIds, forKey: "favoriteRecipes")
    }
    
    private func loadFavorites() {
        let favoriteIds = UserDefaults.standard.stringArray(forKey: "favoriteRecipes") ?? []
        favoriteRecipes = Set(favoriteIds.compactMap { UUID(uuidString: $0) })
    }
    
    func clearFilters() {
        searchText = ""
        selectedCuisine = "All"
        selectedDifficulty = nil
        maxCookingTime = 120
    }
    
    func getRecipesByTag(_ tag: String) -> [Recipe] {
        recipes.filter { $0.tags.contains(tag) }
    }
    
    func getPopularRecipes() -> [Recipe] {
        recipes.sorted { $0.rating > $1.rating }.prefix(5).map { $0 }
    }
    
    func getQuickRecipes() -> [Recipe] {
        recipes.filter { $0.cookingTime <= 30 }.sorted { $0.cookingTime < $1.cookingTime }
    }
}

