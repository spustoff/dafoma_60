//
//  MealPlanGeneratorView.swift
//  FortGourmetMuse
//
//  Created by Вячеслав on 10/9/25.
//

import SwiftUI

struct MealPlanGeneratorView: View {
    @EnvironmentObject var viewModel: MealPlannerViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var currentStep = 0
    
    private let steps = ["Preferences", "Ingredients", "Generate"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress indicator
                ProgressIndicatorView(currentStep: currentStep, totalSteps: steps.count, steps: steps)
                    .padding()
                
                // Content
                TabView(selection: $currentStep) {
                    PreferencesStepView()
                        .environmentObject(viewModel)
                        .tag(0)
                    
                    IngredientsStepView()
                        .environmentObject(viewModel)
                        .tag(1)
                    
                    GenerateStepView()
                        .environmentObject(viewModel)
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)
                
                // Navigation buttons
                HStack(spacing: 16) {
                    if currentStep > 0 {
                        Button("Back") {
                            withAnimation {
                                currentStep -= 1
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                    }
                    
                    Spacer()
                    
                    if currentStep < steps.count - 1 {
                        Button("Next") {
                            withAnimation {
                                currentStep += 1
                            }
                        }
                        .font(.subheadline)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.primaryRed)
                        .cornerRadius(20)
                    } else {
                        Button(viewModel.isGenerating ? "Generating..." : "Generate Plan") {
                            viewModel.generateMealPlan()
                        }
                        .font(.subheadline)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(viewModel.isGenerating ? Color.textSecondary : Color.successGreen)
                        .cornerRadius(20)
                        .disabled(viewModel.isGenerating)
                    }
                }
                .padding()
            }
            .navigationTitle("AI Meal Planner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.textSecondary)
                }
            }
            .onReceive(viewModel.$isGenerating) { isGenerating in
                if !isGenerating && viewModel.currentMealPlan != nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct ProgressIndicatorView: View {
    let currentStep: Int
    let totalSteps: Int
    let steps: [String]
    
    var body: some View {
        VStack(spacing: 12) {
            // Progress bar
            HStack(spacing: 4) {
                ForEach(0..<totalSteps, id: \.self) { index in
                    Rectangle()
                        .fill(index <= currentStep ? Color.primaryRed : Color.divider)
                        .frame(height: 4)
                        .cornerRadius(2)
                }
            }
            
            // Step labels
            HStack {
                ForEach(0..<totalSteps, id: \.self) { index in
                    Text(steps[index])
                        .font(.caption)
                        .fontWeight(index == currentStep ? .semibold : .regular)
                        .foregroundColor(index <= currentStep ? .primaryRed : .textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

struct PreferencesStepView: View {
    @EnvironmentObject var viewModel: MealPlannerViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tell us about your preferences")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    
                    Text("Help us create the perfect meal plan for you")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                }
                
                // Target calories
                VStack(alignment: .leading, spacing: 12) {
                    Text("Daily Calorie Target")
                        .font(.headline)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.textPrimary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("\(viewModel.targetCalories) calories")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.textPrimary)
                            Spacer()
                        }
                        
                        Slider(
                            value: Binding(
                                get: { Double(viewModel.targetCalories) },
                                set: { viewModel.targetCalories = Int($0) }
                            ),
                            in: 1200...3000,
                            step: 50
                        )
                        .accentColor(.primaryRed)
                        
                        HStack {
                            Text("1200")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                            Spacer()
                            Text("3000")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                        }
                    }
                }
                
                // Plan duration
                VStack(alignment: .leading, spacing: 12) {
                    Text("Plan Duration")
                        .font(.headline)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.textPrimary)
                    
                    HStack(spacing: 12) {
                        ForEach([3, 7, 14], id: \.self) { days in
                            Button(action: {
                                viewModel.numberOfDays = days
                            }) {
                                Text("\(days) days")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(viewModel.numberOfDays == days ? .white : .textPrimary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(viewModel.numberOfDays == days ? Color.primaryRed : Color.cardBackground)
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(viewModel.numberOfDays == days ? Color.primaryRed : Color.divider, lineWidth: 1)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        Spacer()
                    }
                }
                
                // Dietary preferences
                VStack(alignment: .leading, spacing: 12) {
                    Text("Dietary Preferences")
                        .font(.headline)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.textPrimary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(DietaryPreference.allCases, id: \.self) { preference in
                            DietaryPreferenceCard(preference: preference)
                                .environmentObject(viewModel)
                        }
                    }
                }
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal)
        }
    }
}

struct DietaryPreferenceCard: View {
    let preference: DietaryPreference
    @EnvironmentObject var viewModel: MealPlannerViewModel
    
    private var isSelected: Bool {
        viewModel.selectedDietaryPreferences.contains(preference)
    }
    
    var body: some View {
        Button(action: {
            if isSelected {
                viewModel.removeDietaryPreference(preference)
            } else {
                viewModel.addDietaryPreference(preference)
            }
        }) {
            VStack(spacing: 8) {
                Image(systemName: preference.icon)
                    .font(.title2)
                    .foregroundColor(Color(hex: preference.color))
                
                Text(preference.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? Color(hex: preference.color).opacity(0.1) : Color.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(hex: preference.color) : Color.divider, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct IngredientsStepView: View {
    @EnvironmentObject var viewModel: MealPlannerViewModel
    @State private var newIngredient = ""
    @State private var newExcludedIngredient = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ingredient Preferences")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    
                    Text("Let us know what ingredients you have and what to avoid")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                }
                
                // Available ingredients
                VStack(alignment: .leading, spacing: 12) {
                    Text("Available Ingredients")
                        .font(.headline)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.textPrimary)
                    
                    Text("Ingredients you already have at home")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                    
                    // Add ingredient field
                    HStack {
                        TextField("Add ingredient...", text: $newIngredient)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button("Add") {
                            if !newIngredient.isEmpty {
                                viewModel.addAvailableIngredient(newIngredient)
                                newIngredient = ""
                            }
                        }
                        .font(.subheadline)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.successGreen)
                        .cornerRadius(8)
                        .disabled(newIngredient.isEmpty)
                    }
                    
                    // Available ingredients list
                    if !viewModel.availableIngredients.isEmpty {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                            ForEach(viewModel.availableIngredients, id: \.self) { ingredient in
                                IngredientChip(
                                    ingredient: ingredient,
                                    color: .successGreen,
                                    onRemove: {
                                        viewModel.removeAvailableIngredient(ingredient)
                                    }
                                )
                            }
                        }
                    }
                }
                
                // Excluded ingredients
                VStack(alignment: .leading, spacing: 12) {
                    Text("Excluded Ingredients")
                        .font(.headline)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.textPrimary)
                    
                    Text("Ingredients you want to avoid")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                    
                    // Add excluded ingredient field
                    HStack {
                        TextField("Add ingredient to exclude...", text: $newExcludedIngredient)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button("Add") {
                            if !newExcludedIngredient.isEmpty {
                                viewModel.addExcludedIngredient(newExcludedIngredient)
                                newExcludedIngredient = ""
                            }
                        }
                        .font(.subheadline)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.dangerRed)
                        .cornerRadius(8)
                        .disabled(newExcludedIngredient.isEmpty)
                    }
                    
                    // Excluded ingredients list
                    if !viewModel.excludedIngredients.isEmpty {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                            ForEach(viewModel.excludedIngredients, id: \.self) { ingredient in
                                IngredientChip(
                                    ingredient: ingredient,
                                    color: .dangerRed,
                                    onRemove: {
                                        viewModel.removeExcludedIngredient(ingredient)
                                    }
                                )
                            }
                        }
                    }
                }
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal)
        }
    }
}

