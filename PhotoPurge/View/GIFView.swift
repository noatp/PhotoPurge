//
//  GIFView.swift
//  PhotoPurge
//
//  Created by Toan Pham on 1/14/25.
//

import SwiftUI
import UIKit

struct GIFView: UIViewRepresentable {
    let gifName: String

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let gifImageView = UIImageView()
        gifImageView.translatesAutoresizingMaskIntoConstraints = false
        gifImageView.contentMode = .scaleAspectFit
        view.addSubview(gifImageView)

        NSLayoutConstraint.activate([
            gifImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gifImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gifImageView.topAnchor.constraint(equalTo: view.topAnchor),
            gifImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        if let gifPath = Bundle.main.path(forResource: gifName, ofType: "gif") {
            let gifData = try? Data(contentsOf: URL(fileURLWithPath: gifPath))
            gifImageView.image = UIImage.gif(data: gifData!)
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

extension UIImage {
    static func gif(data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        var images = [UIImage]()
        let count = CGImageSourceGetCount(source)

        for i in 0..<count {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(UIImage(cgImage: cgImage))
            }
        }

        return UIImage.animatedImage(with: images, duration: Double(images.count) / 10.0)
    }
}
