//
//  RestaurantExplorerViewModel.swift
//  FortGourmetMuse
//
//  Created by Вячеслав on 10/9/25.
//

import Foundation
import UIKit
import CoreLocation
import Combine

@MainActor
class RestaurantExplorerViewModel: NSObject, ObservableObject {
    @Published var restaurants: [Restaurant] = []
    @Published var filteredRestaurants: [Restaurant] = []
    @Published var selectedRestaurant: Restaurant?
    @Published var searchText: String = ""
    @Published var selectedCuisine: String = "All"
    @Published var selectedPriceRange: PriceRange?
    @Published var showOpenOnly: Bool = false
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var isLoading: Bool = false
    @Published var locationPermissionStatus: CLAuthorizationStatus = .notDetermined
    
    private let locationManager = CLLocationManager()
    private var cancellables = Set<AnyCancellable>()
    
    let cuisines = ["All", "Japanese", "Mediterranean", "Indian/Thai", "Italian", "Mexican", "American", "Chinese", "French"]
    
    override init() {
        super.init()
        setupLocationManager()
        loadRestaurants()
        setupSearchAndFilters()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationPermissionStatus = locationManager.authorizationStatus
    }
    
    private func setupSearchAndFilters() {
        Publishers.CombineLatest4($searchText, $selectedCuisine, $selectedPriceRange, $showOpenOnly)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] searchText, cuisine, priceRange, openOnly in
                self?.filterRestaurants(searchText: searchText, cuisine: cuisine, priceRange: priceRange, openOnly: openOnly)
            }
            .store(in: &cancellables)
    }
    
    private func loadRestaurants() {
        isLoading = true
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.restaurants = Restaurant.sampleRestaurants
            self.filteredRestaurants = self.restaurants
            self.isLoading = false
        }
    }
    
    private func filterRestaurants(searchText: String, cuisine: String, priceRange: PriceRange?, openOnly: Bool) {
        var filtered = restaurants
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { restaurant in
                restaurant.name.localizedCaseInsensitiveContains(searchText) ||
                restaurant.description.localizedCaseInsensitiveContains(searchText) ||
                restaurant.cuisine.localizedCaseInsensitiveContains(searchText) ||
                restaurant.address.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by cuisine
        if cuisine != "All" {
            filtered = filtered.filter { $0.cuisine == cuisine }
        }
        
        // Filter by price range
        if let priceRange = priceRange {
            filtered = filtered.filter { $0.priceRange == priceRange }
        }
        
        // Filter by open status
        if openOnly {
            filtered = filtered.filter { $0.isOpenNow }
        }
        
        // Sort by distance if user location is available
        if let userLocation = userLocation {
            filtered = filtered.sorted { restaurant1, restaurant2 in
                let distance1 = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
                    .distance(from: CLLocation(latitude: restaurant1.latitude, longitude: restaurant1.longitude))
                let distance2 = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
                    .distance(from: CLLocation(latitude: restaurant2.latitude, longitude: restaurant2.longitude))
                return distance1 < distance2
            }
        } else {
            // Sort by rating if no location
            filtered = filtered.sorted { $0.rating > $1.rating }
        }
        
        filteredRestaurants = filtered
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func getCurrentLocation() {
        guard locationPermissionStatus == .authorizedWhenInUse || locationPermissionStatus == .authorizedAlways else {
            requestLocationPermission()
            return
        }
        
        locationManager.requestLocation()
    }
    
    func distanceToRestaurant(_ restaurant: Restaurant) -> String? {
        guard let userLocation = userLocation else { return nil }
        
        let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let restaurantLocation = CLLocation(latitude: restaurant.latitude, longitude: restaurant.longitude)
        let distance = userCLLocation.distance(from: restaurantLocation)
        
        if distance < 1000 {
            return String(format: "%.0f m", distance)
        } else {
            return String(format: "%.1f km", distance / 1000)
        }
    }
    
    func clearFilters() {
        searchText = ""
        selectedCuisine = "All"
        selectedPriceRange = nil
        showOpenOnly = false
    }
    
    func getRestaurantsByFeature(_ feature: RestaurantFeature) -> [Restaurant] {
        restaurants.filter { $0.features.contains(feature) }
    }
    
    func getTopRatedRestaurants() -> [Restaurant] {
        restaurants.sorted { $0.rating > $1.rating }.prefix(5).map { $0 }
    }
    
    func getNearbyRestaurants(limit: Int = 10) -> [Restaurant] {
        guard let userLocation = userLocation else {
            return Array(restaurants.prefix(limit))
        }
        
        return restaurants.sorted { restaurant1, restaurant2 in
            let distance1 = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
                .distance(from: CLLocation(latitude: restaurant1.latitude, longitude: restaurant1.longitude))
            let distance2 = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
                .distance(from: CLLocation(latitude: restaurant2.latitude, longitude: restaurant2.longitude))
            return distance1 < distance2
        }.prefix(limit).map { $0 }
    }
    
    func callRestaurant(_ restaurant: Restaurant) {
        guard let phoneNumber = restaurant.phoneNumber,
              let url = URL(string: "tel:\(phoneNumber.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "-", with: ""))") else {
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    func openWebsite(_ restaurant: Restaurant) {
        guard let website = restaurant.website,
              let url = URL(string: website) else {
            return
        }
        
        UIApplication.shared.open(url)
    }
    
    func getDirections(_ restaurant: Restaurant) {
        let coordinate = restaurant.coordinate
        let url = URL(string: "maps://?daddr=\(coordinate.latitude),\(coordinate.longitude)")!
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            // Fallback to Apple Maps web
            let webURL = URL(string: "https://maps.apple.com/?daddr=\(coordinate.latitude),\(coordinate.longitude)")!
            UIApplication.shared.open(webURL)
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension RestaurantExplorerViewModel: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            userLocation = location.coordinate
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            locationPermissionStatus = manager.authorizationStatus
            
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                getCurrentLocation()
            case .denied, .restricted:
                userLocation = nil
            case .notDetermined:
                break
            @unknown default:
                break
            }
        }
    }
}
