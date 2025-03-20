//
//  RoundedRectWithPathAni.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 5/26/24.
//

import Foundation
import SwiftUI

struct RoundedRectWithPathAni: View {
    let width: CGFloat
    let height: CGFloat
    let startPoint: CGPoint
    let cornerRadius: CGFloat
    let strokeWidth: CGFloat
    
//    @Binding var drawPath: Bool
    var drawPath: Bool
    
    var body: some View {
        ZStack {
            // left stroke
            Path { path in
                path.move(to: startPoint)
                
                path.addArc(center: CGPoint(x: cornerRadius, y: height - cornerRadius),
                            radius: cornerRadius,
                            startAngle: Angle(degrees: 90),
                            endAngle: Angle(degrees: 180),
                            clockwise: false)
                
                path.addArc(center: CGPoint(x: cornerRadius, y: cornerRadius),
                            radius: cornerRadius,
                            startAngle: Angle(degrees: 180),
                            endAngle: Angle(degrees: 270),
                            clockwise: false)
                
                path.addLine(to: CGPoint(x: width / 2, y: 0))
            }
            .trim(from: 0, to: drawPath ? 1 : 0)
            .stroke(.moare, style: StrokeStyle(lineWidth: strokeWidth))
            .frame(width: width, height: height)
            
            // right stroke
            Path { path in
                path.move(to: startPoint)
                
                path.addArc(center: CGPoint(x: width - cornerRadius, y: height - cornerRadius),
                            radius: cornerRadius,
                            startAngle: Angle(degrees: 90),
                            endAngle: Angle(degrees: 0),
                            clockwise: true)
                
                path.addArc(center: CGPoint(x: width - cornerRadius, y: cornerRadius),
                            radius: cornerRadius,
                            startAngle: Angle(degrees: 0),
                            endAngle: Angle(degrees: 270),
                            clockwise: true)
                
                path.addLine(to: CGPoint(x: width / 2, y: 0))
            }
            .trim(from: 0, to: drawPath ? 1 : 0)
            .stroke(.moare, style: StrokeStyle(lineWidth: strokeWidth))
            .frame(width: width, height: height)
        }
    }
}
