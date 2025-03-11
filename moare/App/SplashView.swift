//
//  SplashView.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/16/25.
//

import Foundation
import SwiftUI

struct SplashView: View {
    @Binding var isSplashFinished: Bool
    
    @State private var animatePosition = false
    @State private var isLogoVisible = false
    @State private var isCiclesVisible = true
    
    var body: some View {
        VStack {
            Image("moare_logo")
                .resizable()
                .frame(width: 200, height: 200)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isSplashFinished = true
                }
            }
        }
//        ZStack {
//            if isCiclesVisible {
//                Circle()
//                    .stroke(.moare, lineWidth: 4)
//                    .frame(width: 60, height: 60)
//                    .offset(x: 0, y: animatePosition ? -35 : 0)
//                
//                Circle()
//                    .stroke(.moare, lineWidth: 4)
//                    .frame(width: 60, height: 60)
//                    .offset(x: animatePosition ? 40 : 0, y: animatePosition ? -9 : 0)
//                
//                Circle()
//                    .stroke(.moare, lineWidth: 4)
//                    .frame(width: 60, height: 60)
//                    .offset(x: animatePosition ? 23 : 0, y: animatePosition ? 35 : 0)
//                
//                Circle()
//                    .stroke(.moare, lineWidth: 4)
//                    .frame(width: 60, height: 60)
//                    .offset(x: animatePosition ? -23 : 0, y: animatePosition ? 35 : 0)
//                
//                Circle()
//                    .stroke(.moare, lineWidth: 4)
//                    .frame(width: 60, height: 60)
//                    .offset(x: animatePosition ? -40 : 0, y: animatePosition ? -9 : 0)
//            }
//            
//            if isLogoVisible {
//                FlowerShape()
//                    .stroke(.moare, lineWidth: 4)
//                    .frame(width: 60, height: 60)
//            }
//        }
//        .onAppear {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                withAnimation(.spring(duration: 0.5)) {
//                    animatePosition = true
//                }
//            }
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
//                withAnimation(.easeInOut(duration: 0.3)) {
//                    isCiclesVisible = false
//                    isLogoVisible = true
//                }
//            }
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
//                withAnimation(.easeInOut(duration: 0.4)) {
//                    isLogoVisible = false
//                }
//            }
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
//                withAnimation(.easeInOut(duration: 0.5)) {
//                    isSplashFinished = true
//                }
//            }
//        }
    }
}

struct FlowerShape: Shape {
    func path(in rect: CGRect) -> Path {
        let firstCenter = CGPoint(x: rect.midX, y: rect.midY - 35)
        let secondCenter = CGPoint(x: rect.midX + 40, y: rect.midY - 9)
        let thirdCenter = CGPoint(x: rect.midX + 23, y: rect.midY + 35)
        let fourthCenter = CGPoint(x: rect.midX - 23, y: rect.midY + 35)
        let fifthCenter = CGPoint(x: rect.midX - 40, y: rect.midY - 9)
        
        let radius: CGFloat = 30
        
        var path = Path()
        
        // First petal
        path.addArc(
            center: firstCenter,
            radius: radius,
            startAngle: .degrees(-170),
            endAngle: .degrees(-10),
            clockwise: false
        )
        
        // Second petal
        path.addArc(
            center: secondCenter,
            radius: radius,
            startAngle: .degrees(-110),
            endAngle: .degrees(70),
            clockwise: false
        )
        
        // Third petal
        path.addArc(
            center: thirdCenter,
            radius: radius,
            startAngle: .degrees(-30),
            endAngle: .degrees(140),
            clockwise: false
        )
        
        // Fourth petal
        path.addArc(
            center: fourthCenter,
            radius: radius,
            startAngle: .degrees(40),
            endAngle: .degrees(210),
            clockwise: false
        )
        
        // Fifth petal
        path.addArc(
            center: fifthCenter,
            radius: radius,
            startAngle: .degrees(110),
            endAngle: .degrees(290),
            clockwise: false
        )
        
        path.closeSubpath()
        
        return path
    }
}

#Preview {
    SplashView(isSplashFinished: .constant(false))
}
