//
//  ViewController.swift
//  CollectionView-Layout-Custom
//
//  Created by kawaharadai on 2019/02/10.
//  Copyright © 2019 kawaharadai. All rights reserved.
//

import UIKit
import Photos

final class ViewController: UIViewController {

    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.register(PhotoCell.nib(), forCellWithReuseIdentifier: PhotoCell.identifier)
            if let layout = collectionView.collectionViewLayout as? CollectionViewCustomLayout {
                layout.delegate = self
            }
        }
    }

    var collectionViewCurrentLayout: LayoutType = .insta

    var assets: PHFetchResult<PHAsset> = PHFetchResult() {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }

    var heights: [CGFloat] = [100, 150, 200]

    override func viewDidLoad() {
        super.viewDidLoad()
        switch (PhotosDataStore.needsToRequestAccess(), PhotosDataStore.canAccess()) {
        case (true, _):
            PhotosDataStore.requestAuthorization { [weak self] (success) in
                self?.assets = PhotosDataStore.requestAssets()
            }
        case (_, true):
            assets = PhotosDataStore.requestAssets()
        case (_, false):
            // status is restricted or denied
            fatalError("have no permission")
        }
    }

    private func cellImageSize() -> CGSize {
        let width = UIScreen.main.bounds.size.width
        return CGSize(width: width, height: width)
    }

}

extension ViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.identifier, for: indexPath) as? PhotoCell else { fatalError() }
        cell.setPhotoImage(asset: assets[indexPath.item], imageSize: cellImageSize())
        return cell
    }

}

extension ViewController: LayoutDelegate {

    func layoutType() -> LayoutType {
        return collectionViewCurrentLayout
    }

    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        return heights[Int.random(in: 0..<heights.count)]
    }

}
