//
//  RestaurantExplorerView.swift
//  FortGourmetMuse
//
//  Created by Вячеслав on 10/9/25.
//

import SwiftUI
import MapKit

struct RestaurantExplorerView: View {
    @EnvironmentObject var viewModel: RestaurantExplorerViewModel
    @State private var showingFilters = false
    @State private var showingMapView = false
    @State private var selectedRestaurant: Restaurant?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                SearchBar(text: $viewModel.searchText)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                // View toggle
                ViewToggleBar(showingMapView: $showingMapView)
                    .padding(.horizontal)
                
                if viewModel.isLoading {
                    LoadingView()
                } else {
                    if showingMapView {
                        RestaurantMapView()
                            .environmentObject(viewModel)
                    } else {
                        RestaurantListView()
                            .environmentObject(viewModel)
                    }
                }
            }
            .navigationTitle("Explore")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingFilters = true }) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.primaryRed)
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                RestaurantFiltersView()
                    .environmentObject(viewModel)
            }
            .sheet(item: $selectedRestaurant) { restaurant in
                RestaurantDetailView(restaurant: restaurant)
                    .environmentObject(viewModel)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowRestaurantDetail"))) { notification in
            if let restaurant = notification.object as? Restaurant {
                selectedRestaurant = restaurant
            }
        }
        .onAppear {
            if viewModel.locationPermissionStatus == .notDetermined {
                viewModel.requestLocationPermission()
            }
        }
    }
}

struct ViewToggleBar: View {
    @Binding var showingMapView: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            Button(action: { showingMapView = false }) {
                HStack {
                    Image(systemName: "list.bullet")
                        .font(.subheadline)
                    Text("List")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .foregroundColor(showingMapView ? .textSecondary : .white)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(showingMapView ? Color.clear : Color.primaryRed)
            }
            
            Button(action: { showingMapView = true }) {
                HStack {
                    Image(systemName: "map.fill")
                        .font(.subheadline)
                    Text("Map")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .foregroundColor(showingMapView ? .white : .textSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(showingMapView ? Color.primaryRed : Color.clear)
            }
        }
        .background(Color.cardBackground)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.divider, lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.2), value: showingMapView)
    }
}

struct RestaurantListView: View {
    @EnvironmentObject var viewModel: RestaurantExplorerViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Quick categories
                QuickRestaurantCategoriesView()
                    .environmentObject(viewModel)
                
                // Featured restaurants
                FeaturedRestaurantsSection()
                    .environmentObject(viewModel)
                
                // All restaurants
                RestaurantListSection()
                    .environmentObject(viewModel)
            }
            .padding(.horizontal)
        }
    }
}

struct QuickRestaurantCategoriesView: View {
    @EnvironmentObject var viewModel: RestaurantExplorerViewModel
    
    private let categories = [
        ("Nearby", "location.fill", Color.successGreen),
        ("Top Rated", "star.fill", Color.accentYellow),
        ("Open Now", "clock.fill", Color.primaryRed),
        ("Delivery", "bicycle", Color.secondaryBeige)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Access")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.textPrimary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories, id: \.0) { category in
                        CategoryCard(
                            title: category.0,
                            icon: category.1,
                            color: category.2
                        ) {
                            handleCategoryTap(category.0)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    private func handleCategoryTap(_ category: String) {
        switch category {
        case "Nearby":
            viewModel.getCurrentLocation()
        case "Top Rated":
            viewModel.clearFilters()
        case "Open Now":
            viewModel.showOpenOnly = true
        case "Delivery":
            viewModel.searchText = "delivery"
        default:
            break
        }
    }
}

struct FeaturedRestaurantsSection: View {
    @EnvironmentObject var viewModel: RestaurantExplorerViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Featured Restaurants")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Button("See All") {
                    viewModel.clearFilters()
                }
                .font(.subheadline)
                .foregroundColor(.primaryRed)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.getTopRatedRestaurants(), id: \.id) { restaurant in
                        FeaturedRestaurantCard(restaurant: restaurant)
                            .environmentObject(viewModel)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
}

struct FeaturedRestaurantCard: View {
    let restaurant: Restaurant
    @EnvironmentObject var viewModel: RestaurantExplorerViewModel
    
