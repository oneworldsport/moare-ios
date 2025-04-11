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
    let size: URLImageSize
    let customSize: CGSize?
    let isSvg: Bool
    
    init(url: String?, size: URLImageSize = .medium, customSize: CGSize? = nil, isSvg: Bool = false) {
        self.url = url
        self.size = size
        self.customSize = customSize
        self.isSvg = isSvg
    }
    
    var body: some View {
        if let url = url {
            if isSvg {
                WebImage(url: URL(string: url))
                    .resizable()
                    .scaledToFit()
                    .frame(width: customSize != nil ? customSize?.width : imageSize.width, height: customSize != nil ? customSize?.height : imageSize.height)
            } else {
                KFImage(URL(string: url))
                    .placeholder {
                        ProgressView()
                    }
                    .resizable()
                    .scaledToFit()
                    .frame(width: customSize != nil ? customSize?.width : imageSize.width, height: customSize != nil ? customSize?.height : imageSize.height)
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
        }
    }
    
    private var imageSize: CGSize {
            switch size {
            case .small:
                return CGSize(width: 30, height: 30)
            case .medium:
                return CGSize(width: 50, height: 50)
            case .big:
                return CGSize(width: 80, height: 80)
            }
        }
    
    enum URLImageSize {
        case small, medium, big
    }
}
