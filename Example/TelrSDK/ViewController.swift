//
//  ViewController.swift
//  TelrSDK
//
//  Created by Telr Sdk on 10/02/2020.
//  Copyright (c) 2020 Telr Sdk. All rights reserved.
//

import UIKit
import TelrSDK
class ViewController: UIViewController {
    
    let KEY:String = "BwxtF~dq9L#xgWZb" // TODO fill key
    let STOREID:String = "21941"  // TODO fill store id
    let EMAIL:String = "girish.spryox@gmail.com" // TODO fill email id
    
    var paymentRequest:PaymentRequest?
    
    @IBOutlet var showCardBtn: UIButton!
    @IBOutlet var cardSv: UIStackView!
    @IBOutlet var amountTxt: UITextField!
    @IBOutlet var cardTxt: UILabel!
    
    @IBAction func showcardbtnPressed(_ sender: Any) {
        
        cardTxt.text = "**** **** **** " + getSavedData(key: "last4")
        
        if(cardSv.isHidden == true){
            
            cardSv.isHidden = false
            
            showCardBtn.setTitle("Hide",for: .normal)
        
        }else{
            
            cardSv.isHidden = true
            
            showCardBtn.setTitle("Show stored card",for: .normal)
        }
    }
    @IBAction func payBtnPressed(_ sender: Any) {
        
        //Mark:-If you what change the back button as custome back button on navigation
        let customBackButton = UIButton(type: .custom)
        customBackButton.setTitle("Back", for: .normal)
        customBackButton.setTitleColor(.black, for: .normal)
    
        paymentRequest = preparePaymentRequest()
        let telrController = TelrController()
        telrController.delegate = self
        telrController.customBackButton = customBackButton
        telrController.paymentRequest = paymentRequest!
        self.navigationController?.pushViewController(telrController, animated: true)
        

    }
    @IBAction func payBtn2Pressed(_ sender: Any) {
        
        paymentRequest = preparePaymentRequestSaveCard()
        let telrController = TelrController()
        telrController.delegate = self
        telrController.paymentRequest = paymentRequest!
        let nav = UINavigationController(rootViewController: telrController)
        self.navigationController?.present(nav, animated: true, completion: nil)
       
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
       
        let logoContainer = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
        imageView.contentMode = .scaleAspectFit
        let image = UIImage(named: "logo")
        imageView.image = image
        logoContainer.addSubview(imageView)
        self.navigationItem.titleView = logoContainer
        
        self.displaySavedCard()
    
    }

    private func displaySavedCard() {
        if(getSavedData(key: "last4").isEmpty){
             
             showCardBtn.isHidden = true
        
         }else{
            
             showCardBtn.isHidden = false
         }
    }
    private func getSavedData(key:String) -> String{
    
        let defaults = UserDefaults.standard
    
        return defaults.string(forKey: key) ?? ""

    }
    private func saveData(key:String, value:String){
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key)
    }




}

//Mark:- Payment Request Builder
extension ViewController:TelrControllerDelegate{
    
    
    //Mark:- This method call when user click on back button
    func didPaymentCancel() {
         print("didPaymentCancel")
    }
    
    //Mark:- This method call when payment done successfully
    func didPaymentSuccess(response: TelrResponseModel) {
        
        print("didPaymentSuccess")
           
        print("Trace \(String(describing: response.trace))")
        
        print("Status \(String(describing: response.status))")
        
        print("Avs \(String(describing: response.avs))")
        
        print("Code \(String(describing: response.code))")
        
        print("Ca_valid \(String(describing: response.ca_valid))")
        
        print("Card Code \(String(describing: response.cardCode))")
        
        print("Card Last4 \(String(describing: response.cardLast4))")
        
        print("CVV \(String(describing: response.cvv))")
        
        print("TranRef \(String(describing: response.tranRef))")
        
        
        //Mark:- Save card management it save only one card at time.
        //For save the card you need to store tranRef and when you are going to make second trans using thistranRef
        
        if let ref = response.tranRef{
            saveData(key: "ref", value: ref)
        }
        if let last4 = response.cardLast4{
            saveData(key: "last4", value: last4)
        }
        self.displaySavedCard()
      
    }
    
    //Mark:- This method call when user click on cancel button and if payment get failed
    func didPaymentFail(messge: String) {
         print("didPaymentFail \(messge)")
    }
    
    func didCancelPayment() {
        print("didCancelPayment")
    }
    
    
}


//Mark:- Payment Request Builder
extension ViewController{
    
     private func preparePaymentRequest() -> PaymentRequest{
     
     
         let paymentReq = PaymentRequest()
     
         paymentReq.key = KEY
    
         paymentReq.store = STOREID
     
         paymentReq.appId = "123456789"
    
         paymentReq.appName = "TelrSDK"
     
         paymentReq.appUser = "123456"
     
         paymentReq.appVersion = "0.0.1"
     
         paymentReq.transTest = "1"
    
         paymentReq.transType = "auth"
    
         paymentReq.transClass = "paypage"
     
         paymentReq.transCartid = String(arc4random())
     
         paymentReq.transDesc = "Test API"
     
         paymentReq.transCurrency = "AED"
     
         paymentReq.transAmount = amountTxt.text!
     
         paymentReq.billingEmail = EMAIL
     
         paymentReq.billingFName = "Hany"
     
         paymentReq.billingLName = "Sakr"
     
         paymentReq.billingTitle = "Mr"
     
         paymentReq.city = "Dubai"
     
         paymentReq.country = "AE"
     
         paymentReq.region = "Dubai"
     
         paymentReq.address = "line 1"
     
         paymentReq.language = "en"
     
         return paymentReq

     }


     private func preparePaymentRequestSaveCard() -> PaymentRequest{

     
         let paymentReq = PaymentRequest()
     
         paymentReq.key = KEY
     
         paymentReq.store = STOREID
     
         paymentReq.appId = "123456789"
     
         paymentReq.appName = "TelrSDK"
     
         paymentReq.appUser = "123456"
     
         paymentReq.appVersion = "0.0.1"
     
         paymentReq.transTest = "1"
     
         paymentReq.transType = "paypage"
     
         paymentReq.transClass = "ecom"
     
         paymentReq.transCartid = String(arc4random())
     
         paymentReq.transDesc = "Test API"
     
         paymentReq.transCurrency = "AED"
     
         paymentReq.billingFName = "Hany"
     
         paymentReq.billingLName = "Sakr"
     
         paymentReq.billingTitle = "Mr"
     
         paymentReq.city = "Dubai"
     
         paymentReq.country = "AE"
     
         paymentReq.region = "Dubai"
     
         paymentReq.address = "line 1"
     
         paymentReq.transAmount = amountTxt.text!
     
         paymentReq.transFirstRef = self.getSavedData(key: "ref")
     
         paymentReq.transRef = self.getSavedData(key: "ref")
     
         paymentReq.billingEmail = EMAIL
     
         paymentReq.language = "ar"
     
         return paymentReq

     }
}



