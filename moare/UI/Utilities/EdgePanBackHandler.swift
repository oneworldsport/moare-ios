//
//  EdgePanBackHandler.swift
//  moare
//
//  Created by Mohwa Yoon on 1/23/26.
//

import SwiftUI
import UIKit

struct EdgePanBackInstaller: UIViewRepresentable {
    var isEnabled: Bool
    var edgeWidth: CGFloat = 20
    var dragMaxOffset: CGFloat = UIConstants.Width.screenWidth / 3 + 20
    
    var onProgress: (CGFloat) -> Void      // 0~1
    var onCancel: () -> Void
    var onPop: () -> Void
    
//    func makeUIView(context: Context) -> UIView {
//        let view = UIView(frame: .zero)
//        view.backgroundColor = .clear
//        
//        let edgePan = UIScreenEdgePanGestureRecognizer(
//            target: context.coordinator,
//            action: #selector(Coordinator.handle(_:))
//        )
//        edgePan.edges = .left
//        edgePan.cancelsTouchesInView = true   // ✅ 스크롤뷰 터치를 취소시켜 우선권 확보
//        view.addGestureRecognizer(edgePan)
//        
//        context.coordinator.edgePan = edgePan
//        return view
//    }
//    
//    func updateUIView(_ uiView: UIView, context: Context) {
//        context.coordinator.isEnabled = isEnabled
//        context.coordinator.dragMaxOffset = dragMaxOffset
//        context.coordinator.onProgress = onProgress
//        context.coordinator.onCancel = onCancel
//        context.coordinator.onPop = onPop
//        
//        context.coordinator.edgePan?.isEnabled = isEnabled
//    }
//    
//    func makeCoordinator() -> Coordinator { Coordinator() }
//    
//    final class Coordinator: NSObject {
//        var isEnabled: Bool = true
//        var dragMaxOffset: CGFloat = 120
//        
//        var onProgress: ((CGFloat) -> Void)?
//        var onCancel: (() -> Void)?
//        var onPop: (() -> Void)?
//        
//        weak var edgePan: UIScreenEdgePanGestureRecognizer?
//        
//        @objc func handle(_ g: UIScreenEdgePanGestureRecognizer) {
//            guard isEnabled else { return }
//            guard let view = g.view else { return }
//            
//            let translation = g.translation(in: view).x
//            let clamped = max(0, translation)
//            let progress = min(clamped / dragMaxOffset, 1)
//            
//            switch g.state {
//            case .began, .changed:
//                onProgress?(progress)
//                
//            case .ended:
//                if clamped > dragMaxOffset {
//                    onPop?()
//                } else {
//                    onCancel?()
//                }
//                
//            case .cancelled, .failed:
//                onCancel?()
//                
//            default:
//                break
//            }
//        }
//    }
    
    func makeUIView(context: Context) -> InstallerView {
        let v = InstallerView()
        v.onAttached = { hostView in
            context.coordinator.attachIfNeeded(to: hostView)
        }
        return v
    }
    
    func updateUIView(_ uiView: InstallerView, context: Context) {
        context.coordinator.isEnabled = isEnabled
        context.coordinator.edgeWidth = edgeWidth
        context.coordinator.dragMaxOffset = dragMaxOffset
        context.coordinator.onProgress = onProgress
        context.coordinator.onCancel = onCancel
        context.coordinator.onPop = onPop
        context.coordinator.edgePan?.isEnabled = isEnabled
    }
    
    func makeCoordinator() -> Coordinator { Coordinator() }
    
    final class InstallerView: UIView {
        var onAttached: ((UIView) -> Void)?

        override func didMoveToWindow() {
            super.didMoveToWindow()
            if let w = window {
                onAttached?(w)
            }
        }
    }
    
    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var isEnabled: Bool = true
        var edgeWidth: CGFloat = 20
        var dragMaxOffset: CGFloat = 120
        
        var onProgress: ((CGFloat) -> Void)?
        var onCancel: (() -> Void)?
        var onPop: (() -> Void)?
        
        weak var hostView: UIView?
        weak var edgePan: UIScreenEdgePanGestureRecognizer?
        
        func attachIfNeeded(to host: UIView) {
            if hostView === host { return }
            hostView = host
            
            let g = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handle(_:)))
            g.edges = .left
            g.delegate = self
            
            // “드래그일 때만” 다른 터치를 취소시키고 싶으면 false가 더 시스템스러움
            // (진짜로 인식되면 UIKit이 경쟁에서 이기면서 필요시 취소됨)
            g.cancelsTouchesInView = true
            
            host.addGestureRecognizer(g)
            edgePan = g
        }
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                               shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            // edgePan이면, 다른 제스처는 edgePan이 실패해야만 인식되게
            return gestureRecognizer === edgePan
        }
        
        // 왼쪽 edgeWidth 안에서 시작한 터치만 받기
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            guard isEnabled, let v = hostView else { return false }
            let p = touch.location(in: v)
            return p.x <= edgeWidth
        }
        
        // 수평 드래그 성향일 때만 시작
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard isEnabled,
                  let pan = gestureRecognizer as? UIScreenEdgePanGestureRecognizer,
                  let v = hostView
            else { return false }
            let vel = pan.velocity(in: v)
            return abs(vel.x) > abs(vel.y)   // 수평 우선
        }
        
        // 동시 인식 허용여부
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                               shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            false
        }
        
        @objc func handle(_ g: UIScreenEdgePanGestureRecognizer) {
            guard isEnabled, let v = hostView else { return }
            
            let translation = g.translation(in: v).x
            let clamped = max(0, translation)
            let progress = min(clamped / dragMaxOffset, 1)
            
            switch g.state {
            case .began, .changed:
                onProgress?(progress)
            case .ended:
                if clamped > dragMaxOffset { onPop?() }
                else { onCancel?() }
            case .cancelled, .failed:
                onCancel?()
            default:
                break
            }
        }
    }
}
