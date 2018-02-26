//
//  ViewController.swift
//  Nagic 8 Ball
//
//  Created by Henry on 26/02/2018.
//  Copyright © 2018 Henry Huang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var ballImage: UIImageView!
    var randomImageIndex: Int = 0
    let ballImageArray = [#imageLiteral(resourceName: "ball1"), #imageLiteral(resourceName: "ball2"), #imageLiteral(resourceName: "ball3"), #imageLiteral(resourceName: "ball4"), #imageLiteral(resourceName: "ball5")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        updateBallImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func askButton(_ sender: UIButton) {
        updateBallImage()
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        updateBallImage()
    }
    
    func updateBallImage(){
        randomImageIndex = Int(arc4random_uniform(5))
        
        ballImage.image = ballImageArray[randomImageIndex]
    }
}

