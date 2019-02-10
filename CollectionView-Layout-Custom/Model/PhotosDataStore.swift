//
//  PhotosDataStore.swift
//  CollectionView-Layout-Custom
//
//  Created by kawaharadai on 2019/02/10.
//  Copyright © 2019 kawaharadai. All rights reserved.
//

import Photos

final class PhotosDataStore {

    static func requestAssets() -> PHFetchResult<PHAsset> {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return PHAsset.fetchAssets(with: .image, options: options)
    }

    static func canAccess() -> Bool {
        return PHPhotoLibrary.authorizationStatus() == .authorized
    }

    static func needsToRequestAccess() -> Bool {
        return PHPhotoLibrary.authorizationStatus() == .notDetermined
    }

    static func requestAuthorization(completion handler: @escaping (Bool) -> Void) {
        guard PhotosDataStore.needsToRequestAccess() else {
            handler(PhotosDataStore.canAccess())
            return
        }
        PHPhotoLibrary.requestAuthorization { _ in
            handler(PhotosDataStore.canAccess())
        }
    }

}
