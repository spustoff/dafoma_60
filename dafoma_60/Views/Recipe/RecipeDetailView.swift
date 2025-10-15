//
//  RecipeDetailView.swift
//  FortGourmetMuse
//
//  Created by Вячеслав on 10/9/25.
//

import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    @EnvironmentObject var viewModel: RecipeViewModel
    @EnvironmentObject var challengeViewModel: ChallengeViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Header image
                    RecipeHeaderView(recipe: recipe)
                        .environmentObject(viewModel)
                    
                    // Content
                    VStack(alignment: .leading, spacing: 20) {
                        // Basic info
                        RecipeBasicInfoView(recipe: recipe)
                        
                        // Tabs
                        RecipeTabsView(recipe: recipe, selectedTab: $selectedTab)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                }
            }
            .ignoresSafeArea(edges: .top)
            .navigationBarHidden(true)
            .overlay(
                // Custom navigation bar
                VStack {
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.toggleFavorite(recipe)
                        }) {
                            Image(systemName: viewModel.isFavorite(recipe) ? "heart.fill" : "heart")
                                .font(.title2)
                                .foregroundColor(viewModel.isFavorite(recipe) ? .dangerRed : .white)
                                .frame(width: 40, height: 40)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 50)
                    
                    Spacer()
                }
                , alignment: .top
            )
//            .overlay(
                // Start Cooking button
//                VStack {
//                    Spacer()
//                    
//                    Button(action: {
//                        // In a real app, this would navigate to cooking mode
//                        // For now, we'll just mark it as completed
//                        challengeViewModel.completeRecipe(recipe)
//                    }) {
//                        Text("Start Cooking")
//                            .font(.headline)
//                            .fontWeight(.semibold)
//                            .foregroundColor(.white)
//                            .frame(maxWidth: .infinity)
//                            .frame(height: 50)
//                            .background(Color.successGreen)
//                            .cornerRadius(25)
//                    }
//                    .padding(.horizontal)
//                    .padding(.bottom, 34)
//                }
//            )
        }
    }
}

struct RecipeHeaderView: View {
    let recipe: Recipe
    @EnvironmentObject var viewModel: RecipeViewModel
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background gradient
            LinearGradient.primaryGradient
                .frame(height: 300)
            
            // Content overlay
            VStack(spacing: 12) {
                Image(systemName: "fork.knife")
                    .font(.system(size: 60, weight: .light))
                    .foregroundColor(.white)
                
                Text(recipe.cuisine)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(12)
            }
            .padding(.bottom, 40)
        }
    }
}

struct RecipeBasicInfoView: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title and rating
            VStack(alignment: .leading, spacing: 8) {
                Text(recipe.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                
                HStack {
                    HStack(spacing: 4) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < Int(recipe.rating) ? "star.fill" : "star")
                                .font(.caption)
                                .foregroundColor(.accentYellow)
                        }
                    }
                    
                    Text(String(format: "%.1f", recipe.rating))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.textPrimary)
                    
                    Text("(\(recipe.reviewCount) reviews)")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                    
                    Spacer()
                }
            }
            
            // Description
            Text(recipe.description)
                .font(.body)
                .foregroundColor(.textSecondary)
                .lineLimit(nil)
            
            // Quick stats
            HStack(spacing: 20) {
                RecipeStatView(
                    icon: "clock",
                    title: "Cook Time",
                    value: "\(recipe.cookingTime) min"
                )
                
                RecipeStatView(
                    icon: "person.2",
                    title: "Servings",
                    value: "\(recipe.servings)"
                )
                
                RecipeStatView(
                    icon: "flame",
                    title: "Difficulty",
                    value: recipe.difficulty.rawValue,
                    color: Color(hex: recipe.difficulty.color)
                )
            }
            
            // Tags
            if !recipe.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(recipe.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.primaryRed)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.primaryRed.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
    }
}

struct RecipeStatView: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    init(icon: String, title: String, value: String, color: Color = .textPrimary) {
        self.icon = icon
        self.title = title
        self.value = value
        self.color = color
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.textSecondary)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct RecipeTabsView: View {
    let recipe: Recipe
    @Binding var selectedTab: Int
    
    private let tabs = ["Ingredients", "Instructions", "Nutrition"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Tab selector
            HStack(spacing: 0) {
                ForEach(0..<tabs.count, id: \.self) { index in
                    Button(action: {
                        selectedTab = index
                    }) {
                        Text(tabs[index])
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(selectedTab == index ? .primaryRed : .textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                Rectangle()
                                    .fill(selectedTab == index ? Color.primaryRed.opacity(0.1) : Color.clear)
                            )
                    }
                }
            }
            .background(Color.cardBackground)
            .cornerRadius(8)
            
            // Tab content
            Group {
                switch selectedTab {
                case 0:
                    IngredientsTabView(ingredients: recipe.ingredients)
                case 1:
                    InstructionsTabView(instructions: recipe.instructions)
                case 2:
                    NutritionTabView(nutrition: recipe.nutritionInfo)
                default:
                    EmptyView()
                }
            }
        }
    }
}

struct IngredientsTabView: View {
    let ingredients: [Ingredient]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(ingredients, id: \.id) { ingredient in
                HStack {
                    Circle()
                        .fill(Color.primaryRed.opacity(0.2))
                        .frame(width: 8, height: 8)
                    
                    Text(ingredient.displayText)
                        .font(.body)
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                }
                .padding(.vertical, 4)
            }
        }
    }
}

struct InstructionsTabView: View {
    let instructions: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(Array(instructions.enumerated()), id: \.offset) { index, instruction in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index + 1)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24)
                        .background(Color.primaryRed)
                        .clipShape(Circle())
                    
                    Text(instruction)
                        .font(.body)
                        .foregroundColor(.textPrimary)
                        .lineLimit(nil)
                    
                    Spacer()
                }
            }
        }
    }
}

struct NutritionTabView: View {
    let nutrition: NutritionInfo
    
    var body: some View {
        VStack(spacing: 16) {
            // Calories
            HStack {
                Text("Calories")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Text("\(nutrition.calories)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryRed)
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
            
            // Macros
            VStack(spacing: 12) {
                NutritionRowView(label: "Protein", value: nutrition.protein, unit: "g", color: .successGreen)
                NutritionRowView(label: "Carbohydrates", value: nutrition.carbs, unit: "g", color: .accentYellow)
                NutritionRowView(label: "Fat", value: nutrition.fat, unit: "g", color: .primaryRed)
                NutritionRowView(label: "Fiber", value: nutrition.fiber, unit: "g", color: .secondaryBeige)
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
        }
    }
}

struct NutritionRowView: View {
    let label: String
    let value: Double
    let unit: String
    let color: Color
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(label)
                .font(.body)
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            Text(String(format: "%.1f%@", value, unit))
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.textPrimary)
        }
    }
}

#Preview {
    RecipeDetailView(recipe: Recipe.sampleRecipes[0])
        .environmentObject(RecipeViewModel())
}

