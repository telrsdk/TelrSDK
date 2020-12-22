//
//  TabbySelectionVC.swift
//  TelrSDK
//
//  Created by Admin on 22/12/20.
//


import UIKit

public class TabbySelectionVC: UIViewController  {

    public var delegate : TabbyControllerDelegate?
    public var customBackButton : UIButton?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.presentationController?.presentedView?.gestureRecognizers?[0].isEnabled = false
        self.addBackButton()
        self.addButtonsOfPaymentsView()
        self.createCheckoutSession()
        
    }
    var installmentsButton = UIButton()
    var paylaterButton = UIButton()
    private func addButtonsOfPaymentsView(){
        let viewBack = UIView()
        
        viewBack.backgroundColor = .white
        
        viewBack.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        
        let paylaterButton = UIButton()
        self.paylaterButton = paylaterButton
        paylaterButton.frame = CGRect(x: 16, y:(self.view.frame.height/2)+150 , width: self.view.frame.width-32, height: 50)
        paylaterButton.setTitle("PAY LATER WITH TABBY", for: .normal)
        paylaterButton.titleLabel?.textAlignment = .center
        paylaterButton.addTarget(self, action: #selector(paylaterButtonAction), for: .touchUpInside)
        paylaterButton.backgroundColor = UIColor(red:0.24, green:0.93, blue:0.75, alpha:1.0)
        paylaterButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        paylaterButton.isEnabled = false
        paylaterButton.setTitleColor(.gray, for: .disabled)
        paylaterButton.setTitleColor(.black, for: .normal)
        
        viewBack.addSubview(paylaterButton)
        
        let installmentsButton = UIButton()
        self.installmentsButton = installmentsButton
        installmentsButton.frame = CGRect(x: 16, y:(self.view.frame.height/2)+220 , width: self.view.frame.width-32, height: 50)
        installmentsButton.setTitle("PAY IN ISTALLMENTS", for: .normal)
        installmentsButton.titleLabel?.textAlignment = .center
        installmentsButton.addTarget(self, action: #selector(installmentsButtonAction), for: .touchUpInside)
        installmentsButton.backgroundColor = UIColor(red:0.24, green:0.93, blue:0.75, alpha:1.0)
        installmentsButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        installmentsButton.setTitleColor(.gray, for: .disabled)
        installmentsButton.setTitleColor(.black, for: .normal)
        installmentsButton.isEnabled = false
        viewBack.addSubview(installmentsButton)
        self.view.addSubview(viewBack)
    }
    var session: [String: Any]?
    var selectedProduct: String?
    
    
    
    @objc func paylaterButtonAction() {
        selectedProduct = "pay_later"
        let tabbyController = TabbyController()
        tabbyController.productType = self.selectedProduct
        tabbyController.session = self.session
        self.navigationController?.pushViewController(tabbyController, animated: true)
    }
    
    @objc func installmentsButtonAction() {
        selectedProduct = "installments"

        let tabbyController = TabbyController()
        tabbyController.productType = self.selectedProduct
        tabbyController.session = self.session
        self.navigationController?.pushViewController(tabbyController, animated: true)
//        let nav = UINavigationController(rootViewController: tabbyController)
//        self.navigationController?.present(nav, animated: true, completion: nil)
    }
    func createCheckoutSession() {
        let body = """
        {
          "payment": {
              "amount": 1000,
              "buyer": {
                "dob": "1987-10-20",
                "email": "successful.payment@tabby.ai",
                "name": "John Doe",
                "phone": "+971500000001"
              },
              "buyer_history": {
                "loyalty_level": 10,
                "registered_since": "2019-10-05T17:45:17+00:00",
                "wishlist_count": 421
              },
              "currency": "AED",
              "description": "Tabby Store Order #3",
              "order": {
                "items": [
                  {
                    "description": "To be displayed in Tabby order information",
                    "product_url": "https://tabby.store/p/SKU123",
                    "quantity": 1,
                    "reference_id": "SKU123",
                    "title": "Sample Item #1",
                    "unit_price": "300"
                  },
                  {
                    "description": "To be displayed in Tabby order information",
                    "product_url": "https://tabby.store/p/SKU124",
                    "quantity": 1,
                    "reference_id": "SKU124",
                    "title": "Sample Item #2",
                    "unit_price": "600"
                  }
                ],
                "reference_id": "xxxx-xxxxxx-xxxx",
                "shipping_amount": "50",
                "tax_amount": "50"
              },
              "order_history": [
                {
                  "amount": "1000",
                  "buyer": {
                    "name": "John Doe",
                    "phone": "+971-505-5566-33"
                  },
                  "items": [
                    {
                      "quantity": 4,
                      "title": "Sample Item #3",
                      "unit_price": "250",
                      "reference_id": "item-sku",
                      "ordered": 4,
                      "captured": 4,
                      "shipped": 4,
                      "refunded": 1
                    }
                  ],
                  "payment_method": "CoD",
                  "purchased_at": "2019-10-05T18:45:17+00:00",
                  "shipping_address": {
                    "address": "Sample Address #1",
                    "city": "Dubai"
                  },
                  "status": "complete"
                }
              ],
              "shipping_address": {
                "address": "Sample Address #2",
                "city": "Dubai"
              }
          }
        }
        """
        var request = URLRequest(url: URL(string: "https://api.tabby.ai/api/v2/checkout")!)
        request.httpMethod = "post"
        let key = "pk_test_d878b6de-9f6f-4c2c-bc8c-fde1b249b9c4"
        request.allHTTPHeaderFields = [
            "Authorization": "Bearer \(key)"]
        request.httpBody = Data(body.utf8)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in

               guard error == nil else {
                   return
               }

               guard let data = data else {
                   return
               }

              do {
                 if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    //print(json)
                    self.session = json
                    if let configuration = json["configuration"] as? NSDictionary {
                        print(configuration)
                        
                        if let available_products = configuration["available_products"] as? NSDictionary {
                            DispatchQueue.main.async {
                                for (key, _) in available_products {
                                        let type = key as! String
                                        switch type {
                                        case "installments":
                                            self.installmentsButton.isEnabled = true
                                        case "pay_later":
                                            self.paylaterButton.isEnabled = true
                                        default:
                                            continue
                                        }
                                }
                                
                            }
                            
                        }
                    }
         
                 }
              } catch let error {
                print(error.localizedDescription)
              }
           })

           task.resume()
        
    }
    func addBackButton() {
        
        if let customBackButton = self.customBackButton {
            
            customBackButton.addTarget(self, action: #selector(self.backAction(_:)), for: .touchUpInside)
            
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customBackButton)
        
        }else{
            
            let backButton = UIButton(type: .custom)
            
            backButton.setTitle("Back", for: .normal)
            
            backButton.setTitleColor(backButton.tintColor, for: .normal)
            
            backButton.addTarget(self, action: #selector(self.backAction(_:)), for: .touchUpInside)
            
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        }
       
    }
    @objc func backAction(_ sender: UIButton) {
       
        self.delegate?.didPaymentCancel()
    
        self.dismiss(animated: true, completion: nil)
    
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
 }
   


