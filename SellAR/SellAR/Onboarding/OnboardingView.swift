//
//  OnboardingView.swift
//  SellAR
//
//  Created by Mac on 11/5/24.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var timer: Timer?
    @State private var navigateToNext = false
    
    let onboardingData = [
        (image: "onboarding1", text: "다양한 물건을 거래하는 AR 중고거래"),
        (image: "onboarding2", text: "실제 사이즈를 놓아보는 AR 인테리어"),
        (image: "onboarding3", text: "실제 모습처럼 만드는 AR 3D 스캔")
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .edgesIgnoringSafeArea(.all)
            
                GeometryReader{ geometry in
                    TabView(selection: $currentPage) {
                        ForEach(0..<onboardingData.count, id: \.self) { index in
                            VStack (spacing: 20) {
                                Spacer()
                                Image(onboardingData[index].image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 300)
                                    .foregroundColor(.white)
                                
                                Text(onboardingData[index].text.replacingOccurrences(of: "AR", with: "\nAR"))
                                    .font(.title)
                                    .bold()
                                    .multilineTextAlignment(.center)
                                    .padding()
                                    .foregroundColor(.white)
                                    .lineSpacing(8)
                                Spacer()
                            }
                            .tag(index)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .onAppear{ startAutoSlide() }
                    .onChange(of: currentPage) { _ in startAutoSlide() }
                    
                    HStack(spacing: 8) {
                        ForEach(0..<onboardingData.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? Color.white : Color.gray)
                                .frame(width: 10, height: 10)
                        }
                    }
                    .position(x: geometry.size.width / 2, y: geometry.size.height - 60)
                }
                NavigationLink(destination: EmptyView(), isActive: $navigateToNext) {
                    EmptyView()
                }
            }
        }
    }
    private func startAutoSlide() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            withAnimation {
                if currentPage < onboardingData.count - 1 {
                    currentPage += 1
                } else {
                    navigateToNext = true
                }
            }
        }
    }
}

#Preview {
    OnboardingView()
}
