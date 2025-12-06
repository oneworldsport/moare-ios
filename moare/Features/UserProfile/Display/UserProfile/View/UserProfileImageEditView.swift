//
//  UserProfileImageEditView.swift
//  moare
//
//  Created by Mohwa Yoon on 11/15/25.
//

import SwiftUI
import ComposableArchitecture
import PhotosUI
import UIKit

struct UserProfileImageEditView: View {
    let store: StoreOf<UserProfileImageEditStore>
    
    @State private var show = false
    
    @State private var pickerItem: PhotosPickerItem?
    @State private var editingImage: UIImage? // 편집할 원본 이미지
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var normalizedOffset: CGSize = .zero // side에 맞게 정규화된 offset
    
    private let side: CGFloat = 800 // s3에 업로드할 이미지 해상도
    
    var body: some View {
        VStack(spacing: 0) {
            if show {
                HStack {
                    BackButton {
                        store.send(.goBack)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if let editingImage {
//                            let size = CGSize(width: 800, height: 800) // 임의의 정사각 해상도
                            let exportOffset = CGSize(
                                width: normalizedOffset.width * side,
                                height: normalizedOffset.height * side
                            )
                            
                            let cropped = makeCroppedImage(
                                from: editingImage,
                                side: side,
                                scale: scale,
                                offset: exportOffset
                            )
                            store.send(.complete(cropped))
                        } else {
                            store.send(.goBack)
                        }
                    }) {
                        Text("완료")
                            .padding(.trailing, 12)
                    }
                }
                .zIndex(1)
                
                AvatarCropView(
                    originalImage: $editingImage,
                    scale: $scale,
                    offset: $offset,
                    normalizedOffset: $normalizedOffset
                )
                
                Rectangle()
                    .fill(.gray)
                    .frame(height: 20)
                
                PhotosPicker(selection: $pickerItem, matching: .images) {
                    EmptyView()
                }
                .photosPickerStyle(.inline)
//                .photosPickerDisabledCapabilities([.search])
                .photosPickerAccessoryVisibility(.hidden)
                .frame(height: 100)
                .onChange(of: pickerItem) {
                    Task {
                        // NOTE: 이미지 선택 해제 했을때 pickerItem이 안바뀌는 버그?가 있다고함.
                        // 해결 방법 찾아야함.
                        guard let pickerItem else {
                            editingImage = nil
                            return
                        }
                        
                        if let data = try? await pickerItem.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            editingImage = uiImage
                        }
                    }
                }
            }
        }
        .onAppear {
            withAnimation(AnimationConstants.AnimationType.mediumDefaultAnimation) {
                show = true
            }
        }
    }
    
    private func makeCroppedImage(
        from image: UIImage,
//        size: CGSize,
        side: CGFloat,
        scale: CGFloat,
        offset: CGSize
    ) -> UIImage {
//        let side = min(size.width, size.height)
        let cropView = CropContentView(
            image: image,
            scale: scale,
            offset: offset,
            side: side
        )
        
        let square = snapshotImage(of: cropView, size: CGSize(width: side, height: side))
        
        // 필요하다면 여기서 square를 circle로 한 번 더 마스킹 가능
        return square
    }
}

//#Preview {
//    UserProfileImageEditView()
//}

struct AvatarCropView: View {
    @Binding var originalImage: UIImage?

