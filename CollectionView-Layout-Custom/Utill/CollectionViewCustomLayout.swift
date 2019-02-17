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

    // 列の数
    private var numberOfColumns = 3
    // セル周囲のスペース
    private var cellPadding: CGFloat = 1
    private var contentHeight: CGFloat = 0
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    // レイアウト準備のため計算を行う
    override func prepare() {
        guard cachedAttributes.isEmpty, let collectionView = collectionView else {
            return
        }

        // 横に何個入れるか？
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        // 要素ごとのx軸を格納
        var xOffset = [CGFloat]()
        for column in 0 ..< numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        var column = 0
        var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)

        // 一つずつ要素を取り出してサイズを決めていく
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            // 要素のindex
            let indexPath = IndexPath(item: item, section: 0)
            // VC側から要素の高さを取得（collectionViewは持っていないから）
            let photoHeight = delegate?.collectionView(collectionView, heightForPhotoAtIndexPath: indexPath)
            // セルのスペースを含めて高さを決定
            let height = cellPadding * 2 + photoHeight!
            // セルごとのframeを作る
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
            // insetbyは元々のスペースはない程で調整するから、あらかじめスペース分の長さを含めたlengthを渡す
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            // indexで要素を取り出す
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            // indexで取り出したセル(要素)に用意したframeを指定する
            attributes.frame = insetFrame
            // 要素一覧に加える
            cachedAttributes.append(attributes)
            // セルのスペースを含めた一番底のy座標を取得
            contentHeight = max(contentHeight, frame.maxY)
            // y座標管理用の配列に、追加したセル分の座標を追加する（並ぶように）
            yOffset[column] = yOffset[column] + height
            // numberOfItemsの最大値に達してない場合は、1追加して、次の要素のframe生成を進める
            column = column < (numberOfColumns - 1) ? (column + 1) : 0
        }
    }

    // スクロール領域を決定
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

    // パーツのindexごとに必要なレイアウト属性を返す（cellもheaderも混ざった状態）
    // いらないかも
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cachedAttributes[indexPath.item]
    }

}
