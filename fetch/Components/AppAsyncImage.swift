//
//  AsyncImageLoader.swift
//  fetch
//
//  Created by Veeral Suthar on 9/5/24.
//

import SwiftUI

struct AppAsyncImage: View {
  var url: URL?
  var width: CGFloat
  var height: CGFloat
  
  var body: some View {
    AsyncImage(url: url) { phase in
      switch phase {
      case .success(let image):
        image.resizable()
          .aspectRatio(contentMode: .fill)
          .frame(width: width, height: height)
      case .failure(let error):
        if error._code == -999 {
          AsyncImage(url: url) { phase in
            if let image = phase.image {
              image
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
            } else{
              ProgressView()
            }
          }
        }
        else {
          Image(systemName: "xmark.square")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: width, height: height)
        }
      case .empty:
        ProgressView()
      @unknown default:
        Image(systemName: "xmark.square")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: width, height: height)
      }
    }
  }
}
