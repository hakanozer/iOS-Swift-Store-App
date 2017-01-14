//
//  productListTVC.swift
//  storeApp
//
//  Created by MUSTAFA TAHA KIR on 25/12/2016.
//  Copyright © 2016 Hakan. All rights reserved.
//

import UIKit
import SCLAlertView
import SwiftyJSON
import AlamofireImage
import Alamofire
class productListTVC: UITableViewController {

    
    
    let yeni = UIRefreshControl()
    static var calisDurum = 0
    var appearance = SCLAlertView.SCLAppearance()
    var loading = SCLAlertView()
    
    var json:JSON = []
    override func viewDidLoad() {
        super.viewDidLoad()
        appearance = SCLAlertView.SCLAppearance(
        
            showCloseButton: false
            )
        
        yeni.attributedTitle = NSAttributedString(string: "Yenile")
        yeni.addTarget(self, action: #selector(productListTVC.yenile), for: UIControlEvents.valueChanged)
        yeni.beginRefreshing()
        self.tableView.addSubview(yeni)
        
       dataGetir(catID: "37")
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if productListTVC.calisDurum == 0 {
        loading = SCLAlertView(appearance: appearance)
        loading.showWait("Lütfen Bekleyin" ,subTitle: "Ürünler yükleniyor...")
        }
        
    }

    func yenile() {
        dataGetir(catID: "37")
    }
    
    
    func dataGetir(catID:String){
        if productListTVC.calisDurum == 1 {
            loading = SCLAlertView(appearance: appearance)
            loading.showWait("Lütfen Bekleyin" ,subTitle: "Ürünler yükleniyor...")
        }
        //loading = SCLAlertView(appearance: appearance)
        
        //loading.showWait("Lütfen Bekleyin" ,subTitle: "Ürünler yükleniyor...")

        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let url = "http://jsonbulut.com/json/product.php?ref=b7e55c8ed007bc921ac646df023a4dcd&start=1&count=100&categoryId="+catID
        Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON{ response in
            if let data = response.result.value {
                self.json = JSON(data)
                self.json = self.json["Products"][0]["bilgiler"]
                self.tableView.reloadData()
            }
        }
        self.yeni.endRefreshing() // yenileme animasyonunu durdur
       
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        loading.hideView()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return json.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath)


        cell.textLabel?.text = self.json[indexPath.row]["productName"].string
        cell.detailTextLabel?.text = self.json[indexPath.row]["price"].string! + " TL"
        
        // Resim dosyasının varlığının kontrolü ve varsa cell içine çekme
        let isImageAvailable = self.json[indexPath.row]["image"].bool
        if isImageAvailable == true {
            let thumbURL = self.json[indexPath.row]["images"][0]["thumb"].string
            Alamofire.request(thumbURL!).responseImage { response in
                if let _img = response.result.value {
                    cell.imageView?.image = _img
                    cell.imageView?.frame.size = CGSize(width: _img.size.width, height: _img.size.height)
                    cell.imageView?.contentMode = .scaleAspectFit
                    
                }
            }
        }
        
        loading.hideView()
        
        return cell
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let send = self.json[indexPath.row]
        self.performSegue(withIdentifier: "productDetail", sender: send)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "productDetail" {
            if let vc = segue.destination as? productDetailVC {
                vc.data = sender as! JSON
            }
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