    // 제스처 상태
    @Binding var scale: CGFloat
    @State private var lastScale: CGFloat = 1.0
    @Binding var offset: CGSize
    @State private var lastOffset: CGSize = .zero
    @Binding var normalizedOffset: CGSize

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height) * 0.9
            
            ZStack {
                Color.black
                
                if let originalImage {
                    let imageSize = originalImage.size
                    
                    Image(uiImage: originalImage)
                        .resizable()
                        .scaledToFill()
                        .scaleEffect(scale)
                        .offset(offset)
                        .frame(width: side, height: side)
                        .clipped()
//                        .gesture(
//                            dragGesture.simultaneously(with: magnificationGesture)
//                        )
                        .gesture(
                            dragGesture(side: side, imageSize: imageSize)
                                .simultaneously(with: magnificationGesture(side: side, imageSize: imageSize))
                        )
                        .onChange(of: offset) {
                            normalizedOffset = CGSize(
                                width: offset.width / side,
                                height: offset.height / side
                            )
                        }
                }
                
                dimmingOverlay(side: side, image: originalImage)
                    .allowsHitTesting(false) // 제스처 막지 않도록
            }
        }
    }
    
    private func dimmingOverlay(side: CGFloat, image: UIImage?) -> some View {
        if image != nil {
            Color.black.opacity(0.3)
                .frame(width: side, height: side)
    //            .ignoresSafeArea()
                .mask(
                    ZStack {
                        Rectangle()
                        Circle()
                            .frame(width: side, height: side)
                            .blendMode(.destinationOut)
                    }
                )
    //            .compositingGroup()
        } else {
            // 이미지가 없을때는 dimming 배경색을 gray로
            Color.gray.opacity(0.3)
                .frame(width: side, height: side)
                .mask(
                    ZStack {
                        Rectangle()
                        Circle()
                            .frame(width: side, height: side)
                            .blendMode(.destinationOut)
                    }
                )
        }
    }
    
    // 드래그
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                lastOffset = offset
            }
    }

    // 핀치 줌
    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                scale = lastScale * value
            }
            .onEnded { _ in
                // 최소/최대 배율 제한
                scale = min(max(scale, 1.0), 4.0)
                lastScale = scale
            }
    }
    
    // 드래그 제스처 (side, imageSize 기반)
    private func dragGesture(side: CGFloat, imageSize: CGSize) -> some Gesture {
        DragGesture()
            .onChanged { value in
                let proposed = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
                offset = clampedOffset(
                    for: proposed,
                    scale: scale,
                    side: side,
                    imageSize: imageSize
                )
            }
            .onEnded { _ in
                lastOffset = offset
            }
    }
    
    // 핀치 줌도 scale 바뀔 때 offset을 다시 clamp 해주는 게 안전함
    private func magnificationGesture(side: CGFloat, imageSize: CGSize) -> some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let newScale = lastScale * value
                let clampedScale = min(max(newScale, 1.0), 4.0)
                scale = clampedScale
                
                // scale이 줄어들면 기존 offset이 너무 멀리 가 있을 수 있으므로 다시 clamp
                offset = clampedOffset(
                    for: offset,
                    scale: clampedScale,
                    side: side,
                    imageSize: imageSize
                )
            }
            .onEnded { _ in
                scale = min(max(scale, 1.0), 4.0)
                lastScale = scale
            }
    }
    
    private func clampedOffset(
        for proposed: CGSize,
        scale: CGFloat,
        side: CGFloat,
        imageSize: CGSize
    ) -> CGSize {
        let aspect = imageSize.width / imageSize.height
        
        let baseWidth: CGFloat
        let baseHeight: CGFloat
        
        if aspect > 1 {
            // 가로가 더 긴 이미지
            baseWidth = side * aspect
            baseHeight = side
        } else {
            // 세로가 더 긴 이미지(또는 정사각형)
            baseWidth = side
            baseHeight = side / aspect
        }
        
        let scaledWidth = baseWidth * scale
        let scaledHeight = baseHeight * scale
        
        let maxX = max(0, (scaledWidth - side) / 2)
        let maxY = max(0, (scaledHeight - side) / 2)
        
        let clampedX = min(max(proposed.width, -maxX), maxX)
        let clampedY = min(max(proposed.height, -maxY), maxY)
        
        return CGSize(width: clampedX, height: clampedY)
    }
}

struct CropContentView: View {
    let image: UIImage
    let scale: CGFloat
    let offset: CGSize

    let side: CGFloat   // 정사각형 한 변 길이

    var body: some View {
        ZStack {
            Color.black

            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .scaleEffect(scale)
                .offset(offset)
                .frame(width: side, height: side)
                .clipped()
        }
        .frame(width: side, height: side)
    }
}

//func snapshotImage<V: View>(of view: V, size: CGSize) -> UIImage {
//    let controller = UIHostingController(rootView: view)
//    let hostingView = controller.view
//    
//    hostingView?.bounds = CGRect(origin: .zero, size: size)
//    hostingView?.backgroundColor = .clear
//    
//    let renderer = UIGraphicsImageRenderer(size: size)
//    return renderer.image { _ in
//        hostingView?.drawHierarchy(in: hostingView!.bounds, afterScreenUpdates: true)
//    }
//}

@MainActor
func snapshotImage<V: View>(of view: V, size: CGSize) -> UIImage {
    let renderer = ImageRenderer(content: view)
    renderer.proposedSize = .init(size)
    renderer.scale = UIScreen.main.scale

    return renderer.uiImage ?? UIImage()
}
