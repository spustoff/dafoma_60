//
//  Restaurant.swift
//  FortGourmetMuse
//
//  Created by Вячеслав on 10/9/25.
//

import Foundation
import CoreLocation

struct Restaurant: Identifiable, Codable {
    let id = UUID()
    let name: String
    let description: String
    let cuisine: String
    let address: String
    let latitude: Double
    let longitude: Double
    let phoneNumber: String?
    let website: String?
    let priceRange: PriceRange
    let rating: Double
    let reviewCount: Int
    let hours: [DayHours]
    let features: [RestaurantFeature]
    let imageURL: String?
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var isOpenNow: Bool {
        let now = Date()
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: now)
        let currentTime = calendar.dateComponents([.hour, .minute], from: now)
        
        guard let todayHours = hours.first(where: { $0.dayOfWeek == weekday }),
              let openTime = todayHours.openTime,
              let closeTime = todayHours.closeTime else {
            return false
        }
        
        let currentMinutes = (currentTime.hour ?? 0) * 60 + (currentTime.minute ?? 0)
        let openMinutes = openTime.hour * 60 + openTime.minute
        let closeMinutes = closeTime.hour * 60 + closeTime.minute
        
        if closeMinutes > openMinutes {
            return currentMinutes >= openMinutes && currentMinutes <= closeMinutes
        } else {
            // Handle overnight hours
            return currentMinutes >= openMinutes || currentMinutes <= closeMinutes
        }
    }
}

struct DayHours: Codable {
    let dayOfWeek: Int // 1 = Sunday, 2 = Monday, etc.
    let openTime: TimeComponents?
    let closeTime: TimeComponents?
    let isClosed: Bool
    
    var dayName: String {
        let formatter = DateFormatter()
        return formatter.weekdaySymbols[dayOfWeek - 1]
    }
    
    var displayText: String {
        if isClosed {
            return "Closed"
        }
        guard let open = openTime, let close = closeTime else {
            return "Hours not available"
        }
        return "\(open.displayTime) - \(close.displayTime)"
    }
}

struct TimeComponents: Codable {
    let hour: Int
    let minute: Int
    
    var displayTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let date = Calendar.current.date(from: DateComponents(hour: hour, minute: minute)) ?? Date()
        return formatter.string(from: date)
    }
}

enum PriceRange: String, CaseIterable, Codable {
    case budget = "$"
    case moderate = "$$"
    case expensive = "$$$"
    case luxury = "$$$$"
    
    var description: String {
        switch self {
        case .budget: return "Budget-friendly"
        case .moderate: return "Moderate"
        case .expensive: return "Expensive"
        case .luxury: return "Luxury"
        }
    }
    
    var color: String {
        switch self {
        case .budget: return "#1ed55f"
        case .moderate: return "#ffc934"
        case .expensive: return "#dfb492"
        case .luxury: return "#ae2d27"
        }
    }
}

enum RestaurantFeature: String, CaseIterable, Codable {
    case delivery = "Delivery"
    case takeout = "Takeout"
    case dineIn = "Dine-in"
    case outdoor = "Outdoor Seating"
    case parking = "Parking Available"
    case wifi = "Free WiFi"
    case familyFriendly = "Family Friendly"
    case petFriendly = "Pet Friendly"
    case wheelchair = "Wheelchair Accessible"
    case liveMusic = "Live Music"
    case happyHour = "Happy Hour"
    case brunch = "Brunch"
    
    var icon: String {
        switch self {
        case .delivery: return "bicycle"
        case .takeout: return "bag.fill"
        case .dineIn: return "fork.knife"
        case .outdoor: return "sun.max.fill"
        case .parking: return "car.fill"
        case .wifi: return "wifi"
        case .familyFriendly: return "figure.and.child.holdinghands"
        case .petFriendly: return "pawprint.fill"
        case .wheelchair: return "figure.roll"
        case .liveMusic: return "music.note"
        case .happyHour: return "wineglass.fill"
        case .brunch: return "cup.and.saucer.fill"
        }
    }
}

