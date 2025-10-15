//
//  MealPlannerViewModel.swift
//  FortGourmetMuse
//
//  Created by Вячеслав on 10/9/25.
//

import Foundation
import Combine

@MainActor
class MealPlannerViewModel: ObservableObject {
    @Published var mealPlans: [MealPlan] = []
    @Published var currentMealPlan: MealPlan?
    @Published var selectedDietaryPreferences: Set<DietaryPreference> = []
    @Published var targetCalories: Int = 2000
    @Published var numberOfDays: Int = 7
    @Published var isGenerating: Bool = false
    @Published var availableIngredients: [String] = []
    @Published var excludedIngredients: [String] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadMealPlans()
        loadPreferences()
    }
    
    private func loadMealPlans() {
        // Simulate loading from storage
        mealPlans = MealPlan.sampleMealPlans
        currentMealPlan = mealPlans.first
    }
    
    private func loadPreferences() {
        // Load saved dietary preferences
        if let savedPreferences = UserDefaults.standard.array(forKey: "dietaryPreferences") as? [String] {
            selectedDietaryPreferences = Set(savedPreferences.compactMap { DietaryPreference(rawValue: $0) })
        }
        
        targetCalories = UserDefaults.standard.object(forKey: "targetCalories") as? Int ?? 2000
        numberOfDays = UserDefaults.standard.object(forKey: "numberOfDays") as? Int ?? 7
        
        availableIngredients = UserDefaults.standard.stringArray(forKey: "availableIngredients") ?? []
        excludedIngredients = UserDefaults.standard.stringArray(forKey: "excludedIngredients") ?? []
    }
    
    private func savePreferences() {
        UserDefaults.standard.set(selectedDietaryPreferences.map { $0.rawValue }, forKey: "dietaryPreferences")
        UserDefaults.standard.set(targetCalories, forKey: "targetCalories")
        UserDefaults.standard.set(numberOfDays, forKey: "numberOfDays")
        UserDefaults.standard.set(availableIngredients, forKey: "availableIngredients")
        UserDefaults.standard.set(excludedIngredients, forKey: "excludedIngredients")
    }
    
    func generateMealPlan() {
        isGenerating = true
        
        // Simulate AI-powered meal plan generation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let startDate = Date()
            let endDate = Calendar.current.date(byAdding: .day, value: self.numberOfDays, to: startDate) ?? Date()
            
            let newMealPlan = MealPlan(
                name: "AI Generated Plan",
                description: "Personalized meal plan based on your preferences and dietary requirements",
                startDate: startDate,
                endDate: endDate,
                meals: self.generateDayMeals(for: self.numberOfDays, startingFrom: startDate),
                dietaryPreferences: Array(self.selectedDietaryPreferences),
                totalCalories: self.targetCalories * self.numberOfDays,
                estimatedCost: Double(self.numberOfDays) * 8.99
            )
            
            self.mealPlans.insert(newMealPlan, at: 0)
            self.currentMealPlan = newMealPlan
            self.isGenerating = false
            self.savePreferences()
        }
    }
    
    private func generateDayMeals(for days: Int, startingFrom startDate: Date) -> [DayMeal] {
        var dayMeals: [DayMeal] = []
        let availableRecipes = Recipe.sampleRecipes
        
        for day in 0..<days {
            let date = Calendar.current.date(byAdding: .day, value: day, to: startDate) ?? startDate
            
            // Simple algorithm to assign recipes based on preferences
            let breakfast = availableRecipes.randomElement()
            let lunch = availableRecipes.randomElement()
            let dinner = availableRecipes.randomElement()
            
            let dayMeal = DayMeal(
                date: date,
                breakfast: breakfast,
                lunch: lunch,
                dinner: dinner,
                snacks: []
            )
            
            dayMeals.append(dayMeal)
        }
        
        return dayMeals
    }
    
    func addDietaryPreference(_ preference: DietaryPreference) {
        selectedDietaryPreferences.insert(preference)
        savePreferences()
    }
    
    func removeDietaryPreference(_ preference: DietaryPreference) {
        selectedDietaryPreferences.remove(preference)
        savePreferences()
    }
    
    func addAvailableIngredient(_ ingredient: String) {
        if !availableIngredients.contains(ingredient) {
            availableIngredients.append(ingredient)
            savePreferences()
        }
    }
    
    func removeAvailableIngredient(_ ingredient: String) {
        availableIngredients.removeAll { $0 == ingredient }
        savePreferences()
    }
    
    func addExcludedIngredient(_ ingredient: String) {
        if !excludedIngredients.contains(ingredient) {
            excludedIngredients.append(ingredient)
            savePreferences()
        }
    }
    
    func removeExcludedIngredient(_ ingredient: String) {
        excludedIngredients.removeAll { $0 == ingredient }
        savePreferences()
    }
    
    func deleteMealPlan(_ mealPlan: MealPlan) {
        mealPlans.removeAll { $0.id == mealPlan.id }
        if currentMealPlan?.id == mealPlan.id {
            currentMealPlan = mealPlans.first
        }
    }
    
    func duplicateMealPlan(_ mealPlan: MealPlan) {
        let duplicated = MealPlan(
            name: "\(mealPlan.name) (Copy)",
            description: mealPlan.description,
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: mealPlan.duration, to: Date()) ?? Date(),
            meals: mealPlan.meals.map { dayMeal in
                DayMeal(
                    date: Calendar.current.date(byAdding: .day, value: mealPlan.meals.firstIndex(where: { $0.id == dayMeal.id }) ?? 0, to: Date()) ?? Date(),
                    breakfast: dayMeal.breakfast,
                    lunch: dayMeal.lunch,
                    dinner: dayMeal.dinner,
                    snacks: dayMeal.snacks
                )
            },
            dietaryPreferences: mealPlan.dietaryPreferences,
            totalCalories: mealPlan.totalCalories,
            estimatedCost: mealPlan.estimatedCost
        )
        
        mealPlans.insert(duplicated, at: 0)
    }
}

