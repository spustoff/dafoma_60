//
//  ChallengeView.swift
//  FortGourmetMuse
//
//  Created by Вячеслав on 10/9/25.
//

import SwiftUI

struct ChallengeView: View {
    @EnvironmentObject var viewModel: ChallengeViewModel
    @State private var selectedTab = 0
    @State private var selectedChallenge: CookingChallenge?
    @State private var selectedBadge: Badge?
    
    private let tabs = ["Challenges", "Badges", "Progress"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab selector
                TabSelectorView(tabs: tabs, selectedTab: $selectedTab)
                    .padding(.horizontal)
                
                // Content
                TabView(selection: $selectedTab) {
                    ChallengesTabView()
                        .environmentObject(viewModel)
                        .tag(0)
                    
                    BadgesTabView()
                        .environmentObject(viewModel)
                        .tag(1)
                    
                    ProgressTabView()
                        .environmentObject(viewModel)
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: selectedTab)
            }
            .navigationTitle("Challenges")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(item: $selectedChallenge) { challenge in
            ChallengeDetailView(challenge: challenge)
                .environmentObject(viewModel)
        }
        .sheet(item: $selectedBadge) { badge in
            BadgeDetailView(badge: badge)
                .environmentObject(viewModel)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowChallengeDetail"))) { notification in
            if let challenge = notification.object as? CookingChallenge {
                selectedChallenge = challenge
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowBadgeDetail"))) { notification in
            if let badge = notification.object as? Badge {
                selectedBadge = badge
            }
        }
    }
}

struct TabSelectorView: View {
    let tabs: [String]
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = index
                    }
                }) {
                    Text(tabs[index])
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(selectedTab == index ? .white : .textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedTab == index ? Color.primaryRed : Color.clear)
                }
            }
        }
        .background(Color.cardBackground)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.divider, lineWidth: 1)
        )
    }
}

struct ChallengesTabView: View {
    @EnvironmentObject var viewModel: ChallengeViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // User level card
                UserLevelCard()
                    .environmentObject(viewModel)
                
                // Active challenge
                if let currentChallenge = viewModel.currentChallenge {
                    ActiveChallengeSection(challenge: currentChallenge)
                        .environmentObject(viewModel)
                }
                
                // All challenges
                AllChallengesSection()
                    .environmentObject(viewModel)
            }
            .padding(.horizontal)
        }
    }
}

struct UserLevelCard: View {
    @EnvironmentObject var viewModel: ChallengeViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Level \(viewModel.userLevel)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    
                    Text("\(viewModel.userPoints) points")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Next Level")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    
                    Text("\(viewModel.getPointsToNextLevel()) pts")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primaryRed)
                }
            }
            
            // Progress bar
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Progress to Level \(viewModel.userLevel + 1)")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    
                    Spacer()
                    
                    Text("\(Int(viewModel.getLevelProgress() * 100))%")
                        .font(.caption)
                        .fontWeight(.medium)
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
                            .frame(width: geometry.size.width * viewModel.getLevelProgress(), height: 8)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct ActiveChallengeSection: View {
    let challenge: CookingChallenge
    @EnvironmentObject var viewModel: ChallengeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Active Challenge")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Button("View Details") {
                    NotificationCenter.default.post(name: NSNotification.Name("ShowChallengeDetail"), object: challenge)
                }
                .font(.subheadline)
                .foregroundColor(.primaryRed)
            }
            
            ChallengeCard(challenge: challenge, isActive: true)
                .environmentObject(viewModel)
        }
    }
}

struct AllChallengesSection: View {
    @EnvironmentObject var viewModel: ChallengeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("All Challenges")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Text("\(viewModel.challenges.count) challenges")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(viewModel.challenges, id: \.id) { challenge in
                    ChallengeCard(challenge: challenge, isActive: false)
                        .environmentObject(viewModel)
                        .onTapGesture {
                            NotificationCenter.default.post(name: NSNotification.Name("ShowChallengeDetail"), object: challenge)
                        }
                }
            }
        }
    }
}

