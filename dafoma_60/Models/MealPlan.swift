//
//  MealPlan.swift
//  FortGourmetMuse
//
//  Created by Вячеслав on 10/9/25.
//

import Foundation

struct MealPlan: Identifiable, Codable {
    let id = UUID()
    let name: String
    let description: String
    let startDate: Date
    let endDate: Date
    let meals: [DayMeal]
    let dietaryPreferences: [DietaryPreference]
    let totalCalories: Int
    let estimatedCost: Double
    
    var duration: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }
}

struct DayMeal: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let breakfast: Recipe?
    let lunch: Recipe?
    let dinner: Recipe?
    let snacks: [Recipe]
    
    var totalCalories: Int {
        let breakfastCal = breakfast?.nutritionInfo.calories ?? 0
        let lunchCal = lunch?.nutritionInfo.calories ?? 0
        let dinnerCal = dinner?.nutritionInfo.calories ?? 0
        let snacksCal = snacks.reduce(0) { $0 + $1.nutritionInfo.calories }
        return breakfastCal + lunchCal + dinnerCal + snacksCal
    }
}

enum DietaryPreference: String, CaseIterable, Codable {
    case vegetarian = "Vegetarian"
    case vegan = "Vegan"
    case glutenFree = "Gluten-Free"
    case dairyFree = "Dairy-Free"
    case lowCarb = "Low-Carb"
    case keto = "Keto"
    case paleo = "Paleo"
    case mediterranean = "Mediterranean"
    
    var icon: String {
        switch self {
        case .vegetarian: return "leaf.fill"
        case .vegan: return "leaf.circle.fill"
        case .glutenFree: return "g.circle.fill"
        case .dairyFree: return "drop.fill"
        case .lowCarb: return "minus.circle.fill"
        case .keto: return "k.circle.fill"
        case .paleo: return "p.circle.fill"
        case .mediterranean: return "sun.max.fill"
        }
    }
    
    var color: String {
        switch self {
        case .vegetarian, .vegan: return "#1ed55f"
        case .glutenFree, .dairyFree: return "#ffc934"
        case .lowCarb, .keto: return "#eb262f"
        case .paleo, .mediterranean: return "#dfb492"
        }
    }
}

// Sample data
extension MealPlan {
    static let sampleMealPlans: [MealPlan] = [
        MealPlan(
            name: "Mediterranean Week",
            description: "A week of healthy Mediterranean cuisine focusing on fresh vegetables, olive oil, and lean proteins",
            startDate: Calendar.current.date(byAdding: .day, value: 0, to: Date()) ?? Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
            meals: [
                DayMeal(
                    date: Date(),
                    breakfast: Recipe.sampleRecipes[1],
                    lunch: Recipe.sampleRecipes[0],
                    dinner: Recipe.sampleRecipes[2],
                    snacks: []
                )
            ],
            dietaryPreferences: [.mediterranean, .glutenFree],
            totalCalories: 1800,
            estimatedCost: 45.99
        )
    ]
}

