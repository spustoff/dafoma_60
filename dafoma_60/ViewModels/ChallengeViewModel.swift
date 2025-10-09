//
//  ChallengeViewModel.swift
//  FortGourmetMuse
//
//  Created by Вячеслав on 10/9/25.
//

import Foundation
import Combine

@MainActor
class ChallengeViewModel: ObservableObject {
    @Published var challenges: [CookingChallenge] = []
    @Published var userBadges: [Badge] = []
    @Published var completedRecipes: Set<UUID> = []
    @Published var userPoints: Int = 0
    @Published var userLevel: Int = 1
    @Published var currentChallenge: CookingChallenge?
    @Published var isLoading: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadChallenges()
        loadUserProgress()
    }
    
    private func loadChallenges() {
        isLoading = true
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.challenges = CookingChallenge.sampleChallenges
            self.currentChallenge = self.challenges.first { $0.isActive }
            self.isLoading = false
        }
    }
    
    private func loadUserProgress() {
        // Load from UserDefaults
        let savedBadges = UserDefaults.standard.data(forKey: "userBadges") ?? Data()
        if let decodedBadges = try? JSONDecoder().decode([Badge].self, from: savedBadges) {
            userBadges = decodedBadges
        } else {
            // Initialize with first badge unlocked
            userBadges = [Badge.sampleBadges[0]]
        }
        
        let savedRecipes = UserDefaults.standard.stringArray(forKey: "completedRecipes") ?? []
        completedRecipes = Set(savedRecipes.compactMap { UUID(uuidString: $0) })
        
        userPoints = UserDefaults.standard.integer(forKey: "userPoints")
        userLevel = UserDefaults.standard.integer(forKey: "userLevel")
        
        if userLevel == 0 { userLevel = 1 } // Default level
        
        calculateLevel()
    }
    
    private func saveUserProgress() {
        if let encodedBadges = try? JSONEncoder().encode(userBadges) {
            UserDefaults.standard.set(encodedBadges, forKey: "userBadges")
        }
        
        let recipeIds = Array(completedRecipes).map { $0.uuidString }
        UserDefaults.standard.set(recipeIds, forKey: "completedRecipes")
        UserDefaults.standard.set(userPoints, forKey: "userPoints")
        UserDefaults.standard.set(userLevel, forKey: "userLevel")
    }
    
    func completeRecipe(_ recipe: Recipe) {
        guard !completedRecipes.contains(recipe.id) else { return }
        
        completedRecipes.insert(recipe.id)
        userPoints += 10 // Base points for completing a recipe
        
        checkForNewBadges()
        calculateLevel()
        saveUserProgress()
    }
    
    private func checkForNewBadges() {
        let allBadges = Badge.sampleBadges
        
        for badge in allBadges {
            // Skip if already unlocked
            if userBadges.contains(where: { $0.id == badge.id }) { continue }
            
            var shouldUnlock = false
            
            switch badge.name {
            case "First Steps":
                shouldUnlock = completedRecipes.count >= 1
            case "Global Explorer":
                let cuisines = Set(Recipe.sampleRecipes.filter { completedRecipes.contains($0.id) }.map { $0.cuisine })
                shouldUnlock = cuisines.count >= 5
            case "Master Chef":
                shouldUnlock = completedRecipes.count >= 50
            case "Social Butterfly":
                // This would be tracked separately in a real app
                shouldUnlock = false
            case "Seasonal Specialist":
                // This would check completed seasonal challenges
                shouldUnlock = false
            default:
                break
            }
            
            if shouldUnlock {
                unlockBadge(badge)
            }
        }
    }
    
    private func unlockBadge(_ badge: Badge) {
        let unlockedBadge = Badge(
            name: badge.name,
            description: badge.description,
            iconName: badge.iconName,
            category: badge.category,
            requirement: badge.requirement,
            points: badge.points,
            rarity: badge.rarity,
            unlockedDate: Date()
        )
        
        userBadges.append(unlockedBadge)
        userPoints += Int(Double(badge.points) * badge.rarity.pointsMultiplier)
    }
    
    private func calculateLevel() {
        // Simple level calculation: 100 points per level
        let newLevel = max(1, userPoints / 100 + 1)
        if newLevel > userLevel {
            userLevel = newLevel
        }
    }
    
    func joinChallenge(_ challenge: CookingChallenge) {
        // In a real app, this would make an API call
        currentChallenge = challenge
    }
    
    func leaveChallenge() {
        currentChallenge = nil
    }
    
    func getChallengeProgress(_ challenge: CookingChallenge) -> Double {
        let completedChallengeRecipes = challenge.recipes.filter { completedRecipes.contains($0.id) }
        return Double(completedChallengeRecipes.count) / Double(challenge.recipes.count)
    }
    
    func isChallengeCompleted(_ challenge: CookingChallenge) -> Bool {
        return challenge.recipes.allSatisfy { completedRecipes.contains($0.id) }
    }
    
    func getUnlockedBadges() -> [Badge] {
        return userBadges.filter { $0.isUnlocked }
    }
    
    func getLockedBadges() -> [Badge] {
        let unlockedIds = Set(userBadges.map { $0.id })
        return Badge.sampleBadges.filter { !unlockedIds.contains($0.id) }
    }
    
    func getBadgesByCategory(_ category: BadgeCategory) -> [Badge] {
        return Badge.sampleBadges.filter { $0.category == category }
    }
    
    func getPointsToNextLevel() -> Int {
        let pointsForCurrentLevel = (userLevel - 1) * 100
        let pointsForNextLevel = userLevel * 100
        return pointsForNextLevel - userPoints
    }
    
    func getLevelProgress() -> Double {
        let pointsForCurrentLevel = (userLevel - 1) * 100
        let pointsForNextLevel = userLevel * 100
        let currentLevelPoints = userPoints - pointsForCurrentLevel
        let totalLevelPoints = pointsForNextLevel - pointsForCurrentLevel
        
        return Double(currentLevelPoints) / Double(totalLevelPoints)
    }
    
    func resetProgress() {
        completedRecipes.removeAll()
        userPoints = 0
        userLevel = 1
        userBadges = [Badge.sampleBadges[0]] // Keep the first badge
        currentChallenge = nil
        saveUserProgress()
    }
}
