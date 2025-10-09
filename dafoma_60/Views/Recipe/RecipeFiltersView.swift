//
//  RecipeFiltersView.swift
//  FortGourmetMuse
//
//  Created by Вячеслав on 10/9/25.
//

import SwiftUI

struct RecipeFiltersView: View {
    @EnvironmentObject var viewModel: RecipeViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Cuisine filter
                    FilterSection(title: "Cuisine") {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                            ForEach(viewModel.cuisines, id: \.self) { cuisine in
                                FilterChip(
                                    title: cuisine,
                                    isSelected: viewModel.selectedCuisine == cuisine
                                ) {
                                    viewModel.selectedCuisine = cuisine
                                }
                            }
                        }
                    }
                    
                    // Difficulty filter
                    FilterSection(title: "Difficulty") {
                        HStack(spacing: 12) {
                            ForEach(Recipe.DifficultyLevel.allCases, id: \.self) { difficulty in
                                FilterChip(
                                    title: difficulty.rawValue,
                                    isSelected: viewModel.selectedDifficulty == difficulty,
                                    color: Color(hex: difficulty.color)
                                ) {
                                    if viewModel.selectedDifficulty == difficulty {
                                        viewModel.selectedDifficulty = nil
                                    } else {
                                        viewModel.selectedDifficulty = difficulty
                                    }
                                }
                            }
                            Spacer()
                        }
                    }
                    
                    // Cooking time filter
                    FilterSection(title: "Maximum Cooking Time") {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("\(viewModel.maxCookingTime) minutes")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.textPrimary)
                                Spacer()
                            }
                            
                            Slider(
                                value: Binding(
                                    get: { Double(viewModel.maxCookingTime) },
                                    set: { viewModel.maxCookingTime = Int($0) }
                                ),
                                in: 10...120,
                                step: 5
                            )
                            .accentColor(.primaryRed)
                            
                            HStack {
                                Text("10 min")
                                    .font(.caption)
                                    .foregroundColor(.textSecondary)
                                Spacer()
                                Text("120 min")
                                    .font(.caption)
                                    .foregroundColor(.textSecondary)
                            }
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear All") {
                        viewModel.clearFilters()
                    }
                    .foregroundColor(.dangerRed)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .font(.body.weight(.semibold))
                .foregroundColor(.primaryRed)
                }
            }
        }
    }
}

struct FilterSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            content
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    init(title: String, isSelected: Bool, color: Color = .primaryRed, action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? color : Color.cardBackground)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? color : Color.divider, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    RecipeFiltersView()
        .environmentObject(RecipeViewModel())
}
