//
//  RestaurantFiltersView.swift
//  FortGourmetMuse
//
//  Created by Вячеслав on 10/9/25.
//

import SwiftUI

struct RestaurantFiltersView: View {
    @EnvironmentObject var viewModel: RestaurantExplorerViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Cuisine filter
                    FilterSection(title: "Cuisine") {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                            ForEach(viewModel.cuisines, id: \.self) { cuisine in
                                FilterChip(
                                    title: cuisine,
                                    isSelected: viewModel.selectedCuisine == cuisine
                                ) {
                                    viewModel.selectedCuisine = cuisine
                                }
                            }
                        }
                    }
                    
                    // Price range filter
                    FilterSection(title: "Price Range") {
                        HStack(spacing: 12) {
                            ForEach(PriceRange.allCases, id: \.self) { priceRange in
                                FilterChip(
                                    title: "\(priceRange.rawValue) \(priceRange.description)",
                                    isSelected: viewModel.selectedPriceRange == priceRange,
                                    color: Color(hex: priceRange.color)
                                ) {
                                    if viewModel.selectedPriceRange == priceRange {
                                        viewModel.selectedPriceRange = nil
                                    } else {
                                        viewModel.selectedPriceRange = priceRange
                                    }
                                }
                            }
                            Spacer()
                        }
                    }
                    
                    // Features filter
                    FilterSection(title: "Features") {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                            ForEach(RestaurantFeature.allCases.prefix(8), id: \.self) { feature in
                                FeatureFilterChip(feature: feature)
                                    .environmentObject(viewModel)
                            }
                        }
                    }
                    
                    // Open now toggle
                    FilterSection(title: "Availability") {
                        Toggle("Open Now", isOn: $viewModel.showOpenOnly)
                            .font(.subheadline)
                            .tint(.primaryRed)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear All") {
                        viewModel.clearFilters()
                    }
                    .foregroundColor(.dangerRed)
                }
                
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

struct FeatureFilterChip: View {
    let feature: RestaurantFeature
    @EnvironmentObject var viewModel: RestaurantExplorerViewModel
    @State private var isSelected = false
    
    var body: some View {
        Button(action: {
            isSelected.toggle()
            // In a real app, this would filter by features
        }) {
            HStack(spacing: 6) {
                Image(systemName: feature.icon)
                    .font(.caption)
                
                Text(feature.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .white : .textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.primaryRed : Color.cardBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.primaryRed : Color.divider, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    RestaurantFiltersView()
        .environmentObject(RestaurantExplorerViewModel())
}
