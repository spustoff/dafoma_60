//
//  ChallengeDetailView.swift
//  FortGourmetMuse
//
//  Created by Вячеслав on 10/9/25.
//

import SwiftUI

struct ChallengeDetailView: View {
    let challenge: CookingChallenge
    @EnvironmentObject var viewModel: ChallengeViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    ChallengeHeaderView(challenge: challenge)
                        .environmentObject(viewModel)
                    
                    // Progress section
                    ChallengeProgressSection(challenge: challenge)
                        .environmentObject(viewModel)
                    
                    // Recipes section
                    ChallengeRecipesSection(challenge: challenge)
                        .environmentObject(viewModel)
                    
                    // Badge reward
                    ChallengeBadgeSection(challenge: challenge)
                        .environmentObject(viewModel)
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
            }
            .navigationTitle(challenge.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.textSecondary)
                }
            }
            .overlay(
                // Action button
                VStack {
                    Spacer()
                    
                    if viewModel.currentChallenge?.id == challenge.id {
                        Button(action: {
                            viewModel.leaveChallenge()
                        }) {
                            Text("Leave Challenge")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.dangerRed)
                                .cornerRadius(25)
                        }
                    } else {
                        Button(action: {
                            viewModel.joinChallenge(challenge)
                        }) {
                            Text("Join Challenge")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.successGreen)
                                .cornerRadius(25)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 34)
            )
        }
    }
}

struct ChallengeHeaderView: View {
    let challenge: CookingChallenge
    @EnvironmentObject var viewModel: ChallengeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Description
            Text(challenge.description)
                .font(.body)
                .foregroundColor(.textSecondary)
                .lineLimit(nil)
            
            // Stats
            HStack(spacing: 20) {
                ChallengeDetailStatView(
                    icon: "person.2.fill",
                    title: "Participants",
                    value: "\(challenge.participants)",
                    color: .primaryRed
                )
                
                ChallengeDetailStatView(
                    icon: "calendar",
                    title: "Days Left",
                    value: "\(challenge.daysRemaining)",
                    color: .accentYellow
                )
                
                ChallengeDetailStatView(
                    icon: "fork.knife",
                    title: "Recipes",
                    value: "\(challenge.recipes.count)",
                    color: .successGreen
                )
            }
            
            // Dates
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Start Date:")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                    
                    Spacer()
                    
                    Text(challenge.startDate, style: .date)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.textPrimary)
                }
                
                HStack {
                    Text("End Date:")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                    
                    Spacer()
                    
                    Text(challenge.endDate, style: .date)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.textPrimary)
                }
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
        }
    }
}

struct ChallengeDetailStatView: View {
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

struct ChallengeProgressSection: View {
    let challenge: CookingChallenge
    @EnvironmentObject var viewModel: ChallengeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Progress")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 12) {
                HStack {
                    Text("Completed Recipes")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                    
                    Spacer()
                    
                    let completedCount = challenge.recipes.filter { viewModel.completedRecipes.contains($0.id) }.count
                    Text("\(completedCount) / \(challenge.recipes.count)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primaryRed)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.divider)
                            .frame(height: 8)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(LinearGradient.primaryGradient)
                            .frame(width: geometry.size.width * viewModel.getChallengeProgress(challenge), height: 8)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
                
                if viewModel.isChallengeCompleted(challenge) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.successGreen)
                        
                        Text("Challenge Completed!")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.successGreen)
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.successGreen.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
        }
    }
}

struct ChallengeRecipesSection: View {
    let challenge: CookingChallenge
    @EnvironmentObject var viewModel: ChallengeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Challenge Recipes")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            LazyVStack(spacing: 12) {
                ForEach(challenge.recipes, id: \.id) { recipe in
                    ChallengeRecipeCard(recipe: recipe)
                        .environmentObject(viewModel)
                }
            }
        }
    }
}

struct ChallengeRecipeCard: View {
    let recipe: Recipe
    @EnvironmentObject var viewModel: ChallengeViewModel
    
    private var isCompleted: Bool {
        viewModel.completedRecipes.contains(recipe.id)
    }
    
    var body: some View {
        Button(action: {
            NotificationCenter.default.post(name: NSNotification.Name("ShowRecipeDetail"), object: recipe)
        }) {
            HStack(spacing: 12) {
                // Image placeholder
                RoundedRectangle(cornerRadius: 8)
                    .fill(LinearGradient.primaryGradient)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Group {
                            if isCompleted {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.successGreen)
                            } else {
                                Image(systemName: "fork.knife")
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }
                        }
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                    
                    Text(recipe.description)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Text("\(recipe.cookingTime) min")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                        
                        Text("• \(recipe.difficulty.rawValue)")
                            .font(.caption)
                            .foregroundColor(Color(hex: recipe.difficulty.color))
                        
                        Spacer()
                        
                        if isCompleted {
                            Text("Completed")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.successGreen)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.successGreen.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            .padding(12)
            .background(Color.cardBackground)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ChallengeBadgeSection: View {
    let challenge: CookingChallenge
    @EnvironmentObject var viewModel: ChallengeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Reward Badge")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            HStack(spacing: 16) {
                // Badge icon
                Image(systemName: challenge.badge.iconName)
                    .font(.system(size: 40))
                    .foregroundColor(Color(hex: challenge.badge.category.color))
                    .frame(width: 60, height: 60)
                    .background(Color(hex: challenge.badge.category.color).opacity(0.1))
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(challenge.badge.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                    
                    Text(challenge.badge.description)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)
                    
                    HStack {
                        Text(challenge.badge.rarity.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(Color(hex: challenge.badge.rarity.color))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(hex: challenge.badge.rarity.color).opacity(0.1))
                            .cornerRadius(4)
                        
                        Text("• \(challenge.badge.points) pts")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
    }
}

#Preview {
    ChallengeDetailView(challenge: CookingChallenge.sampleChallenges[0])
        .environmentObject(ChallengeViewModel())
}