    var body: some View {
        Button(action: {
            NotificationCenter.default.post(name: NSNotification.Name("ShowRestaurantDetail"), object: restaurant)
        }) {
            VStack(alignment: .leading, spacing: 8) {
                // Image placeholder
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient.primaryGradient)
                    .frame(width: 200, height: 120)
                    .overlay(
                        VStack {
                            Image(systemName: "fork.knife")
                                .font(.title)
                                .foregroundColor(.white)
                            Text(restaurant.cuisine)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(restaurant.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.textPrimary)
                        .lineLimit(2)
                    
                    HStack {
                        Text(restaurant.priceRange.rawValue)
                            .font(.caption)
                            .foregroundColor(Color(hex: restaurant.priceRange.color))
                        
                        if let distance = viewModel.distanceToRestaurant(restaurant) {
                            Text("• \(distance)")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.accentYellow)
                            Text(String(format: "%.1f", restaurant.rating))
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
            .frame(width: 200)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RestaurantListSection: View {
    @EnvironmentObject var viewModel: RestaurantExplorerViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("All Restaurants")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                Text("\(viewModel.filteredRestaurants.count) restaurants")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(viewModel.filteredRestaurants, id: \.id) { restaurant in
                    RestaurantRowCard(restaurant: restaurant)
                        .environmentObject(viewModel)
                }
            }
        }
    }
}

struct RestaurantRowCard: View {
    let restaurant: Restaurant
    @EnvironmentObject var viewModel: RestaurantExplorerViewModel
    
    var body: some View {
        Button(action: {
            NotificationCenter.default.post(name: NSNotification.Name("ShowRestaurantDetail"), object: restaurant)
        }) {
            HStack(spacing: 12) {
                // Image placeholder
                RoundedRectangle(cornerRadius: 8)
                    .fill(LinearGradient.primaryGradient)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "fork.knife")
                            .font(.title2)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(restaurant.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.textPrimary)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        if restaurant.isOpenNow {
                            Text("Open")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.successGreen)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.successGreen.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                    
                    Text(restaurant.description)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Text(restaurant.priceRange.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(Color(hex: restaurant.priceRange.color))
                        
                        Text("• \(restaurant.cuisine)")
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                        
                        if let distance = viewModel.distanceToRestaurant(restaurant) {
                            Text("• \(distance)")
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.accentYellow)
                            Text(String(format: "%.1f", restaurant.rating))
                                .font(.caption)
                                .foregroundColor(.textSecondary)
                        }
                    }
                }
            }
            .padding(12)
            .background(Color.cardBackground)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RestaurantMapView: View {
    @EnvironmentObject var viewModel: RestaurantExplorerViewModel
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, annotationItems: viewModel.filteredRestaurants) { restaurant in
                MapAnnotation(coordinate: restaurant.coordinate) {
                    RestaurantMapPin(restaurant: restaurant)
                        .environmentObject(viewModel)
                }
            }
            .onAppear {
                if let userLocation = viewModel.userLocation {
                    region.center = userLocation
                } else {
                    viewModel.getCurrentLocation()
                }
            }
            .onReceive(viewModel.$userLocation) { location in
                if let location = location {
                    withAnimation {
                        region.center = location
                    }
                }
            }
            
            // Location button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        viewModel.getCurrentLocation()
                        if let userLocation = viewModel.userLocation {
                            withAnimation {
                                region.center = userLocation
                            }
                        }
                    }) {
                        Image(systemName: "location.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.primaryRed)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    .padding(.trailing)
                    .padding(.bottom, 100)
                }
            }
        }
    }
}

struct RestaurantMapPin: View {
    let restaurant: Restaurant
    @EnvironmentObject var viewModel: RestaurantExplorerViewModel
    
    var body: some View {
        Button(action: {
            NotificationCenter.default.post(name: NSNotification.Name("ShowRestaurantDetail"), object: restaurant)
        }) {
            VStack(spacing: 4) {
                Image(systemName: "fork.knife")
                    .font(.caption)
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                    .background(Color(hex: restaurant.priceRange.color))
                    .clipShape(Circle())
                
                Text(restaurant.name)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.cardBackground)
                    .cornerRadius(4)
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    RestaurantExplorerView()
        .environmentObject(RestaurantExplorerViewModel())
}
