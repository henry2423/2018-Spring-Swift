//
//  DocumentInfoViewController.swift
//  16-EmojiArt
//
//  Created by Henry on 04/04/2018.
//  Copyright © 2018 Henry Huang. All rights reserved.
//

import UIKit

class DocumentInfoViewController: UIViewController {
    
    var document: EmojiArtDocument? {
        didSet { updateUI() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    private let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    private func updateUI() {
        
        if sizeLabel != nil, createdLabel != nil,
            let url = document?.fileURL,
            let attributes = try? FileManager.default.attributesOfItem(atPath: url.path) {
                sizeLabel.text = "\(attributes[.size] ?? 0) bytes"
                if let created = attributes[.creationDate] as? Date {
                    createdLabel.text = shortDateFormatter.string(from: created)
            }
        }
        
        if thumbnailImageView != nil, thumbnailAspectRatio != nil, let thumbnail = document?.thumbnail {
            thumbnailImageView.image = thumbnail
            //remove old constant constraint, then give a new proper one with code below
            thumbnailImageView.removeConstraint(thumbnailAspectRatio)
            thumbnailAspectRatio = NSLayoutConstraint(
                item: thumbnailImageView,
                attribute: .width,
                relatedBy: .equal,
                toItem: thumbnailImageView,
                attribute: .height,
                multiplier: thumbnail.size.width / thumbnail.size.height,
                constant: 0
            )
            thumbnailImageView.addConstraint(thumbnailAspectRatio)
            
        }

    }

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    
    @IBAction func done() {
        //dismiss(self) can use also but it's more orthordox to call presentingViewController to dismiss myself
        
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var thumbnailAspectRatio: NSLayoutConstraint!
}
