//
//  OnboardingView.swift
//  FortGourmetMuse
//
//  Created by Вячеслав on 10/9/25.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    
    private let pages = [
        OnboardingPage(
            title: "Welcome to FortGourmetMuse",
            subtitle: "Your culinary adventure begins here",
            description: "Discover amazing recipes from around the world, plan your meals with AI assistance, and explore the best restaurants in your area.",
            imageName: "chef.hat.fill",
            color: .primaryRed
        ),
        OnboardingPage(
            title: "Discover & Plan",
            subtitle: "Smart meal planning made easy",
            description: "Get personalized recipe recommendations based on your dietary preferences and available ingredients. Our AI-powered meal planner creates perfect weekly menus just for you.",
            imageName: "brain.head.profile",
            color: .successGreen
        ),
        OnboardingPage(
            title: "Explore & Engage",
            subtitle: "Find great food and earn rewards",
            description: "Discover nearby restaurants with detailed reviews and participate in monthly cooking challenges to earn badges and unlock achievements.",
            imageName: "map.fill",
            color: .accentYellow
        )
    ]
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Page indicator
                HStack {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Color.primaryRed : Color.divider)
                            .frame(width: 8, height: 8)
                            .scaleEffect(currentPage == index ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: currentPage)
                    }
                }
                .padding(.top, 50)
                .padding(.horizontal)
                
                // Content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                // Bottom buttons
                VStack(spacing: 16) {
                    if currentPage < pages.count - 1 {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentPage += 1
                            }
                        }) {
                            Text("Continue")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.primaryRed)
                                .cornerRadius(25)
                        }
                        
                        Button(action: {
                            hasCompletedOnboarding = true
                        }) {
                            Text("Skip")
                                .font(.subheadline)
                                .foregroundColor(.textSecondary)
                        }
                    } else {
                        Button(action: {
                            hasCompletedOnboarding = true
                        }) {
                            Text("Get Started")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.successGreen)
                                .cornerRadius(25)
                        }
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }
        }
        .background(Color.backgroundLight)
        .ignoresSafeArea()
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let description: String
    let imageName: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Icon
            Image(systemName: page.imageName)
                .font(.system(size: 80, weight: .light))
                .foregroundColor(page.color)
                .padding(.bottom, 16)
            
            // Content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
                
                Text(page.subtitle)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(page.color)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .padding(.horizontal, 16)
            }
            
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

#Preview {
    OnboardingView()
}

