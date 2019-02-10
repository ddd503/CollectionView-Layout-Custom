//
//  CollectionViewCustomLayout.swift
//  CollectionView-Layout-Custom
//
//  Created by kawaharadai on 2019/02/10.
//  Copyright © 2019 kawaharadai. All rights reserved.
//

import UIKit

// VC側にも準拠
protocol LayoutDelegate: class {
    func collectionView(_ collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat
}

final class CollectionViewCustomLayout: UICollectionViewLayout {

    weak var delegate: LayoutDelegate?
    var contentBounds = CGRect.zero
    // オブジェクトの種類をキャッシュする
    var cachedAttributes = [UICollectionViewLayoutAttributes]()

    fileprivate var numberOfColumns = 2
    fileprivate var cellPadding: CGFloat = 6
    fileprivate var contentHeight: CGFloat = 0
    fileprivate var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    // レイアウト準備のため計算を行う
    override func prepare() {
        // 1
        guard cachedAttributes.isEmpty == true, let collectionView = collectionView else {
            return
        }
        // 2
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset = [CGFloat]()
        for column in 0 ..< numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        var column = 0
        var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)

        // 3
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {

            let indexPath = IndexPath(item: item, section: 0)

            // 4
            let photoHeight = delegate?.collectionView(collectionView, heightForPhotoAtIndexPath: indexPath)
            let height = cellPadding * 2 + photoHeight!
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)

            // 5
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cachedAttributes.append(attributes)

            // 6
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height

            column = column < (numberOfColumns - 1) ? (column + 1) : 0
        }
    }

    // スクロール領域を決定
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }

    // レイアウト内のオブジェクトの配列を返す（cellやheader等）
    // 画面内のレイアウト属性を決定する
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // このやり方は一回ごとに全検索をかけるため効率が悪い最初のヒットで拾うようにする
        return cachedAttributes.filter({ (layoutAttributes) -> Bool in
            rect.intersects(layoutAttributes.frame)
        })
    }

    // パーツのindexごとに必要なレイアウト属性を返す（cellもheaderも混ざった状態）
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cachedAttributes[indexPath.item]
    }

}
