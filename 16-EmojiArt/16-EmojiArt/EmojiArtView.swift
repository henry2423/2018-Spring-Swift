//
//  EmojiArtView.swift
//  16-EmojiArt
//
//  Created by Henry on 16/03/2018.
//  Copyright © 2018 Henry Huang. All rights reserved.
//

import UIKit

class EmojiArtView: UIView {
    
    
    var backgroundImage: UIImage? { didSet { setNeedsDisplay() }}

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        backgroundImage?.draw(in: bounds)
    }
    

}
