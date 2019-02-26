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

    @IBOutlet private weak var segmentedControl: UISegmentedControl!

    var collectionViewCurrentLayout: LayoutType = .grid

    var assets: PHFetchResult<PHAsset> = PHFetchResult()

    override func viewDidLoad() {
        super.viewDidLoad()
        switch (PhotosDataStore.needsToRequestAccess(), PhotosDataStore.canAccess()) {
        case (true, _):
            PhotosDataStore.requestAuthorization { [weak self] (success) in
                self?.assets = PhotosDataStore.requestAssets()
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            }
        case (_, true):
            assets = PhotosDataStore.requestAssets()
        case (_, false):
            // status is restricted or denied
            fatalError("have no permission")
        }
    }

    @IBAction func tapSegment(_ sender: UISegmentedControl) {
        guard let layout = LayoutType(rawValue: sender.selectedSegmentIndex) else {
            sender.selectedSegmentIndex = 0
            return
        }
        collectionViewCurrentLayout = layout
        collectionView.reloadData()
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
        cell.setupPhotoCell(asset: assets[indexPath.item], imageSize: cellImageSize(), layoutType: collectionViewCurrentLayout)
        return cell
    }

}

extension ViewController: LayoutDelegate {

    func layoutType() -> LayoutType {
        return collectionViewCurrentLayout
    }

    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        // VC側から高さを渡す場合はここで渡す（indexPathごとに渡すため都度異なる高さを渡せる）
        return collectionView.frame.size.height
    }

}
