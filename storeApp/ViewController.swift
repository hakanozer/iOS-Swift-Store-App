//
//  ViewController.swift
//  storeApp
//
//  Created by Hakan on 25/12/2016.
//  Copyright © 2016 Hakan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    var dizi:[UIImage] = []
    
    @IBOutlet weak var resim: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.removeObject(forKey: "userID")
        
        for item in 1...45 {
            dizi.append(UIImage(named:"\(item)")!)
        }
        self.resim.animationImages = dizi
        self.resim.animationDuration = TimeInterval(1)
        self.resim.startAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { (Timer) in
            self.performSegue(withIdentifier: "anasayfa", sender: nil)
            
            
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

