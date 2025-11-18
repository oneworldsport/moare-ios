//
//  DefaultProfileImage.swift
//  moare
//
//  Created by Mohwa Yoon on 11/13/25.
//

import SwiftUI
import Kingfisher

enum ProfileImageSize {
    case small, medium, big
}

struct ProfileImage: View {
    let url: String?
    
    private let imageSize: CGFloat
    
    init(
        url: String?,
        size: ProfileImageSize = .big,
        customSize: CGFloat? = nil
    ) {
        self.url = url
        
        if let customSize {
            self.imageSize = customSize
        } else {
            self.imageSize = switch size {
            case .small: 30
            case .medium: 50
            case .big: 80
            }
        }
    }
    
    var body: some View {
        if let url {
            KFImage(URL(string: url))
                .placeholder {
                    ProgressView()
                }
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
                .frame(
                    width: imageSize,
                    height: imageSize
                )
        } else {
            DefaultProfileImage(size: imageSize)
        }
    }
}

struct DefaultProfileImage: View {
    let size: CGFloat
    
    var body: some View {
        Image(systemName: "person")
            .font(.system(size: size))
            .foregroundStyle(.secondary)
            .offset(x: 0, y: 13)
        .background(
            Circle()
                .strokeBorder(.secondary, lineWidth: 2)
        )
        .mask {
            Circle()
        }
    }
}

struct UpdateFormProfileImage: View {
    let url: String?
    let size: CGFloat
    
    var body: some View {
        if let url {
            KFImage(URL(string: url))
                .placeholder {
                    ProgressView()
                }
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
                .frame(
                    maxWidth: size,
                    maxHeight: size
                )
                .overlay {
                    ZStack(alignment: .bottomTrailing) {
                        Circle()
                            .opacity(0)
                        
                        Image(systemName: "photo")
                            .font(.system(size: 20))
                            .foregroundStyle(.primary)
                            .opacity(0.7)
                            .background(
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(.white)
                                    .shadow(radius: 3)
                            )
                            .offset(x: -8, y: -8)
                    }
                }
        } else {
            UpdateFormDefaultProfileImage(size: size)
                .overlay {
                    ZStack(alignment: .bottomTrailing) {
                        Circle()
                            .opacity(0)
                        
                        Image(systemName: "photo")
                            .font(.system(size: 20))
                            .foregroundStyle(.primary)
                            .opacity(0.7)
                            .background(
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(.white)
                                    .shadow(radius: 3)
                            )
                            .offset(x: -8, y: -8)
                    }
                }
        }
    }
}

struct UpdateFormDefaultProfileImage: View {
    let size: CGFloat
    
    var body: some View {
        Image(systemName: "person")
            .font(.system(size: size))
            .foregroundStyle(.secondary)
            .offset(x: 0, y: 18)
//            .frame(maxWidth: size, maxHeight: size)
        .background(
            Circle()
                .strokeBorder(.secondary, lineWidth: 2)
        )
        .mask {
            Circle()
        }
    }
}
