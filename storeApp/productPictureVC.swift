//
//  productPictureVC.swift
//  storeApp
//
//  Created by Emir Kartal on 28.12.2016.
//  Copyright © 2016 Hakan. All rights reserved.
//

import UIKit
import Alamofire

class productPictureVC: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollV: UIScrollView!
    
    @IBOutlet weak var pictureView: UIImageView!
    
    var takePicture = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Alamofire.request(takePicture).responseImage { response in
            if let img = response.result.value {
                self.pictureView.image = img
            }
        }
        
        self.scrollV.minimumZoomScale = 1.0
        self.scrollV.maximumZoomScale = 6.0
        
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return pictureView
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
