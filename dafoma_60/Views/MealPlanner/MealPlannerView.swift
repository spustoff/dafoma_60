//
//  MealPlannerView.swift
//  FortGourmetMuse
//
//  Created by Вячеслав on 10/9/25.
//

import SwiftUI

struct MealPlannerView: View {
    @EnvironmentObject var viewModel: MealPlannerViewModel
    @State private var showingGenerator = false
    @State private var selectedMealPlan: MealPlan?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // AI Generator Card
                    AIGeneratorCard()
                        .environmentObject(viewModel)
                        .onTapGesture {
                            showingGenerator = true
                        }
                    
                    // Current meal plan
                    if let currentPlan = viewModel.currentMealPlan {
                        CurrentMealPlanSection(mealPlan: currentPlan)
                            .environmentObject(viewModel)
                    }
                    
                    // All meal plans
                    MealPlansListSection()
                        .environmentObject(viewModel)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Meal Planner")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingGenerator) {
                MealPlanGeneratorView()
                    .environmentObject(viewModel)
            }
            .sheet(item: $selectedMealPlan) { mealPlan in
                MealPlanDetailView(mealPlan: mealPlan)
                    .environmentObject(viewModel)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowMealPlanDetail"))) { notification in
            if let mealPlan = notification.object as? MealPlan {
                selectedMealPlan = mealPlan
            }
        }
    }
}

struct AIGeneratorCard: View {
    @EnvironmentObject var viewModel: MealPlannerViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            
            if viewModel.isGenerating {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.successGreen)
                    
                    Text("Generating your perfect meal plan...")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(
            LinearGradient.successGradient.opacity(0.1)
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.successGreen.opacity(0.3), lineWidth: 1)
        )
    }
}

struct CurrentMealPlanSection: View {
    let mealPlan: MealPlan
    @EnvironmentObject var viewModel: MealPlannerViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Current Plan")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Button("View Details") {
                    NotificationCenter.default.post(name: NSNotification.Name("ShowMealPlanDetail"), object: mealPlan)
                }
                .font(.subheadline)
                .foregroundColor(.primaryRed)
            }
            
            MealPlanCard(mealPlan: mealPlan, isCurrentPlan: true)
                .environmentObject(viewModel)
        }
    }
}

struct MealPlansListSection: View {
    @EnvironmentObject var viewModel: MealPlannerViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("All Meal Plans")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Text("\(viewModel.mealPlans.count) plans")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(viewModel.mealPlans, id: \.id) { mealPlan in
                    MealPlanCard(mealPlan: mealPlan, isCurrentPlan: false)
                        .environmentObject(viewModel)
                        .onTapGesture {
                            NotificationCenter.default.post(name: NSNotification.Name("ShowMealPlanDetail"), object: mealPlan)
                        }
                }
            }
        }
    }
}

struct MealPlanCard: View {
    let mealPlan: MealPlan
    let isCurrentPlan: Bool
    @EnvironmentObject var viewModel: MealPlannerViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(mealPlan.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                    
                    Text(mealPlan.description)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                if isCurrentPlan {
                    Text("ACTIVE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.successGreen)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.successGreen.opacity(0.1))
                        .cornerRadius(4)
                }
            }
            
            // Stats
            HStack(spacing: 20) {
                MealPlanStatView(
                    icon: "calendar",
                    title: "Duration",
                    value: "\(mealPlan.duration) days"
                )
                
                MealPlanStatView(
                    icon: "flame",
                    title: "Calories",
                    value: "\(mealPlan.totalCalories)"
                )
                
                MealPlanStatView(
                    icon: "dollarsign.circle",
                    title: "Cost",
                    value: String(format: "$%.0f", mealPlan.estimatedCost)
                )
            }
            
            // Dietary preferences
            if !mealPlan.dietaryPreferences.isEmpty {
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
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(hex: preference.color).opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct MealPlanStatView: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(.primaryRed)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.textSecondary)
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    MealPlannerView()
        .environmentObject(MealPlannerViewModel())
}

