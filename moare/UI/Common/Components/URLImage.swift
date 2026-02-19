//
//  URLImage.swift
//  SportSearchEngine_iOS
//
//  Created by Mohwa Yoon on 10/14/24.
//

import SwiftUI
import Kingfisher
import SDWebImageSwiftUI

struct URLImage: View {
    let url: String?
    let isSvg: Bool // TODO: contains(".svg") 사용하는걸로 변경
    
    private let imageSize: CGSize
    
    init(url: String?, size: URLImageSize = .medium, customSize: CGSize? = nil, isSvg: Bool = false) {
        self.url = url
        self.isSvg = isSvg
        
        if let customSize {
            self.imageSize = customSize
        } else {
            self.imageSize = switch size {
            case .small:
                CGSize(width: 30, height: 30)
            case .medium:
                CGSize(width: 50, height: 50)
            case .big:
                CGSize(width: 80, height: 80)
            }
        }
    }
    
    var body: some View {
        if let url {
            if url.contains(".svg") {
                WebImage(url: URL(string: url))
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: imageSize.width,
                        height: imageSize.height
                    )
            } else {
                KFImage(URL(string: url))
                    .placeholder {
                        ProgressView()
                    }
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: imageSize.width,
                        height: imageSize.height
                    )
            }
            
//            AsyncImage(url: URL(string: url)) { image in
//                image
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//            } placeholder: {
//                ProgressView()
//            }
//            .frame(width: customSize != nil ? customSize?.width : imageSize.width, height: customSize != nil ? customSize?.height : imageSize.height)
//            .clipShape(Circle())
        } else {
            // TODO: 사람일때는 person.crop.circle 이걸로 보여주게
            Circle()
                .fill(.secondary)
                .opacity(0.6)
                .frame(
                    width: imageSize.width,
                    height: imageSize.height
                )
        }
    }
    
    enum URLImageSize {
        case small, medium, big
    }
}
