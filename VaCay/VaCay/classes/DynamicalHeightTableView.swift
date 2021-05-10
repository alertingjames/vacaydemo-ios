//
//  DynamicalHeightTableView.swift
//  VaCay
//
//  Created by Andre on 7/27/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import Foundation

public class DynamicSizeTableView: UITableView
{
    override public func layoutSubviews() {
        super.layoutSubviews()
        if bounds.size != intrinsicContentSize {
            invalidateIntrinsicContentSize()
        }
    }

    override public var intrinsicContentSize: CGSize {
        return contentSize
    }
}
