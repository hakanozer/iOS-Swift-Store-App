//
//  signUp.swift
//  storeAppLogin
//
//  Created by CesurMecnun on 14/01/2017.
//  Copyright © 2017 CesurMecnun. All rights reserved.
//

import UIKit
import Alamofire
import SCLAlertView
import SwiftyJSON
import SVProgressHUD

class signUp: UIViewController {
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtSurname: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!

    @IBAction func fncSignUp(_ sender: UIButton) {
        if (txtName.text == "" || txtSurname.text == "" ||
            txtPhone.text == "" || txtEmail.text == "" || txtPassword.text == "" )
        {
            SCLAlertView().showWarning("Register Warning", subTitle: "All fields are required")
            return
        }
        SVProgressHUD.show(withStatus: "Loading...");
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black);
        
        
        let url = "http://jsonbulut.com/json/userRegister.php"
        let dic = ["ref":"b7e55c8ed007bc921ac646df023a4dcd","userName":txtName.text!, "userSurname":txtSurname.text!, "userPhone":txtPhone.text!, "userMail":txtEmail.text!, "userPass":txtPassword.text!]
        
        Alamofire.request(url, method: .get, parameters: dic, encoding: URLEncoding.default, headers: nil).responseJSON { response in
            
            if let data = response.result.value {
                let json = JSON(data)
                // Denetim
                let durum = json["user"][0]["durum"].boolValue
                let mesaj = json["user"][0]["mesaj"].string
                if durum == true { //kayıt başarılı
                    let id = json["user"][0]["kullaniciId"].string
                    UserDefaults.standard.set(id!, forKey: "userID")
                   SCLAlertView().showSuccess("İşlem Sonucu", subTitle: mesaj!, closeButtonTitle: "Tamam")
                    self.dismiss(animated: true, completion: nil)

                }
                else { // kayıt başarısız
                    SCLAlertView().showError("İşlem Sonucu", subTitle: mesaj!, closeButtonTitle: "Tamam")
                }
               SVProgressHUD.dismiss();
                
            }
            else { 
                
                SCLAlertView().showError("Hata", subTitle: "İşlem Sırasında Hata Oluştu", closeButtonTitle: "Tamam")
            }
            
            
        }
    }
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}