// Sample data
extension Restaurant {
    static let sampleRestaurants: [Restaurant] = [
        Restaurant(
            name: "Sakura Sushi & Ramen",
            description: "Authentic Japanese cuisine with fresh sushi and traditional ramen bowls",
            cuisine: "Japanese",
            address: "123 Cherry Blossom St, Downtown",
            latitude: 37.7749,
            longitude: -122.4194,
            phoneNumber: "(555) 123-4567",
            website: "https://sakurasushi.com",
            priceRange: .moderate,
            rating: 4.6,
            reviewCount: 234,
            hours: [
                DayHours(dayOfWeek: 1, openTime: TimeComponents(hour: 12, minute: 0), closeTime: TimeComponents(hour: 22, minute: 0), isClosed: false),
                DayHours(dayOfWeek: 2, openTime: TimeComponents(hour: 11, minute: 30), closeTime: TimeComponents(hour: 22, minute: 30), isClosed: false),
                DayHours(dayOfWeek: 3, openTime: TimeComponents(hour: 11, minute: 30), closeTime: TimeComponents(hour: 22, minute: 30), isClosed: false),
                DayHours(dayOfWeek: 4, openTime: TimeComponents(hour: 11, minute: 30), closeTime: TimeComponents(hour: 22, minute: 30), isClosed: false),
                DayHours(dayOfWeek: 5, openTime: TimeComponents(hour: 11, minute: 30), closeTime: TimeComponents(hour: 23, minute: 0), isClosed: false),
                DayHours(dayOfWeek: 6, openTime: TimeComponents(hour: 11, minute: 30), closeTime: TimeComponents(hour: 23, minute: 0), isClosed: false),
                DayHours(dayOfWeek: 7, openTime: TimeComponents(hour: 12, minute: 0), closeTime: TimeComponents(hour: 22, minute: 0), isClosed: false)
            ],
            features: [.dineIn, .takeout, .delivery, .parking, .wifi],
            imageURL: nil
        ),
        Restaurant(
            name: "Mediterranean Breeze",
            description: "Fresh Mediterranean dishes with a modern twist, featuring locally sourced ingredients",
            cuisine: "Mediterranean",
            address: "456 Olive Grove Ave, Midtown",
            latitude: 37.7849,
            longitude: -122.4094,
            phoneNumber: "(555) 987-6543",
            website: "https://medbreeze.com",
            priceRange: .expensive,
            rating: 4.8,
            reviewCount: 189,
            hours: [
                DayHours(dayOfWeek: 1, openTime: nil, closeTime: nil, isClosed: true),
                DayHours(dayOfWeek: 2, openTime: TimeComponents(hour: 17, minute: 0), closeTime: TimeComponents(hour: 22, minute: 0), isClosed: false),
                DayHours(dayOfWeek: 3, openTime: TimeComponents(hour: 17, minute: 0), closeTime: TimeComponents(hour: 22, minute: 0), isClosed: false),
                DayHours(dayOfWeek: 4, openTime: TimeComponents(hour: 17, minute: 0), closeTime: TimeComponents(hour: 22, minute: 0), isClosed: false),
                DayHours(dayOfWeek: 5, openTime: TimeComponents(hour: 17, minute: 0), closeTime: TimeComponents(hour: 23, minute: 0), isClosed: false),
                DayHours(dayOfWeek: 6, openTime: TimeComponents(hour: 11, minute: 0), closeTime: TimeComponents(hour: 23, minute: 0), isClosed: false),
                DayHours(dayOfWeek: 7, openTime: TimeComponents(hour: 11, minute: 0), closeTime: TimeComponents(hour: 22, minute: 0), isClosed: false)
            ],
            features: [.dineIn, .outdoor, .parking, .wifi, .happyHour, .brunch],
            imageURL: nil
        ),
        Restaurant(
            name: "Spice Route",
            description: "Vibrant Indian and Thai fusion cuisine with bold flavors and aromatic spices",
            cuisine: "Indian/Thai",
            address: "789 Curry Lane, Spice District",
            latitude: 37.7649,
            longitude: -122.4294,
            phoneNumber: "(555) 456-7890",
            website: "https://spiceroute.com",
            priceRange: .moderate,
            rating: 4.4,
            reviewCount: 312,
            hours: [
                DayHours(dayOfWeek: 1, openTime: TimeComponents(hour: 11, minute: 0), closeTime: TimeComponents(hour: 21, minute: 30), isClosed: false),
                DayHours(dayOfWeek: 2, openTime: TimeComponents(hour: 11, minute: 0), closeTime: TimeComponents(hour: 21, minute: 30), isClosed: false),
                DayHours(dayOfWeek: 3, openTime: TimeComponents(hour: 11, minute: 0), closeTime: TimeComponents(hour: 21, minute: 30), isClosed: false),
                DayHours(dayOfWeek: 4, openTime: TimeComponents(hour: 11, minute: 0), closeTime: TimeComponents(hour: 21, minute: 30), isClosed: false),
                DayHours(dayOfWeek: 5, openTime: TimeComponents(hour: 11, minute: 0), closeTime: TimeComponents(hour: 22, minute: 0), isClosed: false),
                DayHours(dayOfWeek: 6, openTime: TimeComponents(hour: 11, minute: 0), closeTime: TimeComponents(hour: 22, minute: 0), isClosed: false),
                DayHours(dayOfWeek: 7, openTime: TimeComponents(hour: 11, minute: 0), closeTime: TimeComponents(hour: 21, minute: 30), isClosed: false)
            ],
            features: [.dineIn, .takeout, .delivery, .familyFriendly, .wifi],
            imageURL: nil
        )
    ]
}

