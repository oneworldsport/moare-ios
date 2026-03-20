//
//  Zoom.swift
//  moare
//
//  Created by Mohwa Yoon on 3/19/26.
//

import SwiftUI

//struct ZoomableScrollView<Content: View>: UIViewRepresentable {
//    let content: Content
//    let contentSize: CGSize
//    var minZoomScale: CGFloat = 0.5
//    var maxZoomScale: CGFloat = 1.5
//
//    init(
//        contentSize: CGSize,
//        minZoomScale: CGFloat = 0.5,
//        maxZoomScale: CGFloat = 1.5,
//        @ViewBuilder content: () -> Content
//    ) {
//        self.contentSize = contentSize
//        self.minZoomScale = minZoomScale
//        self.maxZoomScale = maxZoomScale
//        self.content = content()
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(hostingController: UIHostingController(rootView: content))
//    }
//
//    func makeUIView(context: Context) -> UIScrollView {
//        let scrollView = UIScrollView()
//        scrollView.delegate = context.coordinator
//        scrollView.minimumZoomScale = minZoomScale
//        scrollView.maximumZoomScale = maxZoomScale
//        scrollView.bouncesZoom = true
//        scrollView.showsHorizontalScrollIndicator = true
//        scrollView.showsVerticalScrollIndicator = true
//
//        let hostedView = context.coordinator.hostingController.view!
//        hostedView.translatesAutoresizingMaskIntoConstraints = true
//        hostedView.backgroundColor = .clear
//
//        scrollView.addSubview(hostedView)
//        context.coordinator.hostedView = hostedView
//
//        return scrollView
//    }
//
////    func updateUIView(_ scrollView: UIScrollView, context: Context) {
////        context.coordinator.hostingController.rootView = content
////
////        guard let hostedView = context.coordinator.hostedView else { return }
////
////        let targetSize = context.coordinator.hostingController.sizeThatFits(in: CGSize(
////            width: UIView.layoutFittingCompressedSize.width,
////            height: UIView.layoutFittingCompressedSize.height
////        ))
////
////        hostedView.frame = CGRect(origin: .zero, size: targetSize)
////        scrollView.contentSize = targetSize
////
////        context.coordinator.centerContent(in: scrollView)
////    }
//    func updateUIView(_ scrollView: UIScrollView, context: Context) {
//        context.coordinator.hostingController.rootView = content
//
//        guard let hostedView = context.coordinator.hostedView else { return }
//        
//        guard contentSize != .zero else { return }
//
//        hostedView.frame = CGRect(origin: .zero, size: contentSize)
//        scrollView.contentSize = contentSize
//
////        let fittedSize = context.coordinator.hostingController.sizeThatFits(in: CGSize(
////            width: UIView.layoutFittingCompressedSize.width,
////            height: UIView.layoutFittingCompressedSize.height
////        ))
////
////        let targetSize = CGSize(
////            width: ceil(fittedSize.width),
////            height: ceil(fittedSize.height) + 12
////        )
////
////        hostedView.frame = CGRect(origin: .zero, size: targetSize)
////        scrollView.contentSize = targetSize
//
//        context.coordinator.centerContent(in: scrollView)
//    }
//
//    class Coordinator: NSObject, UIScrollViewDelegate {
//        let hostingController: UIHostingController<Content>
//        weak var hostedView: UIView?
//
//        init(hostingController: UIHostingController<Content>) {
//            self.hostingController = hostingController
//        }
//
//        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//            hostedView
//        }
//
//        func scrollViewDidZoom(_ scrollView: UIScrollView) {
//            centerContent(in: scrollView)
//        }
//
////        func centerContent(in scrollView: UIScrollView) {
////            guard let hostedView = hostedView else { return }
////
////            let boundsSize = scrollView.bounds.size
////            let contentFrame = hostedView.frame
////
////            let insetX = max((boundsSize.width - contentFrame.width) / 2, 0)
////            let insetY = max((boundsSize.height - contentFrame.height) / 2, 0)
////
////            scrollView.contentInset = UIEdgeInsets(
////                top: insetY,
////                left: insetX,
////                bottom: insetY,
////                right: insetX
////            )
////        }
//        func centerContent(in scrollView: UIScrollView) {
//            guard scrollView.zoomScale > scrollView.minimumZoomScale else {
//                scrollView.contentInset = .zero
//                return
//            }
//
//            let boundsSize = scrollView.bounds.size
//            let scaledContentWidth = scrollView.contentSize.width * scrollView.zoomScale
//            let scaledContentHeight = scrollView.contentSize.height * scrollView.zoomScale
//
//            let insetX = max((boundsSize.width - scaledContentWidth) / 2, 0)
//            let insetY = max((boundsSize.height - scaledContentHeight) / 2, 0)
//
//            scrollView.contentInset = UIEdgeInsets(
//                top: insetY,
//                left: insetX,
//                bottom: insetY,
//                right: insetX
//            )
//        }
//    }
//}


struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    let content: Content
    let minZoomScale: CGFloat
    let maxZoomScale: CGFloat
    
    init(
        minZoomScale: CGFloat = 0.5,
        maxZoomScale: CGFloat = 1.5,
        @ViewBuilder content: () -> Content
    ) {
        self.minZoomScale = minZoomScale
        self.maxZoomScale = maxZoomScale
        self.content = content()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(rootView: content)
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = minZoomScale
        scrollView.maximumZoomScale = maxZoomScale
        scrollView.bouncesZoom = true
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.showsVerticalScrollIndicator = true
        scrollView.delegate = context.coordinator

        let containerView = context.coordinator.containerView
        let hostedView = context.coordinator.hostingController.view!
//        hostedView.translatesAutoresizingMaskIntoConstraints = true
        hostedView.translatesAutoresizingMaskIntoConstraints = false
//        hostedView.frame = scrollView.bounds
        hostedView.backgroundColor = .clear
        
        containerView.addSubview(hostedView)
        
        NSLayoutConstraint.activate([
            hostedView.topAnchor.constraint(equalTo: containerView.topAnchor),
            hostedView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            hostedView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            hostedView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        scrollView.addSubview(containerView)
//        context.coordinator.hostedView = hostedView
        
        return scrollView
    }

    func updateUIView(_ scrollView: UIScrollView, context: Context) {
//        context.coordinator.hostingController.rootView = content
//        context.coordinator.hostingController.view.sizeToFit()
        
//        let hostedView = context.coordinator.hostingController.view!
//        
//        context.coordinator.hostingController.rootView = content
//        
//        hostedView.setNeedsLayout()
//        hostedView.layoutIfNeeded()
//        hostedView.invalidateIntrinsicContentSize()
//        
//        DispatchQueue.main.async {
//            let fittingSize = context.coordinator.hostingController.sizeThatFits(in: CGSize(
//                width: UIView.layoutFittingCompressedSize.width,
//                height: UIView.layoutFittingCompressedSize.height
//            ))
//            
//            hostedView.frame = CGRect(origin: .zero, size: fittingSize)
//            scrollView.contentSize = fittingSize
//        }
        
        let coordinator = context.coordinator
        let hostedView = coordinator.hostingController.view!
        let containerView = coordinator.containerView
        
        coordinator.hostingController.rootView = content
        
        let currentZoomScale = scrollView.zoomScale
        
        let fittingSize = coordinator.hostingController.sizeThatFits(in: CGSize(
            width: UIView.layoutFittingCompressedSize.width,
            height: UIView.layoutFittingCompressedSize.height
        ))
        
        // 원본 콘텐츠 크기만 갱신
        containerView.frame = CGRect(origin: .zero, size: fittingSize)
        hostedView.frame = containerView.bounds
        
        // contentSize는 "원본 크기"
        scrollView.contentSize = fittingSize
        
        // 줌 상태 유지
        if scrollView.zoomScale != currentZoomScale {
            scrollView.zoomScale = currentZoomScale
        }
    }

    
    class Coordinator: NSObject, UIScrollViewDelegate {
        let hostingController: UIHostingController<Content>
        let containerView = UIView()

        init(rootView: Content) {
            hostingController = UIHostingController(rootView: rootView)
            self.hostingController.view.backgroundColor = .clear
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            containerView
//            hostingController.view
        }
    }
}
