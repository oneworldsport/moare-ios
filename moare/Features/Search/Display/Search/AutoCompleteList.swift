//
//  SearchList.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 3/5/24.
//

import SwiftUI

struct AutoCompleteList: View {
    let autoCompleteList: [String]
    let onItemSelected: (String) -> ()
    
    let itemHeight:CGFloat = 34
    let itemBottomPadding: CGFloat = 3
    let maxVisibleItemCount = 6
    
    @State private var selectedKeyword = ""
    @State private var isOpened = false
    
    var body: some View {
        ScrollView {
            HStack {
                Spacer()
            }
            
            VStack(spacing: 0) {
                ForEach(autoCompleteList.indices, id: \.self) { index in
                    let keyword = autoCompleteList[index]
                    
                    // selectedItemIndex 로직을 사용하면 Item을 다시 그리기 때문에 애니메이션이 원하느대로 동작x
                    AutoCompleteItem(
                        keyword: keyword,
                        height: itemHeight,
                        bottomPadding: itemBottomPadding,
                        selectedKeyword: $selectedKeyword
                    ) { selectedWord in
                        onItemSelected(selectedWord)
                    }
                    .vSequentialListAni(
                        index: index,
                        itemCount: autoCompleteList.count,
                        itemHeight: itemHeight,
                        aniDelay: isOpened ? 0 : 0.1, // apply animation only on first open
                        aniDuration: isOpened ? 0 : 0.5 // apply animation only on first open
                    )
                }
            }
            .onAppear {
                self.isOpened = true
            }
        }
        .padding(.vertical, 0)
        .frame(maxHeight: calculateMaxHeight())
        .scrollDisabled(autoCompleteList.count > maxVisibleItemCount ? false : true)
    }
    
    private func calculateMaxHeight() -> CGFloat {
        if autoCompleteList.count > maxVisibleItemCount {
            return (itemHeight + itemBottomPadding) * CGFloat(maxVisibleItemCount)
        } else {
            return (itemHeight + itemBottomPadding) * CGFloat(autoCompleteList.count)
        }
    }
}

struct AutoCompleteItem: View {
    let keyword: String
    let height: CGFloat
    let bottomPadding: CGFloat
    @Binding var selectedKeyword: String
    let onItemSelected: (String) -> ()
    
    @State var shouldStartSelectedItemAni = false
    
    var body: some View {
        if selectedKeyword.isEmpty || selectedKeyword == keyword {
            Button(action: {
                withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                    selectedKeyword = keyword
                    shouldStartSelectedItemAni = true
                }
                
                onItemSelected(keyword)
            }) {
                HStack(spacing: 0) {
                    // TODO: 양 끝 사이드 stroke만 남기면서 animation하는게 잘 안돼서 괄호를 사용했는데 디자인이 맘에 안듦. 고민하고 수정 필요
                    Text("(")
                        .font(.system(size: 23))
                        .padding(.bottom, bottomPadding)
                        .foregroundColor(.moare)
                    
                    Text(keyword)
                        .padding(.horizontal, 4)
                        
                    Spacer()
                        .frame(maxWidth: shouldStartSelectedItemAni ? 0 : .infinity)
                    
                    Text(")")
                        .font(.system(size: 23))
                        .padding(.bottom, bottomPadding)
                        .foregroundColor(.moare)
                }
            }
            .frame(height: height)
            .padding(.horizontal, UIConstants.Padding.defaultHPadding)
            .foregroundColor(.primary)
        }
    }
}

//#Preview {
//    let data = ["test", "test1", "test2"]
//    return AutoCompleteList(data: data, onItemSelected: {_ in })
//}