struct IngredientChip: View {
    let ingredient: String
    let color: Color
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(ingredient)
                .font(.subheadline)
                .foregroundColor(.textPrimary)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption)
                    .foregroundColor(color)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct GenerateStepView: View {
    @EnvironmentObject var viewModel: MealPlannerViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 60, weight: .light))
                        .foregroundColor(.successGreen)
                    
                    Text("Ready to Generate!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    
                    Text("We'll create a personalized meal plan based on your preferences")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                }
                
                // Summary
                VStack(alignment: .leading, spacing: 16) {
                    Text("Plan Summary")
                        .font(.headline)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.textPrimary)
                    
                    VStack(spacing: 12) {
                        SummaryRow(title: "Duration", value: "\(viewModel.numberOfDays) days")
                        SummaryRow(title: "Daily Calories", value: "\(viewModel.targetCalories)")
                        SummaryRow(title: "Dietary Preferences", value: viewModel.selectedDietaryPreferences.isEmpty ? "None" : "\(viewModel.selectedDietaryPreferences.count) selected")
                        SummaryRow(title: "Available Ingredients", value: viewModel.availableIngredients.isEmpty ? "None" : "\(viewModel.availableIngredients.count) items")
                        SummaryRow(title: "Excluded Ingredients", value: viewModel.excludedIngredients.isEmpty ? "None" : "\(viewModel.excludedIngredients.count) items")
                    }
                }
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(12)
                
                if viewModel.isGenerating {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                            .tint(.successGreen)
                        
                        Text("Generating your personalized meal plan...")
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                    }
                    .padding()
                }
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal)
        }
    }
}

struct SummaryRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.textPrimary)
        }
    }
}

#Preview {
    MealPlanGeneratorView()
        .environmentObject(MealPlannerViewModel())
}
