//
//  FlowStack.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 3/11/24.
//

import SwiftUI

struct FlowStack: View {
    let items: [String: String]
    let itemSpacing: CGFloat = 8
    let lineSpacing: CGFloat = 8
    let horizontalPadding: CGFloat = 10
    @Binding var positions: [ItemPosition]
    @State private var animatePositions: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    
            self.generateContent(in: geometry)
                .opacity(0)
                .coordinateSpace(name: "FlowStack")
                .onPreferenceChange(DDPreferenceKey.self) { positions in
                    self.positions = positions
                }
            
            ForEach(positions) { position in
                if let index = self.items.firstIndex(where: { $0.value == position.id }) {
                    itemView(self.items[index].key, self.items[index].value)
                        .position(animatePositions ? position.position : center)
//                        .scaleEffect(animatePositions ? 1 : 0.01)
                        .onAppear {
                            withAnimation(.spring(response: 1)) {
                                animatePositions = true
                            }
                        }
//                        .animation(
//                            Animation.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0.5),
//                                .delay(0.1 * Double(index)), // Optional: Delay each item's animation for a staggered effect
//                            value: positions
//                        )
                    
                }
            }
        }
    }
    
    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        return ZStack(alignment: .topLeading) {
            ForEach(Array(self.items), id: \.key) { key, value in
                itemView(key, value)
                    .padding([.horizontal], horizontalPadding)
                    .alignmentGuide(.leading) { d in
                        if (abs(width - d.width) > geometry.size.width) {
                            width = 0
                            height -= d.height + lineSpacing
                        }
                        let result = width
                        
                        if key == Array(self.items).last!.key {
                            width = 0 // last item
                        } else {
                            width -= d.width + itemSpacing
                        }
                        return result
                    }
                    .alignmentGuide(.top) {d in
                        let result = height
                        if key == Array(self.items).last!.key {
                            height = 0 // last item
                        }
                        return result
                    }
            }
        }
    }
    
    @ViewBuilder
    private func itemView(_ dataKey: String, _ dataValue: String) -> some View {
        VStack {
            Text(dataKey)
            Text(dataValue)
        }
        .padding(.all, 5)
        .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.moare, lineWidth: 1)
            )
        .background(GeometryReader { geometry in
                Color.clear.preference(key: DDPreferenceKey.self, value: [ItemPosition(id: dataValue,  position: CGPoint(
                    x: geometry.frame(in: .named("FlowStack")).midX,
                    y: geometry.frame(in: .named("FlowStack")).midY
                ))])
//                Color.clear
//                    .onAppear {
//                        let position = geometry.frame(in: .global).origin
//                                            print("Position of \(text): \(position)")
//                    }
//                    .preference(key: DDPreferenceKey.self, value: [ItemPosition(id: text, position: CGPoint(x: geometry.frame(in: .global).minX, y: geometry.frame(in: .global).minY))])
//                        let frame = geo.frame(in: .local)
//                        let position = ItemPosition(id: text, position: CGPoint(x: frame.minX, y: frame.minY))
//                        DispatchQueue.main.async {
//                            // Here we use a method to update the array of positions
//                            // This could be done via a preferenceKey or another state management solution
//                        }
//                        return Color.clear
                })
    }
}

struct ItemPosition: Identifiable, Equatable {
    let id: String  // Assuming each item's content is unique for identification
    let position: CGPoint
}

// TODO: change name
struct DDPreferenceKey: PreferenceKey {
    static var defaultValue: [ItemPosition] = []
    
    static func reduce(value: inout [ItemPosition], nextValue: () -> [ItemPosition]) {
        value.append(contentsOf: nextValue())
    }
}

//#Preview {
//    FlowStack(items: ["One", "Two", "Three", "Four", "Five", "Six", "Seven", "dsfdfsdsfs", "sdfdfsdfdsfd"])
//        .frame(width: .infinity, height: 200)
//}
