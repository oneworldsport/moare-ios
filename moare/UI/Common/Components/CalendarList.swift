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
    private let barYOffset: CGFloat
    
    @Binding var shouldScroll: Bool
    @State private var barXOffset: CGFloat
    
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
        
        self.barYOffset =  switch calendarType {
        case .day: 22
        default: 25
        }
        
        self._shouldScroll = shouldScroll
        self._barXOffset = State(initialValue: getOffsetOfAniCapsuleBar(itemWidth: itemWidth, barWidth: itemWidth))
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            ZStack(alignment: .topLeading) {
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
                            barXOffset = getOffsetOfAniCapsuleBar(itemWidth: itemWidth, barWidth: itemWidth, spacing: itemSpacing, index: selectedIndex)
                        }
                    }
                    .onChange(of: selectedIndex) { newValue in
                        if shouldScroll {
                            withAnimation {
                                proxy.scrollTo(newValue, anchor: .leading)
                            }
                        }
                        
                        withAnimation(.spring(duration: 0.5)) {
                            barXOffset = getOffsetOfAniCapsuleBar(itemWidth: itemWidth, barWidth: itemWidth, spacing: itemSpacing, index: newValue)
                        }
                    }
                } // ScrollViewReader
                
                HCapsuleBar(customWidth: itemWidth)
                    .offset(CGSize(width: barXOffset, height: 0))
                    .padding(.top, barYOffset)
                    .padding(.bottom, 2)
            } // ZStack
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
    
    var dayOfWeek: String {
        switch calendarType {
        case .day: "\((date as! DayInfo).displayName)"
        default: ""
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
            VStack(spacing: 0) {
                Text(text)
                    .font(.system(size: 17))
                    .frame(height: 20, alignment: .top)

                if calendarType == .day {
                    Text(dayOfWeek)
                        .font(.system(size: 11, weight: .light))
                        .frame(height: 22, alignment: .bottom)
                }
            }
        }
        .frame(width: width)
        .foregroundStyle(isDisabled ? .secondary : .primary)
        .opacity(isDisabled ? 0.5 : 1)
        .disabled(isDisabled)
    }
}
