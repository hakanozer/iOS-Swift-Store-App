//
//  productDetailVC.swift
//  storeApp
//
//  Created by MUSTAFA TAHA KIR on 25/12/2016.
//  Copyright © 2016 Hakan. All rights reserved.
//

import UIKit
import SwiftyJSON
import Auk
import AlamofireImage
import Alamofire
import SCLAlertView
import SQLiteManager

class productDetailVC: UIViewController,UIScrollViewDelegate,UIPickerViewDelegate, UIPickerViewDataSource,UITextFieldDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var lblBaslik: UILabel!
    @IBOutlet weak var detayWebView: UIWebView!
  
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var UnitPV: UIPickerView!
    @IBOutlet weak var txtUnit: UITextField!
    @IBOutlet weak var txtUnitPrice: UILabel!
    @IBOutlet weak var txtTotalPrice: UILabel!
    
    @IBOutlet weak var lblBirimFiyati: UILabel!
    @IBOutlet weak var lblToplamTutar: UILabel!
    
    var appearance = SCLAlertView.SCLAppearance()
    var loading = SCLAlertView()

    let db =  try! SQLitePool.manager().initialize(database: "storeAppDB", withExtension: "db")

    
    

    var data:JSON = []
    var unitList:[String] = []
    var userId:Int = 0
    
    
    override func viewDidLoad() {
         super.viewDidLoad()
            userId = 123
        
        appearance = SCLAlertView.SCLAppearance(
            
            showCloseButton: false
        )

        productListTVC.calisDurum = 1
   
        for item in 1...10 { // stok bilgisi olmadığı için 1 den 10'a kadar oluşturdum.
            
            self.unitList.append("\(item)")
        }
        
        scrollView.delegate = self
        scrollView.auk.startAutoScroll(delaySeconds: 3)
        scrollView.auk.settings.preloadRemoteImagesAround = 1
        
        
        
        txtUnit.delegate = self
        //UnitPV.alpha = 0

        getProductDetails()
        
    
    }
    
    func tapAct () {
        
        let sendImage = contentImages[scrollView.auk.currentPageIndex!] //tiklanan resmin yolunu degiskene aktardim
        performSegue(withIdentifier: "productPicture", sender: sendImage)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "productPicture" {
            
            if let vc = segue.destination as? productPictureVC {
                vc.popoverPresentationController?.delegate = self
                vc.preferredContentSize = CGSize(width: self.view.frame.width * 0.8 , height: 400)
                vc.popoverPresentationController?.sourceView = scrollView
                vc.popoverPresentationController?.sourceRect = scrollView.bounds
                vc.takePicture = sender as! String
                
            }
        }
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    private var contentImages : [String] = []
    
    func getProductDetails() { // Ürün bilgilerini bu fonksiyon getiriyor
 
        let isImageAvailable = data["image"].bool
        
        if isImageAvailable == true {
            for item in data["images"].arrayValue{
                
                self.contentImages.append(item["normal"].string!)
                scrollView.auk.show(url: item["normal"].string!)
            }
            let tapGest = UITapGestureRecognizer(target: self, action: #selector(tapAct))//resme tiklandiginda event atiyorum
            scrollView.addGestureRecognizer(tapGest) // event'i sadece scrollview icin kullaniyorum
            
        }
  
        self.pickerView(self.UnitPV, didSelectRow: 0, inComponent: 0) // UIPickerView ilk değeri seçilmiş gibi hareket ediyorum.
        let firstRow = UnitPV.selectedRow(inComponent: 0)
        
        txtUnit.text = unitList[firstRow]


        lblBaslik.text = data["productName"].string
        
        
        let x: Double = Double(data["price"].string!)!  // ürün tutarını hesaplamalar için Double olarak alıyorum
        
        /* UILabel e Birim fiyatını yazdırırken 232323 gibi bir değer gelmesin diye para birimini formatlıyorum böylelikle 2.323,23 şeklinde çıkacak */
        let number = NSDecimalNumber(decimal: Decimal(x))
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale(identifier: "tr_TR")
        
        let result = numberFormatter.string(from: number)
        
        txtUnitPrice.text = result?.replacingOccurrences(of: "₺", with: "")
        /* para birimi ile ilgili formatlama işlemi bitti ve ilgili alana yazıldı. */
        
        detayWebView.loadHTMLString(data["description"].string!, baseURL: nil)
        
        txtTotalPrice.text = CalculatePrice(_unitprice: data["price"].string!, _unit: unitList[firstRow])
      
        
    }    
    
    func CalculatePrice(_unitprice: String , _unit: String) -> String { // Birim fiyatı * Miktar ile toplam tutarı bu fonksiyon ile döndüyüroum.
        
        let unitPrice: Double = Double(_unitprice)!
        let unit: Double = Double(_unit)!
        
        
        
        let totalPrice = unitPrice * unit
        
        let _totalPrice: Decimal = Decimal(totalPrice)
        
        let number = NSDecimalNumber(decimal: _totalPrice)
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale(identifier: "tr_TR")
        
        let result = numberFormatter.string(from: number)

        return (result?.replacingOccurrences(of: "₺", with: ""))!
        
    }
    
    @IBAction func fncOpenUnitList(_ sender: UITextField) { // textbox a tıklandığında PickerView in açılmasını ve altındaki alanların gizlenmesini sağlıyorum.
        
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.5, animations: {
            self.UnitPV.alpha = 1
            self.lblBirimFiyati.alpha = 0
            self.lblToplamTutar.alpha = 0
            self.txtUnitPrice.alpha = 0
            self.txtTotalPrice.alpha = 0
        })
        
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool { // UITexField e kullanıcı tarafından veri girilmesini devre dışı bırakıyorum.
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { // boş bir alana tıklandığında PickerView i gizleyip altında kalan alanları tekrardan görünün yapıyorum.
        
        self.view.endEditing(true)
        UIView.animate(withDuration: 0.5, animations: {
            self.UnitPV.alpha = 0
            self.lblBirimFiyati.alpha = 1
            self.lblToplamTutar.alpha = 1
            self.txtUnitPrice.alpha = 1
            self.txtTotalPrice.alpha = 1
        })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnbackToProductList(_ sender: UIBarButtonItem) { //Ürün listesine geri dön
        dismiss(animated: true, completion: nil) // Programi yormasin diye ekledim
        //performSegue(withIdentifier: "backToProductList", sender: nil)
        //navigationController?.dismiss(animated: true, completion: nil)
       // let g = navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func btnAddToBasket(_ sender: UIBarButtonItem) {
        
        fncInsert(productId: Int(self.data["productId"].string!)!, productName: data["productName"].string!, unitPrice: txtUnitPrice.text!, unit: Int(txtUnit.text!)!, totalPrice: txtTotalPrice.text!)
    }
    
    

    func fncInsert(productId:Int, productName:String, unitPrice:String, unit:Int, totalPrice:String) // sqlLite'a buradan veri basıyorum.
    {
        loading = SCLAlertView(appearance: appearance)
        

        let sonuc = try! db.query("insert into sepet values(null,\(userId),\(productId),'\(productName)','\(unitPrice)',\(unit),'\(totalPrice)')")
        // yazma denetimi
        if sonuc.affectedRowCount > 0 {
            loading.showSuccess("Bilgilendirme" ,subTitle: "Ürün sepete eklendi.", duration:1.0)
        }else {
            loading.showError("HATA", subTitle: "Ürün sepete eklenirken bir hata oluştu", duration:2.0)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { //UIPickerView satır sayısı
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { // Stok bilgisi kadar row oluşturuyorum.
        
        return unitList.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? { //row başlığına yazılacak text verisini basıyorum.
        
        return unitList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) { // UIPickerView den seçilen veriyi alıp hesaplamaları yapıyorum.
        
        self.view.endEditing(true)
        txtUnit.text = unitList[row]
        
      //  print(txtUnit.text)
        
        txtTotalPrice.text = CalculatePrice(_unitprice: data["price"].string!, _unit: unitList[row])
        
        UIView.animate(withDuration: 0.5, animations: {
            self.UnitPV.alpha = 0
            self.lblBirimFiyati.alpha = 1
            self.lblToplamTutar.alpha = 1
            self.txtUnitPrice.alpha = 1
            self.txtTotalPrice.alpha = 1
        })
        
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
