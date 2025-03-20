//
//  SynchronizedScrollView.swift
//  moare
//
//  Created by Mohwa Yoon on 3/11/25.
//

import Foundation
import SwiftUI

struct HSynchronizedScrollView<Content: View>: UIViewRepresentable {
    @Binding var scrollOffset: CGFloat
    @Binding var scrollToHItem: Int?
    @Binding var scrollToVItem: Int?
    let shouldAnimate: Bool
    let itemWidth: CGFloat
    let itemHeight: CGFloat
    let content: Content
    
    init(
        scrollOffset: Binding<CGFloat>,
        scrollToHItem: Binding<Int?> = .constant(nil),
        scrollToVItem: Binding<Int?> = .constant(nil),
        shouldAnimate: Bool = false,
        itemWidth: CGFloat,
        itemHeight: CGFloat,
        @ViewBuilder content: () -> Content
    ) {
        self._scrollOffset = scrollOffset
        self._scrollToHItem = scrollToHItem
        self._scrollToVItem = scrollToVItem
        self.shouldAnimate = shouldAnimate
        self.itemWidth = itemWidth
        self.itemHeight = itemHeight
        self.content = content()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        let hostingController = UIHostingController(rootView: content)
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(hostingController.view)
        scrollView.delegate = context.coordinator
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.showsVerticalScrollIndicator = false  // Disable vertical scrolling
//        scrollView.bounces = false  // Prevents unnecessary bouncing
//        scrollView.decelerationRate = .fast

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hostingController.view.heightAnchor.constraint(equalTo: scrollView.heightAnchor)  // Restrict to horizontal scrolling
        ])

        return scrollView
    }

    func updateUIView(_ uiView: UIScrollView, context: Context) {
        if abs(uiView.contentOffset.x - scrollOffset) > 1 {
            uiView.setContentOffset(CGPoint(x: scrollOffset, y: 0), animated: false)
        }
        
        // Scroll to item when triggered
        if let item = scrollToHItem {
            DispatchQueue.main.async {
                let targetOffset = CGFloat(item) * itemWidth
                
                if shouldAnimate {
                    let animator = UIViewPropertyAnimator(duration: 0.4, curve: .easeInOut) {
                        uiView.setContentOffset(CGPoint(x: targetOffset, y: 0), animated: false)
                    }
                    animator.startAnimation()
                } else {
                    uiView.setContentOffset(CGPoint(x: targetOffset, y: 0), animated: false)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    scrollToHItem = nil
                }
            }
        }
        
        if let item = scrollToVItem {
            DispatchQueue.main.async {
                let targetOffset = CGFloat(item) * itemHeight
                
                if shouldAnimate {
                    let animator = UIViewPropertyAnimator(duration: 0.4, curve: .easeInOut) {
                        uiView.setContentOffset(CGPoint(x: 0, y: targetOffset), animated: false)
                    }
                    animator.startAnimation()
                } else {
                    uiView.setContentOffset(CGPoint(x: 0, y: targetOffset), animated: false)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    scrollToVItem = nil
                }
            }
        }
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: HSynchronizedScrollView

        init(_ parent: HSynchronizedScrollView) {
            self.parent = parent
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            DispatchQueue.main.async {
                self.parent.scrollOffset = scrollView.contentOffset.x
            }
        }
    }
}

struct VSynchronizedScrollView<Content: View>: UIViewRepresentable {
    @Binding var scrollOffset: CGFloat
    let content: Content
    
    init(scrollOffset: Binding<CGFloat>, @ViewBuilder content: () -> Content) {
        self._scrollOffset = scrollOffset
        self.content = content()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        let hostingController = UIHostingController(rootView: content)
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(hostingController.view)
        scrollView.delegate = context.coordinator
        scrollView.showsVerticalScrollIndicator = true
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            hostingController.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor) // Make it scroll vertically only
        ])
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        if abs(uiView.contentOffset.y - scrollOffset) > 1 {
            uiView.setContentOffset(CGPoint(x: 0, y: scrollOffset), animated: false)
        }
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: VSynchronizedScrollView
        
        init(_ parent: VSynchronizedScrollView) {
            self.parent = parent
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            DispatchQueue.main.async {
                self.parent.scrollOffset = scrollView.contentOffset.y
            }
        }
    }
}
