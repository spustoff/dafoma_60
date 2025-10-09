//
//  Recipe.swift
//  FortGourmetMuse
//
//  Created by Вячеслав on 10/9/25.
//

import Foundation

struct Recipe: Identifiable, Codable, Hashable {
    let id = UUID()
    let name: String
    let description: String
    let cuisine: String
    let difficulty: DifficultyLevel
    let cookingTime: Int // in minutes
    let servings: Int
    let ingredients: [Ingredient]
    let instructions: [String]
    let imageURL: String?
    let nutritionInfo: NutritionInfo
    let tags: [String]
    let rating: Double
    let reviewCount: Int
    
    enum DifficultyLevel: String, CaseIterable, Codable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
        
        var color: String {
            switch self {
            case .easy: return "#1ed55f"
            case .medium: return "#ffc934"
            case .hard: return "#eb262f"
            }
        }
    }
}

struct Ingredient: Identifiable, Codable, Hashable {
    let id = UUID()
    let name: String
    let amount: String
    let unit: String
    
    var displayText: String {
        "\(amount) \(unit) \(name)"
    }
}

struct NutritionInfo: Codable, Hashable {
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double
}

// Sample data for the app
extension Recipe {
    static let sampleRecipes: [Recipe] = [
        Recipe(
            name: "Authentic Pad Thai",
            description: "Traditional Thai stir-fried noodles with tamarind, fish sauce, and fresh herbs",
            cuisine: "Thai",
            difficulty: .medium,
            cookingTime: 30,
            servings: 4,
            ingredients: [
                Ingredient(name: "Rice noodles", amount: "8", unit: "oz"),
                Ingredient(name: "Shrimp", amount: "1", unit: "lb"),
                Ingredient(name: "Bean sprouts", amount: "2", unit: "cups"),
                Ingredient(name: "Eggs", amount: "3", unit: "large"),
                Ingredient(name: "Tamarind paste", amount: "3", unit: "tbsp"),
                Ingredient(name: "Fish sauce", amount: "2", unit: "tbsp"),
                Ingredient(name: "Palm sugar", amount: "2", unit: "tbsp"),
                Ingredient(name: "Peanuts", amount: "1/4", unit: "cup"),
                Ingredient(name: "Lime", amount: "2", unit: "wedges")
            ],
            instructions: [
                "Soak rice noodles in warm water until soft, about 15 minutes",
                "Heat oil in a large wok or skillet over high heat",
                "Add shrimp and cook until pink, about 2 minutes",
                "Push shrimp to one side, add eggs and scramble",
                "Add drained noodles, tamarind paste, fish sauce, and palm sugar",
                "Toss everything together for 2-3 minutes",
                "Add bean sprouts and cook for another minute",
                "Serve with crushed peanuts and lime wedges"
            ],
            imageURL: nil,
            nutritionInfo: NutritionInfo(calories: 420, protein: 28.5, carbs: 45.2, fat: 12.8, fiber: 3.2),
            tags: ["Asian", "Noodles", "Seafood", "Quick"],
            rating: 4.7,
            reviewCount: 342
        ),
        Recipe(
            name: "Mediterranean Quinoa Bowl",
            description: "Healthy quinoa bowl with fresh vegetables, feta cheese, and lemon tahini dressing",
            cuisine: "Mediterranean",
            difficulty: .easy,
            cookingTime: 25,
            servings: 2,
            ingredients: [
                Ingredient(name: "Quinoa", amount: "1", unit: "cup"),
                Ingredient(name: "Cherry tomatoes", amount: "1", unit: "cup"),
                Ingredient(name: "Cucumber", amount: "1", unit: "medium"),
                Ingredient(name: "Red onion", amount: "1/4", unit: "cup"),
                Ingredient(name: "Feta cheese", amount: "1/2", unit: "cup"),
                Ingredient(name: "Kalamata olives", amount: "1/4", unit: "cup"),
                Ingredient(name: "Tahini", amount: "2", unit: "tbsp"),
                Ingredient(name: "Lemon juice", amount: "2", unit: "tbsp"),
                Ingredient(name: "Olive oil", amount: "2", unit: "tbsp")
            ],
            instructions: [
                "Cook quinoa according to package instructions",
                "Dice cucumber and halve cherry tomatoes",
                "Thinly slice red onion",
                "Whisk together tahini, lemon juice, and olive oil",
                "Combine cooked quinoa with vegetables",
                "Top with feta cheese and olives",
                "Drizzle with tahini dressing and serve"
            ],
            imageURL: nil,
            nutritionInfo: NutritionInfo(calories: 385, protein: 16.2, carbs: 42.1, fat: 18.5, fiber: 6.8),
            tags: ["Healthy", "Vegetarian", "Mediterranean", "Bowl"],
            rating: 4.5,
            reviewCount: 128
        ),
        Recipe(
            name: "Japanese Chicken Teriyaki",
            description: "Tender chicken glazed with homemade teriyaki sauce, served with steamed rice",
            cuisine: "Japanese",
            difficulty: .easy,
            cookingTime: 20,
            servings: 4,
            ingredients: [
                Ingredient(name: "Chicken thighs", amount: "2", unit: "lbs"),
                Ingredient(name: "Soy sauce", amount: "1/4", unit: "cup"),
                Ingredient(name: "Mirin", amount: "2", unit: "tbsp"),
                Ingredient(name: "Brown sugar", amount: "2", unit: "tbsp"),
                Ingredient(name: "Garlic", amount: "2", unit: "cloves"),
                Ingredient(name: "Ginger", amount: "1", unit: "tbsp"),
                Ingredient(name: "Sesame oil", amount: "1", unit: "tsp"),
                Ingredient(name: "Green onions", amount: "2", unit: "stalks"),
                Ingredient(name: "Sesame seeds", amount: "1", unit: "tbsp")
            ],
            instructions: [
                "Mix soy sauce, mirin, brown sugar, minced garlic, and ginger",
                "Heat sesame oil in a large skillet over medium-high heat",
                "Cook chicken thighs skin-side down for 5 minutes",
                "Flip chicken and cook for another 4 minutes",
                "Pour teriyaki sauce over chicken",
                "Simmer until sauce thickens, about 3 minutes",
                "Garnish with sliced green onions and sesame seeds",
                "Serve with steamed rice"
            ],
            imageURL: nil,
            nutritionInfo: NutritionInfo(calories: 320, protein: 35.2, carbs: 12.8, fat: 14.5, fiber: 0.5),
            tags: ["Asian", "Chicken", "Gluten-Free", "Quick"],
            rating: 4.8,
            reviewCount: 567
        )
    ]
}
