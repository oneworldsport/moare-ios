//
//  EdgePanBackHandler.swift
//  moare
//
//  Created by Mohwa Yoon on 1/23/26.
//

import SwiftUI
import UIKit

struct EdgePanBackHandler: UIViewRepresentable {
    var isEnabled: Bool
    var dragMaxOffset: CGFloat = UIConstants.Width.screenWidth / 3 + 20
    
    var onProgress: (CGFloat) -> Void      // 0~1
    var onCancel: () -> Void
    var onPop: () -> Void
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        
        let edgePan = UIScreenEdgePanGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handle(_:))
        )
        edgePan.edges = .left
        edgePan.cancelsTouchesInView = true   // ✅ 스크롤뷰 터치를 취소시켜 우선권 확보
        view.addGestureRecognizer(edgePan)
        
        context.coordinator.edgePan = edgePan
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.isEnabled = isEnabled
        context.coordinator.dragMaxOffset = dragMaxOffset
        context.coordinator.onProgress = onProgress
        context.coordinator.onCancel = onCancel
        context.coordinator.onPop = onPop
        
        context.coordinator.edgePan?.isEnabled = isEnabled
    }
    
    func makeCoordinator() -> Coordinator { Coordinator() }
    
    final class Coordinator: NSObject {
        var isEnabled: Bool = true
        var dragMaxOffset: CGFloat = 120
        
        var onProgress: ((CGFloat) -> Void)?
        var onCancel: (() -> Void)?
        var onPop: (() -> Void)?
        
        weak var edgePan: UIScreenEdgePanGestureRecognizer?
        
        @objc func handle(_ g: UIScreenEdgePanGestureRecognizer) {
            guard isEnabled else { return }
            guard let view = g.view else { return }
            
            let translation = g.translation(in: view).x
            let clamped = max(0, translation)
            let progress = min(clamped / dragMaxOffset, 1)
            
            switch g.state {
            case .began, .changed:
                onProgress?(progress)
                
            case .ended:
                if clamped > dragMaxOffset {
                    onPop?()
                } else {
                    onCancel?()
                }
                
            case .cancelled, .failed:
                onCancel?()
                
            default:
                break
            }
        }
    }
}