struct ChallengeCard: View {
    let challenge: CookingChallenge
    let isActive: Bool
    @EnvironmentObject var viewModel: ChallengeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(challenge.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                    
                    Text(challenge.description)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                if isActive {
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
            
            // Progress
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Progress")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    
                    Spacer()
                    
                    Text("\(Int(viewModel.getChallengeProgress(challenge) * 100))%")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primaryRed)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.divider)
                            .frame(height: 6)
                            .cornerRadius(3)
                        
                        Rectangle()
                            .fill(Color.primaryRed)
                            .frame(width: geometry.size.width * viewModel.getChallengeProgress(challenge), height: 6)
                            .cornerRadius(3)
                    }
                }
                .frame(height: 6)
            }
            
            // Stats
            HStack(spacing: 20) {
                ChallengeStatView(
                    icon: "person.2.fill",
                    title: "Participants",
                    value: "\(challenge.participants)"
                )
                
                ChallengeStatView(
                    icon: "calendar",
                    title: "Days Left",
                    value: "\(challenge.daysRemaining)"
                )
                
                ChallengeStatView(
                    icon: "fork.knife",
                    title: "Recipes",
                    value: "\(challenge.recipes.count)"
                )
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct ChallengeStatView: View {
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

struct BadgesTabView: View {
    @EnvironmentObject var viewModel: ChallengeViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Stats overview
                BadgeStatsOverview()
                    .environmentObject(viewModel)
                
                // Unlocked badges
                UnlockedBadgesSection()
                    .environmentObject(viewModel)
                
                // Locked badges
                LockedBadgesSection()
                    .environmentObject(viewModel)
            }
            .padding(.horizontal)
        }
    }
}

struct BadgeStatsOverview: View {
    @EnvironmentObject var viewModel: ChallengeViewModel
    
    var body: some View {
        HStack(spacing: 20) {
            BadgeStatCard(
                title: "Unlocked",
                value: "\(viewModel.getUnlockedBadges().count)",
                color: .successGreen
            )
            
            BadgeStatCard(
                title: "Total",
                value: "\(Badge.sampleBadges.count)",
                color: .primaryRed
            )
            
            BadgeStatCard(
                title: "Points",
                value: "\(viewModel.userPoints)",
                color: .accentYellow
            )
        }
    }
}

struct BadgeStatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct UnlockedBadgesSection: View {
    @EnvironmentObject var viewModel: ChallengeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Unlocked Badges")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            let unlockedBadges = viewModel.getUnlockedBadges()
            
            if unlockedBadges.isEmpty {
                EmptyBadgesView(message: "Complete challenges to unlock badges!")
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(unlockedBadges, id: \.id) { badge in
                        BadgeCard(badge: badge, isUnlocked: true)
                            .onTapGesture {
                                NotificationCenter.default.post(name: NSNotification.Name("ShowBadgeDetail"), object: badge)
                            }
                    }
                }
            }
        }
    }
}

struct LockedBadgesSection: View {
    @EnvironmentObject var viewModel: ChallengeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Locked Badges")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(viewModel.getLockedBadges(), id: \.id) { badge in
                    BadgeCard(badge: badge, isUnlocked: false)
                        .onTapGesture {
                            NotificationCenter.default.post(name: NSNotification.Name("ShowBadgeDetail"), object: badge)
                        }
                }
            }
        }
    }
}

struct BadgeCard: View {
    let badge: Badge
    let isUnlocked: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            // Badge icon
            Image(systemName: badge.iconName)
                .font(.title)
                .foregroundColor(isUnlocked ? Color(hex: badge.category.color) : .textSecondary)
                .opacity(isUnlocked ? 1.0 : 0.5)
            
