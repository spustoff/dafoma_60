//
//  MealPlanDetailView.swift
//  FortGourmetMuse
//
//  Created by Вячеслав on 10/9/25.
//

import SwiftUI

struct MealPlanDetailView: View {
    let mealPlan: MealPlan
    @EnvironmentObject var viewModel: MealPlannerViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedDay = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    MealPlanHeaderView(mealPlan: mealPlan)
                    
                    // Day selector
                    if mealPlan.meals.count > 1 {
                        DaySelectorView(
                            meals: mealPlan.meals,
                            selectedDay: $selectedDay
                        )
                    }
                    
                    // Day details
                    if selectedDay < mealPlan.meals.count {
                        DayMealDetailView(dayMeal: mealPlan.meals[selectedDay])
                    }
                    
                    // Nutrition summary
                    NutritionSummaryView(mealPlan: mealPlan)
                    
                    // Actions
                    MealPlanActionsView(mealPlan: mealPlan)
                        .environmentObject(viewModel)
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
            }
            .navigationTitle(mealPlan.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.textSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            viewModel.duplicateMealPlan(mealPlan)
                        }) {
                            Label("Duplicate Plan", systemImage: "doc.on.doc")
                        }
                        
                        Button(role: .destructive, action: {
                            viewModel.deleteMealPlan(mealPlan)
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Label("Delete Plan", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.primaryRed)
                    }
                }
            }
        }
    }
}

struct MealPlanHeaderView: View {
    let mealPlan: MealPlan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Description
            Text(mealPlan.description)
                .font(.body)
                .foregroundColor(.textSecondary)
                .lineLimit(nil)
            
            // Stats
            HStack(spacing: 20) {
                StatView(
                    icon: "calendar",
                    title: "Duration",
                    value: "\(mealPlan.duration) days",
                    color: .primaryRed
                )
                
                StatView(
                    icon: "flame",
                    title: "Total Calories",
                    value: "\(mealPlan.totalCalories)",
                    color: .accentYellow
                )
                
                StatView(
                    icon: "dollarsign.circle",
                    title: "Est. Cost",
                    value: String(format: "$%.0f", mealPlan.estimatedCost),
                    color: .successGreen
                )
            }
            
            // Dietary preferences
            if !mealPlan.dietaryPreferences.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Dietary Preferences")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(mealPlan.dietaryPreferences, id: \.self) { preference in
                                HStack(spacing: 4) {
                                    Image(systemName: preference.icon)
                                        .font(.caption)
                                    Text(preference.rawValue)
                                        .font(.caption)
                                }
                                .foregroundColor(Color(hex: preference.color))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(hex: preference.color).opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                }
            }
        }
    }
}

struct StatView: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
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

struct DaySelectorView: View {
    let meals: [DayMeal]
    @Binding var selectedDay: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Day")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<meals.count, id: \.self) { index in
                        DayButton(
                            day: index + 1,
                            date: meals[index].date,
                            isSelected: selectedDay == index
                        ) {
                            selectedDay = index
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
}

struct DayButton: View {
    let day: Int
    let date: Date
    let isSelected: Bool
    let action: () -> Void
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("Day \(day)")
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text(dayFormatter.string(from: date))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(dateFormatter.string(from: date))
                    .font(.caption)
            }
            .foregroundColor(isSelected ? .white : .textPrimary)
            .frame(width: 60, height: 80)
            .background(isSelected ? Color.primaryRed : Color.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.primaryRed : Color.divider, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DayMealDetailView: View {
    let dayMeal: DayMeal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Meals for \(dayFormatter.string(from: dayMeal.date))")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Text("\(dayMeal.totalCalories) cal")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primaryRed)
            }
            
            VStack(spacing: 12) {
                if let breakfast = dayMeal.breakfast {
                    MealRowView(mealType: "Breakfast", recipe: breakfast, icon: "sun.max.fill", color: .accentYellow)
                }
                
                if let lunch = dayMeal.lunch {
                    MealRowView(mealType: "Lunch", recipe: lunch, icon: "sun.haze.fill", color: .successGreen)
                }
                
                if let dinner = dayMeal.dinner {
                    MealRowView(mealType: "Dinner", recipe: dinner, icon: "moon.fill", color: .primaryRed)
                }
                
                if !dayMeal.snacks.isEmpty {
                    ForEach(dayMeal.snacks, id: \.id) { snack in
                        MealRowView(mealType: "Snack", recipe: snack, icon: "leaf.fill", color: .secondaryBeige)
                    }
                }
            }
        }
    }
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter
    }
}

