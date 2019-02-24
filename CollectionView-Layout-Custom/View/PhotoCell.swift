//
//  PhotoCell.swift
//  CollectionView-Layout-Custom
//
//  Created by kawaharadai on 2019/02/10.
//  Copyright © 2019 kawaharadai. All rights reserved.
//

import UIKit
import Photos

final class PhotoCell: UICollectionViewCell {

    @IBOutlet private weak var imageView: UIImageView!

    static var identifier: String {
        return String(describing: self)
    }

    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    private let options = { () -> PHImageRequestOptions in
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        options.version = .original
        return options
    }()

    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
    }

    func setupPhotoCell(asset: PHAsset, imageSize: CGSize, layoutType: LayoutType) {
        switch layoutType {
        case .pintarest:
            setLayer(cornerRadius: 5)
        default: break
        }
        PHImageManager.default().requestImage(for: asset,
                                                     targetSize: imageSize,
                                                     contentMode: .aspectFit,
                                                     options: options) { [weak self] (image, dic) in
                                                        self?.imageView.image = image
        }
    }

    func setLayer(cornerRadius: CGFloat) {
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = cornerRadius
    }

}
