//
//  RestaurantDetailView.swift
//  FortGourmetMuse
//
//  Created by Вячеслав on 10/9/25.
//

import SwiftUI
import MapKit

struct RestaurantDetailView: View {
    let restaurant: Restaurant
    @EnvironmentObject var viewModel: RestaurantExplorerViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    RestaurantHeaderView(restaurant: restaurant)
                        .environmentObject(viewModel)
                    
                    // Content
                    VStack(alignment: .leading, spacing: 20) {
                        // Basic info
                        RestaurantBasicInfoView(restaurant: restaurant)
                            .environmentObject(viewModel)
                        
                        // Tabs
                        RestaurantTabsView(restaurant: restaurant, selectedTab: $selectedTab)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                }
            }
            .ignoresSafeArea(edges: .top)
            .navigationBarHidden(true)
            .overlay(
                // Custom navigation bar
                VStack {
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        Menu {
                            Button(action: {
                                viewModel.callRestaurant(restaurant)
                            }) {
                                Label("Call Restaurant", systemImage: "phone")
                            }
                            
                            Button(action: {
                                viewModel.openWebsite(restaurant)
                            }) {
                                Label("Visit Website", systemImage: "safari")
                            }
                            
                            Button(action: {
                                // Share functionality
                            }) {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 50)
                    
                    Spacer()
                }
                , alignment: .top
            )
            .overlay(
                // Action buttons
                VStack {
                    Spacer()
                    
                    HStack(spacing: 12) {
                        if restaurant.phoneNumber != nil {
                            Button(action: {
                                viewModel.callRestaurant(restaurant)
                            }) {
                                HStack {
                                    Image(systemName: "phone.fill")
                                        .font(.subheadline)
                                    Text("Call")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color.successGreen)
                                .cornerRadius(22)
                            }
                        }
                        
                        Button(action: {
                            viewModel.getDirections(restaurant)
                        }) {
                            HStack {
                                Image(systemName: "location.fill")
                                    .font(.subheadline)
                                Text("Directions")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.primaryRed)
                            .cornerRadius(22)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 34)
                }
            )
        }
    }
}

struct RestaurantHeaderView: View {
    let restaurant: Restaurant
    @EnvironmentObject var viewModel: RestaurantExplorerViewModel
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background gradient
            LinearGradient.primaryGradient
                .frame(height: 300)
            
            // Content overlay
            VStack(spacing: 12) {
                Image(systemName: "fork.knife")
                    .font(.system(size: 60, weight: .light))
                    .foregroundColor(.white)
                
                Text(restaurant.cuisine)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(12)
            }
            .padding(.bottom, 40)
        }
    }
}

struct RestaurantBasicInfoView: View {
    let restaurant: Restaurant
    @EnvironmentObject var viewModel: RestaurantExplorerViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title and rating
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(restaurant.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    
                    Spacer()
                    
                    if restaurant.isOpenNow {
                        Text("Open Now")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.successGreen)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.successGreen.opacity(0.1))
                            .cornerRadius(12)
                    } else {
                        Text("Closed")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.dangerRed)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color.dangerRed.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
                
                HStack {
                    HStack(spacing: 4) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < Int(restaurant.rating) ? "star.fill" : "star")
                                .font(.caption)
                                .foregroundColor(.accentYellow)
                        }
                    }
                    
                    Text(String(format: "%.1f", restaurant.rating))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.textPrimary)
                    
                    Text("(\(restaurant.reviewCount) reviews)")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                    
                    Spacer()
                    
                    Text(restaurant.priceRange.rawValue)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: restaurant.priceRange.color))
                }
            }
            
            // Description
            Text(restaurant.description)
                .font(.body)
                .foregroundColor(.textSecondary)
                .lineLimit(nil)
            
            // Address and distance
            HStack {
                Image(systemName: "location")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                
                Text(restaurant.address)
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                
                Spacer()
                
                if let distance = viewModel.distanceToRestaurant(restaurant) {
                    Text(distance)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primaryRed)
                }
            }
            
            // Features
            if !restaurant.features.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(restaurant.features.prefix(6), id: \.self) { feature in
                            HStack(spacing: 4) {
                                Image(systemName: feature.icon)
                                    .font(.caption)
                                Text(feature.rawValue)
                                    .font(.caption)
                            }
                            .foregroundColor(.primaryRed)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.primaryRed.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
    }
}

struct RestaurantTabsView: View {
    let restaurant: Restaurant
    @Binding var selectedTab: Int
    
    private let tabs = ["Hours", "Location", "Contact"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Tab selector
            HStack(spacing: 0) {
                ForEach(0..<tabs.count, id: \.self) { index in
                    Button(action: {
                        selectedTab = index
                    }) {
                        Text(tabs[index])
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(selectedTab == index ? .primaryRed : .textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                Rectangle()
                                    .fill(selectedTab == index ? Color.primaryRed.opacity(0.1) : Color.clear)
                            )
                    }
                }
            }
            .background(Color.cardBackground)
            .cornerRadius(8)
            
            // Tab content
            Group {
                switch selectedTab {
                case 0:
                    HoursTabView(hours: restaurant.hours)
                case 1:
                    LocationTabView(restaurant: restaurant)
                case 2:
                    ContactTabView(restaurant: restaurant)
                default:
                    EmptyView()
                }
            }
        }
    }
}

struct HoursTabView: View {
    let hours: [DayHours]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(hours, id: \.dayOfWeek) { dayHours in
                HStack {
                    Text(dayHours.dayName)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.textPrimary)
                        .frame(width: 80, alignment: .leading)
                    
                    Spacer()
                    
                    Text(dayHours.displayText)
                        .font(.body)
                        .foregroundColor(dayHours.isClosed ? .dangerRed : .textSecondary)
                }
                .padding(.vertical, 4)
            }
        }
    }
}

struct LocationTabView: View {
    let restaurant: Restaurant
    @State private var region: MKCoordinateRegion
    
    init(restaurant: Restaurant) {
        self.restaurant = restaurant
        self._region = State(initialValue: MKCoordinateRegion(
            center: restaurant.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Map(coordinateRegion: .constant(region), annotationItems: [restaurant]) { restaurant in
                MapPin(coordinate: restaurant.coordinate, tint: .red)
            }
            .frame(height: 200)
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Address")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                Text(restaurant.address)
                    .font(.body)
                    .foregroundColor(.textSecondary)
            }
        }
    }
}

struct ContactTabView: View {
    let restaurant: Restaurant
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let phoneNumber = restaurant.phoneNumber {
                ContactRowView(
                    icon: "phone.fill",
                    title: "Phone",
                    value: phoneNumber,
                    color: .successGreen
                )
            }
            
            if let website = restaurant.website {
                ContactRowView(
                    icon: "globe",
                    title: "Website",
                    value: website,
                    color: .primaryRed
                )
            }
            
            ContactRowView(
                icon: "location.fill",
                title: "Address",
                value: restaurant.address,
                color: .textSecondary
            )
        }
    }
}

struct ContactRowView: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.textSecondary)
                
                Text(value)
                    .font(.body)
                    .foregroundColor(.textPrimary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    RestaurantDetailView(restaurant: Restaurant.sampleRestaurants[0])
        .environmentObject(RestaurantExplorerViewModel())
}