struct MealRowView: View {
    let mealType: String
    let recipe: Recipe
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(mealType)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.textSecondary)
                
                Text(recipe.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                HStack {
                    Text("\(recipe.cookingTime) min")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    
                    Text("\(recipe.nutritionInfo.calories) cal")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
            }
            
            Spacer()
            
            Button(action: {
                NotificationCenter.default.post(name: NSNotification.Name("ShowRecipeDetail"), object: recipe)
            }) {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2)
                    .foregroundColor(.primaryRed)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
    }
}

struct NutritionSummaryView: View {
    let mealPlan: MealPlan
    
    private var averageDailyNutrition: NutritionInfo {
        let totalMeals = mealPlan.meals.count
        guard totalMeals > 0 else {
            return NutritionInfo(calories: 0, protein: 0, carbs: 0, fat: 0, fiber: 0)
        }
        
        var totalCalories = 0
        var totalProtein = 0.0
        var totalCarbs = 0.0
        var totalFat = 0.0
        var totalFiber = 0.0
        
        for dayMeal in mealPlan.meals {
            let meals = [dayMeal.breakfast, dayMeal.lunch, dayMeal.dinner].compactMap { $0 } + dayMeal.snacks
            for meal in meals {
                totalCalories += meal.nutritionInfo.calories
                totalProtein += meal.nutritionInfo.protein
                totalCarbs += meal.nutritionInfo.carbs
                totalFat += meal.nutritionInfo.fat
                totalFiber += meal.nutritionInfo.fiber
            }
        }
        
        return NutritionInfo(
            calories: totalCalories / totalMeals,
            protein: totalProtein / Double(totalMeals),
            carbs: totalCarbs / Double(totalMeals),
            fat: totalFat / Double(totalMeals),
            fiber: totalFiber / Double(totalMeals)
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Average Daily Nutrition")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 12) {
                NutritionBarView(
                    label: "Protein",
                    value: averageDailyNutrition.protein,
                    unit: "g",
                    color: .successGreen,
                    maxValue: 150
                )
                
                NutritionBarView(
                    label: "Carbs",
                    value: averageDailyNutrition.carbs,
                    unit: "g",
                    color: .accentYellow,
                    maxValue: 300
                )
                
                NutritionBarView(
                    label: "Fat",
                    value: averageDailyNutrition.fat,
                    unit: "g",
                    color: .primaryRed,
                    maxValue: 100
                )
                
                NutritionBarView(
                    label: "Fiber",
                    value: averageDailyNutrition.fiber,
                    unit: "g",
                    color: .secondaryBeige,
                    maxValue: 40
                )
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
        }
    }
}

struct NutritionBarView: View {
    let label: String
    let value: Double
    let unit: String
    let color: Color
    let maxValue: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Text(String(format: "%.1f%@", value, unit))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.divider)
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * min(value / maxValue, 1.0), height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)
        }
    }
}

struct MealPlanActionsView: View {
    let mealPlan: MealPlan
    @EnvironmentObject var viewModel: MealPlannerViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: {
                viewModel.currentMealPlan = mealPlan
            }) {
                Text(viewModel.currentMealPlan?.id == mealPlan.id ? "Current Plan" : "Set as Current Plan")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(viewModel.currentMealPlan?.id == mealPlan.id ? Color.textSecondary : Color.successGreen)
                    .cornerRadius(25)
            }
            .disabled(viewModel.currentMealPlan?.id == mealPlan.id)
            
            HStack(spacing: 12) {
                Button(action: {
                    viewModel.duplicateMealPlan(mealPlan)
                }) {
                    Text("Duplicate")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primaryRed)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.cardBackground)
                        .cornerRadius(22)
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(Color.primaryRed, lineWidth: 1)
                        )
                }
                
                Button(action: {
                    // In a real app, this would export or share the meal plan
                }) {
                    Text("Share")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primaryRed)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.cardBackground)
                        .cornerRadius(22)
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(Color.primaryRed, lineWidth: 1)
                        )
                }
            }
        }
    }
}

#Preview {
    MealPlanDetailView(mealPlan: MealPlan.sampleMealPlans[0])
        .environmentObject(MealPlannerViewModel())
}

