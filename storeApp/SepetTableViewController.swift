//
//  SepetTableViewController.swift
//  storeApp
//
//  Created by wissen on 15/01/17.
//  Copyright © 2017 Hakan. All rights reserved.
//

import UIKit
import SwiftyJSON
import Auk
import AlamofireImage
import Alamofire
import SCLAlertView
import SQLiteManager

class SepetTableViewController: UITableViewController {
    
    var data : SQLiteDataArray?
    let db =  try! SQLitePool.manager().initialize(database: "storeAppDB", withExtension: "db")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("URL : \(db.databaseUrl)")
        dataGetir()
    }
    
    func dataGetir(){
        data = try! db.query("select * from sepet").results
        self.tableView.reloadData()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return (data == nil ? 0 : (data?.count)!)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let data = self.data?[indexPath.row]
        cell.textLabel?.text = data?["productName"] as? String
        cell.detailTextLabel?.text = data?["unitPrice"] as? String

        return cell
    }
    
    
    @IBAction func fncGeri(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            
            let dataa = self.data?[indexPath.row]
            let id = dataa?["sepetId"] as? Int
            let sil  = try! db.query("delete from sepet where sepetId = \(id!)")
            if sil.affectedRowCount > 0 {
                // silme işlemi başarılı
                data?.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    @IBAction func fncSiparisTamala(_ sender: UIButton) {
        
        
        // kontrol - sepette ürün var mı ?
        if (self.data?.count)! > 0 {
            var userID:String = ""
            var ids:String = ""
            for item in self.data! {
                ids += ",\(item["productId"] as! Int)"
                userID = "\(item["userId"] as! Int)"
            }
            let gdic:[String:String] = ["ref":"b7e55c8ed007bc921ac646df023a4dcd","customerId":userID, "productId":"1","html":ids]            
            Alamofire.request("http://jsonbulut.com/json/orderForm.php", method: .get, parameters: gdic, encoding: URLEncoding.default, headers: nil).responseJSON { response in
                if let jdata = response.result.value {
                    let jsonData = JSON(jdata)
                    let durum = jsonData["order"][0]["durum"].bool
                    if durum == true {
                        // gönderim başarılı
                        // veritabanını temizle
                        let silDurum = try! self.db.query("delete from sepet where userId = \(userID)")
                        if silDurum.affectedRowCount > 0 {
                            self.data?.removeAll()
                            self.tableView.reloadData()
                            SCLAlertView().showSuccess("Başarılı", subTitle: "Siparişiniz Tamamlandı !", closeButtonTitle: "Tamam")
                        }
                    }
                }else {
                    SCLAlertView().showError("Bağlantı Hatası", subTitle: "Sunucu ile bağlantı sağlanamadı !")
                }
            }
            
            
        }else {
            SCLAlertView().showError("Gönderme Hatası", subTitle: "Sepetiniz Boş !")
        }
        
        
        
        
    }


}
