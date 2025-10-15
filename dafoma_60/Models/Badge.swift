//
//  Badge.swift
//  FortGourmetMuse
//
//  Created by Вячеслав on 10/9/25.
//

import Foundation

struct Badge: Identifiable, Codable {
    let id = UUID()
    let name: String
    let description: String
    let iconName: String
    let category: BadgeCategory
    let requirement: String
    let points: Int
    let rarity: BadgeRarity
    let unlockedDate: Date?
    
    var isUnlocked: Bool {
        unlockedDate != nil
    }
}

enum BadgeCategory: String, CaseIterable, Codable {
    case cooking = "Cooking"
    case exploration = "Exploration"
    case social = "Social"
    case achievement = "Achievement"
    case seasonal = "Seasonal"
    
    var color: String {
        switch self {
        case .cooking: return "#ae2d27"
        case .exploration: return "#1ed55f"
        case .social: return "#ffc934"
        case .achievement: return "#dfb492"
        case .seasonal: return "#eb262f"
        }
    }
    
    var icon: String {
        switch self {
        case .cooking: return "flame.fill"
        case .exploration: return "location.fill"
        case .social: return "person.2.fill"
        case .achievement: return "star.fill"
        case .seasonal: return "leaf.fill"
        }
    }
}

enum BadgeRarity: String, CaseIterable, Codable {
    case common = "Common"
    case uncommon = "Uncommon"
    case rare = "Rare"
    case epic = "Epic"
    case legendary = "Legendary"
    
    var color: String {
        switch self {
        case .common: return "#808080"
        case .uncommon: return "#1ed55f"
        case .rare: return "#ffc934"
        case .epic: return "#ae2d27"
        case .legendary: return "#eb262f"
        }
    }
    
    var pointsMultiplier: Double {
        switch self {
        case .common: return 1.0
        case .uncommon: return 1.5
        case .rare: return 2.0
        case .epic: return 3.0
        case .legendary: return 5.0
        }
    }
}

struct CookingChallenge: Identifiable, Codable {
    let id = UUID()
    let name: String
    let description: String
    let startDate: Date
    let endDate: Date
    let recipes: [Recipe]
    let badge: Badge
    let participants: Int
    let isActive: Bool
    
    var daysRemaining: Int {
        let calendar = Calendar.current
        let now = Date()
        if now > endDate {
            return 0
        }
        return calendar.dateComponents([.day], from: now, to: endDate).day ?? 0
    }
    
    var progress: Double {
        let total = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 1
        let elapsed = Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0
        return min(1.0, max(0.0, Double(elapsed) / Double(total)))
    }
}

// Sample data
extension Badge {
    static let sampleBadges: [Badge] = [
        Badge(
            name: "First Steps",
            description: "Complete your first recipe",
            iconName: "star.fill",
            category: .achievement,
            requirement: "Cook 1 recipe",
            points: 10,
            rarity: .common,
            unlockedDate: Date()
        ),
        Badge(
            name: "Global Explorer",
            description: "Try recipes from 5 different cuisines",
            iconName: "globe",
            category: .exploration,
            requirement: "Cook recipes from 5 cuisines",
            points: 50,
            rarity: .uncommon,
            unlockedDate: nil
        ),
        Badge(
            name: "Master Chef",
            description: "Complete 50 recipes successfully",
            iconName: "crown.fill",
            category: .cooking,
            requirement: "Cook 50 recipes",
            points: 200,
            rarity: .rare,
            unlockedDate: nil
        ),
        Badge(
            name: "Social Butterfly",
            description: "Share 10 recipes with friends",
            iconName: "heart.fill",
            category: .social,
            requirement: "Share 10 recipes",
            points: 75,
            rarity: .uncommon,
            unlockedDate: nil
        ),
        Badge(
            name: "Seasonal Specialist",
            description: "Complete all seasonal challenges in a year",
            iconName: "calendar",
            category: .seasonal,
            requirement: "Complete 4 seasonal challenges",
            points: 500,
            rarity: .legendary,
            unlockedDate: nil
        )
    ]
}

extension CookingChallenge {
    static let sampleChallenges: [CookingChallenge] = [
        CookingChallenge(
            name: "October Harvest Festival",
            description: "Celebrate autumn with seasonal recipes featuring pumpkins, apples, and warming spices",
            startDate: Calendar.current.date(from: DateComponents(year: 2025, month: 10, day: 1)) ?? Date(),
            endDate: Calendar.current.date(from: DateComponents(year: 2025, month: 10, day: 31)) ?? Date(),
            recipes: Array(Recipe.sampleRecipes.prefix(2)),
            badge: Badge(
                name: "Harvest Master",
                description: "Complete the October Harvest Festival challenge",
                iconName: "leaf.fill",
                category: .seasonal,
                requirement: "Complete October challenge",
                points: 100,
                rarity: .rare,
                unlockedDate: nil
            ),
            participants: 1247,
            isActive: true
        )
    ]
}

