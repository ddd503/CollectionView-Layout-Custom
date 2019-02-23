//
//  CollectionViewCustomLayout.swift
//  CollectionView-Layout-Custom
//
//  Created by kawaharadai on 2019/02/10.
//  Copyright © 2019 kawaharadai. All rights reserved.
//

import UIKit

enum LayoutType {
    case grid
    case insta
    case pintarest
    case tiktok
}

// VC側にも準拠
protocol LayoutDelegate: class {
    func layoutType() -> LayoutType
    func collectionView(_ collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat
}

final class CollectionViewCustomLayout: UICollectionViewLayout {

    weak var delegate: LayoutDelegate?

    var contentBounds = CGRect.zero
    // オブジェクトの種類をキャッシュする
    var cachedAttributes = [UICollectionViewLayoutAttributes]()
    // 列の数
    private var numberOfColumns = 3
    // セル周囲のスペース
    private var cellPadding: CGFloat = 1
    // レイアウトの総Height
    private var contentHeight: CGFloat = 0
    // レイアウトの総Width
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }

    override func prepare() {
        guard let type = delegate?.layoutType() else {
            return
        }
        switch type {
        case .grid:
            gridAttributes()
        case .insta:
            instaAttributes()
        default:
            break
        }
    }

    override var collectionViewContentSize: CGSize {
        // prepareが終わった後に呼ばれるので、計算したcontentHeightを返す
        return CGSize(width: contentWidth, height: contentHeight)
    }

