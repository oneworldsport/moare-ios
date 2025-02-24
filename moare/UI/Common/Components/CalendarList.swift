//
//  CalendarList.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 1/7/25.
//

import SwiftUI

enum CalendarType {
    case season, yearmonth, month, day
}

struct CalendarList<T>: View {
    let dateList: [T]
    let calendarType: CalendarType
    let selectedIndex: Int
    var onItemSelected: (T, Int) -> Void
    
    private let itemWidth: CGFloat
    private let itemSpacing: CGFloat
    
    @Binding var shouldScroll: Bool
    @State private var barOffset: CGSize
    
    init(dateList: [T], calendarType: CalendarType, selectedIndex: Int, shouldScroll: Binding<Bool> = .constant(false), onItemSelected: @escaping (T, Int) -> Void) {
        self.dateList = dateList
        self.calendarType = calendarType
        self.selectedIndex = selectedIndex
        self.onItemSelected = onItemSelected
        
        self.itemWidth = switch calendarType {
        case .season: 200
        case .yearmonth: 55
        case .month: 50
        case .day: 30
        }
        
        self.itemSpacing = switch calendarType {
        case .season: 20
        case .yearmonth: 12
        case .month: 10
        case .day: 0
        }
        
        self._shouldScroll = shouldScroll
        self._barOffset = State(initialValue: getOffsetOfAniCapsuleBar(itemWidth: itemWidth, barWidth: itemWidth))
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            VStack(alignment: .leading, spacing: 8) {
                ScrollViewReader { proxy in
                    HStack(spacing: itemSpacing) {
                        ForEach(dateList.indices, id: \.self) { index in
                            let date = dateList[index]
                            
                            CalendarListItem(
                                date: date,
                                calendarType: calendarType,
                                width: itemWidth
                            ) {
                                onItemSelected(date, index)
                            }
                        }
                    }
                    .onAppear {
                        withAnimation {
                            proxy.scrollTo(selectedIndex, anchor: .leading)
                        }
                        
                        withAnimation(.spring(duration: 0.5)) {
                            barOffset = getOffsetOfAniCapsuleBar(itemWidth: itemWidth, barWidth: itemWidth, spacing: itemSpacing, index: selectedIndex)
                        }
                    }
                    .onChange(of: selectedIndex) { newValue in
                        if shouldScroll {
                            withAnimation {
                                proxy.scrollTo(newValue, anchor: .leading)
                            }
                        }
                        
                        withAnimation(.spring(duration: 0.5)) {
                            barOffset = getOffsetOfAniCapsuleBar(itemWidth: itemWidth, barWidth: itemWidth, spacing: itemSpacing, index: newValue)
                        }
                    }
                } // ScrollViewReader
                
                HCapsuleBar(customWidth: itemWidth)
                    .offset(barOffset)
            }
        } // ScrollView
        .padding(.horizontal, 5)
    }
}

struct CalendarListItem<T>: View {
    let date: T
    let calendarType: CalendarType
    let width: CGFloat
    
    var onItemSelected: () -> Void
    
    var text: String {
        switch calendarType {
        case .day: "\((date as! DayInfo).day)"
        default: "\(date)"
        }
    }
    
    var isDisabled: Bool {
        switch calendarType {
        case .day: (date as! DayInfo).isDataEmpty
        default: false
        }
    }
    
    var body: some View {
        Button(action: {
            onItemSelected()
        }) {
            Text(text)
                .font(.system(size: 17))
                .frame(width: width)
        }
        .foregroundStyle(isDisabled ? .secondary : .primary)
        .opacity(isDisabled ? 0.5 : 1)
        .disabled(isDisabled)
    }
}
