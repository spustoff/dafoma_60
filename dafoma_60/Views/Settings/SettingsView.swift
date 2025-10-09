//
//  SettingsView.swift
//  FortGourmetMuse
//
//  Created by Вячеслав on 10/9/25.
//

import SwiftUI
import UIKit

struct SettingsView: View {
    @EnvironmentObject var challengeViewModel: ChallengeViewModel
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @State private var showingResetAlert = false
    @State private var showingAbout = false
    
    var body: some View {
        NavigationView {
            List {
                // Profile section
                Section {
                    ProfileHeaderView()
                        .environmentObject(challengeViewModel)
                }
                // Data & Privacy
                
                // App actions
                Section("App") {
                    SettingsRow(
                        icon: "arrow.clockwise",
                        title: "Reset Onboarding",
                        subtitle: "Show the welcome screens again",
                        color: .accentYellow
                    ) {
                        hasCompletedOnboarding = false
                    }
                    
                    SettingsRow(
                        icon: "trash.fill",
                        title: "Reset Progress",
                        subtitle: "Clear all cooking progress and badges",
                        color: .dangerRed
                    ) {
                        showingResetAlert = true
                    }
                    
                    SettingsRow(
                        icon: "star.fill",
                        title: "Rate App",
                        subtitle: "Rate FortGourmetMuse on the App Store",
                        color: .accentYellow
                    ) {
                        // Open App Store rating
                        if let url = URL(string: "https://apps.apple.com") {
                            UIApplication.shared.open(url)
                        }
                    }
                }
                
                // Support & Info
                Section("Support & Info") {
                    
                    SettingsRow(
                        icon: "info.circle.fill",
                        title: "About",
                        subtitle: "App version and information",
                        color: .textSecondary
                    ) {
                        showingAbout = true
                    }
                }
                
                // Version info
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 4) {
                            Text("FortGourmetMuse")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.textPrimary)
                            
                            Text("Version 1.0.0")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .alert("Reset Progress", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    challengeViewModel.resetProgress()
                }
            } message: {
                Text("This will permanently delete all your cooking progress, completed recipes, and earned badges. This action cannot be undone.")
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
        }
    }
}

struct ProfileHeaderView: View {
    @EnvironmentObject var challengeViewModel: ChallengeViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            // Profile image placeholder
            Circle()
                .fill(LinearGradient.primaryGradient)
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Culinary Explorer")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                Text("Level \(challengeViewModel.userLevel) • \(challengeViewModel.userPoints) points")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                
                Text("\(challengeViewModel.getUnlockedBadges().count) badges earned")
                    .font(.caption)
                    .foregroundColor(.primaryRed)
            }
            
            Spacer()
            
            // Level badge
            VStack(spacing: 2) {
                Image(systemName: "star.fill")
                    .font(.title3)
                    .foregroundColor(.accentYellow)
                
                Text("LVL")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.textSecondary)
                
                Text("\(challengeViewModel.userLevel)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
            }
            .padding(8)
            .background(Color.accentYellow.opacity(0.1))
            .cornerRadius(8)
        }
        .padding(.vertical, 8)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.textPrimary)
                        .multilineTextAlignment(.leading)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // App icon and name
                    VStack(spacing: 16) {
                        Circle()
                            .fill(LinearGradient.primaryGradient)
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "fork.knife")
                                    .font(.system(size: 40, weight: .light))
                                    .foregroundColor(.white)
                            )
                        
                        VStack(spacing: 4) {
                            Text("FortGourmetMuse")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.textPrimary)
                            
                            Text("Your Culinary Adventure Companion")
                                .font(.subheadline)
                                .foregroundColor(.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    // App description
                    VStack(alignment: .leading, spacing: 16) {
                        Text("About FortGourmetMuse")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.textPrimary)
                        
                        Text("FortGourmetMuse is your comprehensive culinary companion that helps you discover new recipes, plan meals with AI assistance, explore nearby restaurants, and participate in exciting cooking challenges.")
                            .font(.body)
                            .foregroundColor(.textSecondary)
                            .lineLimit(nil)
                    }
                    
                    // Features
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Features")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.textPrimary)
                        
                        VStack(spacing: 12) {
                            FeatureRow(
                                icon: "globe",
                                title: "Global Recipes",
                                description: "Discover authentic recipes from various cultures"
                            )
                            
                            FeatureRow(
                                icon: "brain.head.profile",
                                title: "AI Meal Planner",
                                description: "Get personalized meal plans based on your preferences"
                            )
                            
                            FeatureRow(
                                icon: "map.fill",
                                title: "Restaurant Explorer",
                                description: "Find and explore nearby restaurants with reviews"
                            )
                            
                            FeatureRow(
                                icon: "trophy.fill",
                                title: "Cooking Challenges",
                                description: "Participate in challenges and earn badges"
                            )
                        }
                    }
                    
                    // Version and credits
                    VStack(spacing: 16) {
                        Divider()
                        
                        VStack(spacing: 8) {
                            Text("Version 1.0.0")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.textPrimary)
                            
                            Text("Built with ❤️ for food enthusiasts")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                            
                            Text("© 2025 FortGourmetMuse. All rights reserved.")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 50)
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
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

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.primaryRed)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(ChallengeViewModel())
}