    // レイアウト内のオブジェクトの配列を返す（cellやheader等）
    // 画面内のレイアウト属性を決定する
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // collectionViewが配置処理を行う場所にあるlayoutAttributesを返す（持っているframeの一致を利用して、万が一一致しない場合は配置自体しない）
        // このやり方は一回ごとに全検索をかけるため効率が悪い最初のヒットで拾うようにする
        // 辞書のkeyで一致もあり？
        return cachedAttributes.filter({ (layoutAttributes) -> Bool in
            rect.intersects(layoutAttributes.frame)
        })
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cachedAttributes[indexPath.item]
    }

    // baseLayout
    private func baseAttributes() {
        guard cachedAttributes.isEmpty, let collectionView = collectionView else { return }
        let cellWidth = contentWidth / CGFloat(numberOfColumns)
        let cellXOffsets = (0 ..< numberOfColumns).map {
            CGFloat($0) * cellWidth
        }
        var cellYOffsets = [CGFloat](repeating: 0, count: numberOfColumns)
        var currentColumnNumber = 0
        (0 ..< collectionView.numberOfItems(inSection: 0)).forEach {
            let indexPath = IndexPath(item: $0, section: 0)
            let itemHeight = delegate?.collectionView(collectionView, heightForPhotoAtIndexPath: indexPath) ?? 0
            let cellHeight = cellPadding * 2 + itemHeight
            let cellFrame = CGRect(x: cellXOffsets[currentColumnNumber], y: cellYOffsets[currentColumnNumber], width: cellWidth, height: cellHeight)
            let itemFrame = cellFrame.insetBy(dx: cellPadding, dy: cellPadding)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = itemFrame
            cachedAttributes.append(attributes)
            contentHeight = max(contentHeight, cellFrame.maxY)
            cellYOffsets[currentColumnNumber] = cellYOffsets[currentColumnNumber] + cellHeight
            currentColumnNumber = currentColumnNumber < (numberOfColumns - 1) ? currentColumnNumber + 1 : 0
        }
    }

    private func gridAttributes() {
        guard cachedAttributes.isEmpty, let collectionView = collectionView else { return }
        let cellLength = contentWidth / CGFloat(numberOfColumns)
        let cellXOffsets = (0 ..< numberOfColumns).map {
            CGFloat($0) * cellLength
        }
        var cellYOffsets = [CGFloat](repeating: 0, count: numberOfColumns)
        var currentColumnNumber = 0
        (0 ..< collectionView.numberOfItems(inSection: 0)).forEach {
            let indexPath = IndexPath(item: $0, section: 0)
            let cellFrame = CGRect(x: cellXOffsets[currentColumnNumber], y: cellYOffsets[currentColumnNumber], width: cellLength, height: cellLength)
            let itemFrame = cellFrame.insetBy(dx: cellPadding, dy: cellPadding)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = itemFrame
            cachedAttributes.append(attributes)
            contentHeight = max(contentHeight, cellFrame.maxY)
            cellYOffsets[currentColumnNumber] = cellYOffsets[currentColumnNumber] + cellLength
            currentColumnNumber = currentColumnNumber < (numberOfColumns - 1) ? currentColumnNumber + 1 : 0
        }
    }

    private func instaAttributes() {
        let layoutBaseNumber = 17
        guard cachedAttributes.isEmpty, let collectionView = collectionView else { return }
        let baseLength = contentWidth / CGFloat(numberOfColumns)
        let cellXOffsets = (0 ..< numberOfColumns).map {
            CGFloat($0) * baseLength
        }
        var cellYOffsets = [CGFloat](repeating: 0, count: numberOfColumns)
        var currentColumnNumber = 0

        (0 ..< collectionView.numberOfItems(inSection: 0)).forEach {
            let indexPath = IndexPath(item: $0, section: 0)
            var cellFrame: CGRect = .zero
            var cellLength: CGFloat = 0
            // 配置場所を表す番号
            let cellNumber = $0 % (layoutBaseNumber + 1)
            
            switch cellNumber {
            case 0:
                cellLength = baseLength * 2
                cellFrame = CGRect(x: cellXOffsets[currentColumnNumber], y: cellYOffsets[currentColumnNumber], width: cellLength, height: cellLength)
                cellYOffsets[currentColumnNumber] = cellYOffsets[currentColumnNumber] + cellLength
                print(cellFrame)
            case 1:
                cellLength = baseLength
                cellFrame = CGRect(x: cellXOffsets[currentColumnNumber + 1], y: cellYOffsets[currentColumnNumber], width: cellLength, height: cellLength)
                cellYOffsets[currentColumnNumber] = cellYOffsets[currentColumnNumber] + (cellLength * 2)
                print(cellFrame)
            case 2:
                cellLength = baseLength
                cellFrame = CGRect(x: cellXOffsets[currentColumnNumber], y: cellYOffsets[currentColumnNumber] + baseLength, width: cellLength, height: cellLength)
                cellYOffsets[currentColumnNumber] = cellYOffsets[currentColumnNumber] + (cellLength * 2)
                print(cellFrame)
            case 9:
                cellLength = baseLength
                cellFrame = CGRect(x: cellXOffsets[currentColumnNumber], y: cellYOffsets[currentColumnNumber], width: cellLength, height: cellLength)
                cellYOffsets[currentColumnNumber] = cellYOffsets[currentColumnNumber] + (cellLength * 2)
                print(cellFrame)
            case 10:
                cellLength = baseLength * 2
                cellFrame = CGRect(x: cellXOffsets[currentColumnNumber], y: cellYOffsets[currentColumnNumber], width: cellLength, height: cellLength)
                cellYOffsets[currentColumnNumber] = cellYOffsets[currentColumnNumber] + cellLength
                print(cellFrame)
            case 11:
                cellLength = baseLength
                cellFrame = CGRect(x: cellXOffsets[currentColumnNumber - 2], y: cellYOffsets[currentColumnNumber] + baseLength, width: cellLength, height: cellLength)
                cellYOffsets[currentColumnNumber] = cellYOffsets[currentColumnNumber] + (cellLength * 2)
                print(cellFrame)
            default:
                cellLength = baseLength
                cellFrame = CGRect(x: cellXOffsets[currentColumnNumber], y: cellYOffsets[currentColumnNumber], width: cellLength, height: cellLength)
                cellYOffsets[currentColumnNumber] = cellYOffsets[currentColumnNumber] + cellLength
                print(cellFrame)
            }
            let itemFrame = cellFrame.insetBy(dx: cellPadding, dy: cellPadding)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = itemFrame
            cachedAttributes.append(attributes)
            contentHeight = max(contentHeight, cellFrame.maxY)
            currentColumnNumber = currentColumnNumber < (numberOfColumns - 1) ? currentColumnNumber + 1 : 0
        }
    }

}