            // Badge info
            VStack(spacing: 4) {
                Text(badge.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isUnlocked ? .textPrimary : .textSecondary)
                    .multilineTextAlignment(.center)
                
                Text(badge.rarity.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Color(hex: badge.rarity.color))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color(hex: badge.rarity.color).opacity(0.1))
                    .cornerRadius(4)
                
                Text("\(badge.points) pts")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        .opacity(isUnlocked ? 1.0 : 0.7)
    }
}

struct EmptyBadgesView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "star.circle")
                .font(.system(size: 50))
                .foregroundColor(.textSecondary)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct ProgressTabView: View {
    @EnvironmentObject var viewModel: ChallengeViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Overall progress
                OverallProgressCard()
                    .environmentObject(viewModel)
                
                // Recent achievements
                RecentAchievementsSection()
                    .environmentObject(viewModel)
                
                // Statistics
                StatisticsSection()
                    .environmentObject(viewModel)
            }
            .padding(.horizontal)
        }
    }
}

struct OverallProgressCard: View {
    @EnvironmentObject var viewModel: ChallengeViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Your Culinary Journey")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            HStack(spacing: 20) {
                ProgressStatView(
                    title: "Recipes Completed",
                    value: "\(viewModel.completedRecipes.count)",
                    icon: "checkmark.circle.fill",
                    color: .successGreen
                )
                
                ProgressStatView(
                    title: "Current Level",
                    value: "\(viewModel.userLevel)",
                    icon: "star.fill",
                    color: .accentYellow
                )
                
                ProgressStatView(
                    title: "Total Points",
                    value: "\(viewModel.userPoints)",
                    icon: "flame.fill",
                    color: .primaryRed
                )
            }
        }
        .padding()
        .background(LinearGradient.primaryGradient.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.primaryRed.opacity(0.3), lineWidth: 1)
        )
    }
}

struct ProgressStatView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

struct RecentAchievementsSection: View {
    @EnvironmentObject var viewModel: ChallengeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Achievements")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            let recentBadges = viewModel.getUnlockedBadges().sorted { badge1, badge2 in
                (badge1.unlockedDate ?? Date.distantPast) > (badge2.unlockedDate ?? Date.distantPast)
            }.prefix(3)
            
            if recentBadges.isEmpty {
                EmptyBadgesView(message: "No achievements yet. Start cooking to earn badges!")
            } else {
                VStack(spacing: 8) {
                    ForEach(Array(recentBadges), id: \.id) { badge in
                        AchievementRowView(badge: badge)
                    }
                }
            }
        }
    }
}

struct AchievementRowView: View {
    let badge: Badge
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: badge.iconName)
                .font(.title2)
                .foregroundColor(Color(hex: badge.category.color))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(badge.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                Text(badge.description)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Text("+\(badge.points)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.primaryRed)
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(8)
    }
}

struct StatisticsSection: View {
    @EnvironmentObject var viewModel: ChallengeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Statistics")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 12) {
                StatisticRowView(
                    title: "Badges Unlocked",
                    value: "\(viewModel.getUnlockedBadges().count) / \(Badge.sampleBadges.count)",
                    progress: Double(viewModel.getUnlockedBadges().count) / Double(Badge.sampleBadges.count)
                )
                
                StatisticRowView(
                    title: "Challenges Completed",
                    value: "0 / \(viewModel.challenges.count)",
                    progress: 0.0
                )
                
                StatisticRowView(
                    title: "Level Progress",
                    value: "\(Int(viewModel.getLevelProgress() * 100))%",
                    progress: viewModel.getLevelProgress()
                )
            }
        }
    }
}

struct StatisticRowView: View {
    let title: String
    let value: String
    let progress: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primaryRed)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.divider)
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .fill(Color.primaryRed)
                        .frame(width: geometry.size.width * progress, height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(8)
    }
}

#Preview {
    ChallengeView()
        .environmentObject(ChallengeViewModel())
}
