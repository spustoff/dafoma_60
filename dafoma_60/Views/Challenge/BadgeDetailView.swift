//
//  BadgeDetailView.swift
//  FortGourmetMuse
//
//  Created by Вячеслав on 10/9/25.
//

import SwiftUI

struct BadgeDetailView: View {
    let badge: Badge
    @EnvironmentObject var viewModel: ChallengeViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Badge icon
                Image(systemName: badge.iconName)
                    .font(.system(size: 80, weight: .light))
                    .foregroundColor(badge.isUnlocked ? Color(hex: badge.category.color) : .textSecondary)
                    .opacity(badge.isUnlocked ? 1.0 : 0.5)
                
                // Status
                Text(badge.isUnlocked ? "Unlocked!" : "Locked")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(badge.isUnlocked ? .successGreen : .textSecondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background((badge.isUnlocked ? Color.successGreen : Color.textSecondary).opacity(0.1))
                    .cornerRadius(12)
                
                // Basic info
                VStack(alignment: .leading, spacing: 8) {
                    Text("Badge Information")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.textPrimary)
                    
                    VStack(spacing: 4) {
                        HStack {
                            Text("Name:")
                                .font(.subheadline)
                                .foregroundColor(.textSecondary)
                            Spacer()
                            Text(badge.name)
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(.textPrimary)
                        }
                        
                        HStack {
                            Text("Category:")
                                .font(.subheadline)
                                .foregroundColor(.textSecondary)
                            Spacer()
                            Text(badge.category.rawValue)
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(.textPrimary)
                        }
                        
                        HStack {
                            Text("Rarity:")
                                .font(.subheadline)
                                .foregroundColor(.textSecondary)
                            Spacer()
                            Text(badge.rarity.rawValue)
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(Color(hex: badge.rarity.color))
                        }
                        
                        HStack {
                            Text("Points:")
                                .font(.subheadline)
                                .foregroundColor(.textSecondary)
                            Spacer()
                            Text("\(badge.points)")
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(.textPrimary)
                        }
                    }
                }
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(12)
                
                // Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.textPrimary)
                    
                    Text(badge.description)
                        .font(.body)
                        .foregroundColor(.textSecondary)
                }
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
            .navigationTitle(badge.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.textSecondary)
                }
            }
        }
    }
}

#Preview {
    BadgeDetailView(badge: Badge.sampleBadges[0])
        .environmentObject(ChallengeViewModel())
}