//
//  ImagePageViewController.swift
//  VaCay
//
//  Created by Andre on 7/25/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit
import Kingfisher
import Auk
import DynamicBlurView
import GSImageViewerController

class ImagePageViewController: BaseViewController {
    
    @IBOutlet weak var image_scrollview: UIScrollView!
    @IBOutlet weak var view_pictures: UIView!
    var blurView:DynamicBlurView!
    var count:Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        image_scrollview.auk.settings.contentMode = .scaleAspectFit
        self.blurView = DynamicBlurView(frame: self.view_pictures.bounds)
        
//        self.sliderImagesArray.addObjects(from: gPostPictures)
            
        for pic in gPostPictures {
            self.image_scrollview.auk.show(url: pic.image_url)
        }
            
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tappedScrollView(_:)))
        self.image_scrollview.addGestureRecognizer(tap)
        
    }
        
    @objc func tappedScrollView(_ sender: UITapGestureRecognizer? = nil) {
        let index = self.image_scrollview.auk.currentPageIndex
    //        print("tapped on Image: \(index)")
        let images = self.image_scrollview.auk.images
        let image = images[index!]
            
        let imageInfo   = GSImageInfo(image: image , imageMode: .aspectFit)
        let transitionInfo = GSTransitionInfo(fromView:self.image_scrollview)
        let imageViewer = GSImageViewerController(imageInfo: imageInfo, transitionInfo: transitionInfo)
            
        imageViewer.dismissCompletion = {
                print("dismissCompletion")
        }
            
        present(imageViewer, animated: true, completion: nil)
    }

    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
