//
//  TelrController.swift
//  TelrSDK
//
//  Created by Telr Sdk on 10/02/2020.
//  Copyright (c) 2020 Telr Sdk. All rights reserved.
//

import UIKit

import WebKit

public protocol TelrControllerDelegate {
    
    func didPaymentCancel()
    
    func didPaymentSuccess(response:TelrResponseModel)
    
    func didPaymentFail(messge:String)
}

public class TelrController: UIViewController, XMLParserDelegate {

    @objc var webView : WKWebView = WKWebView()
    
    var actInd: UIActivityIndicatorView?
    
    public var delegate : TelrControllerDelegate?
    
    private var _paymentRequest:PaymentRequest?
    
    private var _code:String?
    
    private var _status:String?
    
    private var _avs:String?
    
    private var _ca_valid:String?
    
    private var _cardCode:String?
    
    private var _cardLast4:String?
    
    private var _cvv:String?
    
    private var _transRef:String?
    
    private var _transFirstRef:String?
    
    private var _trace:String?
    
    private var _cardFirst6:String?

    public var paymentRequest:PaymentRequest{
        get{
            return _paymentRequest!
           }
        set{
            _paymentRequest = newValue
            _paymentRequest?.deviceType = "iPhone"
            _paymentRequest?.deviceId = UIDevice.current.identifierForVendor!.uuidString
        }
    }
    
    public var customBackButton : UIButton?
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        self.addBackButton()
        
        DispatchQueue.main.async {
            
            self.navigationController?.presentationController?.presentedView?.gestureRecognizers?[0].isEnabled = false
            
            self.createWebView()
                   
        }

        self.loadPaymentPage()
        
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
    @objc func createWebView() {

            
        let configuration = WKWebViewConfiguration()
            
        let viewBack = UIView()
        
        viewBack.backgroundColor = .white
        
        viewBack.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        
        webView = WKWebView(frame: CGRect.zero, configuration: configuration)
            
        webView.frame = CGRect(x: 0, y: 0, width: viewBack.bounds.width, height: viewBack.bounds.height)
            
        webView.navigationDelegate = self
        
        webView.uiDelegate = self
        
        webView.navigationDelegate = self
        
        webView.backgroundColor = .white
        
        webView.scrollView.delegate = self
        
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        webView.scrollView.alwaysBounceHorizontal = false
        
        if #available(iOS 11.0, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        } else {
            // Fallback on earlier versions
        }
        
        webView.scrollView.alwaysBounceVertical = false
        
        webView.scrollView.isDirectionalLockEnabled = true
        
        webView.backgroundColor = UIColor.white
        
        webView.isMultipleTouchEnabled = false
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        viewBack.addSubview(webView)
        
        self.view.addSubview(viewBack)
        
        self.showActivityIndicatory(uiView: self.webView)
            
    }
    
    func showActivityIndicatory(uiView: UIView) {
        
        actInd = UIActivityIndicatorView()
        
        actInd?.frame = CGRect(x: 0.0, y: -20, width: 40.0, height: 40.0);
        
        actInd?.center = uiView.center
        
        actInd?.hidesWhenStopped = true
        
        if #available(iOS 13.0, *) {
            actInd?.style = UIActivityIndicatorView.Style.medium
        } else {
            // Fallback on earlier versions
            actInd?.style = UIActivityIndicatorView.Style.gray
        }
        
        actInd?.color = .black
        
        uiView.addSubview(actInd!)
        
        actInd?.startAnimating()
    }
    
   
    
    @objc func loadPaymentPage(){
    
            let xml:String = self.initiatePaymentGateway(paymentRequest:self.paymentRequest)
            print(xml)
            let data = xml.data(using: .utf8)
            let url = URL(string:"https://secure.telr.com/gateway/mobile.xml")
               
            if let newurl = url{
                   
                var request = URLRequest(url: newurl)
                
                request.httpMethod = "post"
                
                request.httpBody = data
                   
                URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
                    
                    
                    if let data = data{

                        let str = String(data: data, encoding: .utf8)!
                        print(str)
                        let parser = XMLParser(data: data)
                        parser.delegate = self
                        parser.parse()

                        let xmlresponse = XML.parse(data)

                        
                        if let message = xmlresponse["mobile","auth","message"].text{
                            
                           
                            let when = DispatchTime.now() + 0  // No waiting time
                            DispatchQueue.main.asyncAfter(deadline: when) {
                                
                            if(message == "Authorised"){
                                
                                self._code = xmlresponse["mobile","auth","code"].text

                                self._status = xmlresponse["mobile","auth","status"].text

                                self._avs = xmlresponse["mobile","auth","avs"].text

                                self._ca_valid = xmlresponse["mobile","auth","ca_valid"].text

                                self._cardCode = xmlresponse["mobile","auth","cardcode"].text

                                self._cardLast4 = xmlresponse["mobile","auth","cardlast4"].text

                                self._cvv = xmlresponse["mobile","auth","cvv"].text!

                                self._transRef = xmlresponse["mobile","auth","tranref"].text

                                self._transFirstRef = xmlresponse["mobile","auth","tranfirstref"].text

                                self._trace = xmlresponse["mobile","trace"].text

                                let telrResponseModel = TelrResponseModel()
                                
                                telrResponseModel.message = "Your transaction is successful \(String(describing: self._trace))"
                                telrResponseModel.code = self._code
                                             
                                telrResponseModel.status = self._status
                                              
                                telrResponseModel.ca_valid = self._ca_valid
                                             
                                telrResponseModel.avs = self._avs
                                             
                                telrResponseModel.cardCode = self._cardCode
                                             
                                telrResponseModel.cardLast4 = self._cardLast4
                                            
                                telrResponseModel.cvv = self._cvv
                                             
                                telrResponseModel.trace = self._trace
                                
                                telrResponseModel.store = self.paymentRequest.store
                                
                                telrResponseModel.key = self.paymentRequest.key
                                
                                telrResponseModel.deviceType = self.paymentRequest.deviceType
                                
                                telrResponseModel.deviceId = self.paymentRequest.deviceId
                                
                                telrResponseModel.appId = self.paymentRequest.appId
                                
                                telrResponseModel.appName = self.paymentRequest.appName
                                
                                telrResponseModel.appUser = self.paymentRequest.appUser
                                
                                telrResponseModel.appVersion = self.paymentRequest.appVersion
                                
                                telrResponseModel.transTest = self.paymentRequest.transTest
                                
                                telrResponseModel.transType = self.paymentRequest.transType
                                
                                telrResponseModel.transClass = self.paymentRequest.transClass
                                
                                telrResponseModel.transCartid = self.paymentRequest.transCartid
                                
                                telrResponseModel.transDesc = self.paymentRequest.transDesc
                                
                                telrResponseModel.transCurrency = self.paymentRequest.transCurrency
                                
                                telrResponseModel.transAmount = self.paymentRequest.transAmount
                                
                                telrResponseModel.billingEmail = self.paymentRequest.billingEmail
                                
                                telrResponseModel.billingPhone = self.paymentRequest.billingPhone
                                
                                telrResponseModel.billingFName = self.paymentRequest.billingFName
                                
                                telrResponseModel.billingLName = self.paymentRequest.billingLName
                                
                                telrResponseModel.billingTitle = self.paymentRequest.billingTitle
                                
                                telrResponseModel.city = self.paymentRequest.city
                                
                                telrResponseModel.country = self.paymentRequest.country
                                
                                telrResponseModel.region = self.paymentRequest.region
                                
                                telrResponseModel.address = self.paymentRequest.address
                                
                                telrResponseModel.language = self.paymentRequest.language
                                
                                telrResponseModel.transRef = self._transRef
                                
                                telrResponseModel.transFirstRef = self._transRef
                                
                                self.saveTheCard(card: telrResponseModel)
                               
                                self.delegate?.didPaymentSuccess(response: telrResponseModel)
                                                          
                                self.dismiss(animated: true, completion: nil)
                                                          
                                let _ = self.navigationController?.popViewController(animated: true)
                                
                            
                             
                            }else{
                                DispatchQueue.main.async {
                                    self.delegate?.didPaymentFail(messge: message)

                                    self.dismiss(animated: true, completion: nil)

                                    let _ = self.navigationController?.popViewController(animated: true)
                                }
                            }
                            }
                           
                        }else{

                            let start = xmlresponse["mobile","webview","start"]

                            let code = xmlresponse["mobile","webview","code"]

                            self._code = code.text!

                            let newurl = URL(string:start.text!)

                            let newrequest = URLRequest(url: newurl!)

                            DispatchQueue.main.async {

                                self.webView.load(newrequest)

                            }

                        }

                    }
                   
                    
                    if error != nil {
                        DispatchQueue.main.async {
                            self.delegate?.didPaymentFail(messge: "Network error!")
                               
                            self.dismiss(animated: true, completion: nil)
                               
                            let _ = self.navigationController?.popViewController(animated: true)
                        }
                    }
                    
                   
                }).resume()
               
            }
    }
    
    private func initiateStatusRequest(key:String, store:String, complete:String) -> String{
        let xmlString =  """
         <?xml version=\"1.0\"?>
         <mobile>
             <store>\(store)</store>
             <key>\(key)</key>
             <complete>\(complete)</complete>
         </mobile>
         """
        return xmlString
    }
    
    private func checkStatus(key:String, store:String, complete:String, completionHandler:@escaping (Bool) -> ()) -> Void{
        
        let completeURL = "https://secure.telr.com/gateway/mobile_complete.xml"
        
        let xml:String = initiateStatusRequest(key:key, store:store, complete: complete)
       
        let data = xml.data(using: .utf8)
        
        let url = URL(string:completeURL)
        
        if let newurl = url{
            
            var request = URLRequest(url: newurl)
            
            request.httpMethod = "post"
            
            request.httpBody = data
            
            URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
               
                if let data = data{

                    let xmlresponse = XML.parse(data)

                    let statusMessage = xmlresponse["mobile","auth","message"]

                    self._code = xmlresponse["mobile","auth","code"].text

                    self._status = xmlresponse["mobile","auth","status"].text

                    self._avs = xmlresponse["mobile","auth","avs"].text

                    self._ca_valid = xmlresponse["mobile","auth","ca_valid"].text

                    self._cardCode = xmlresponse["mobile","auth","cardcode"].text

                    self._cardLast4 = xmlresponse["mobile","auth","cardlast4"].text

                    self._cvv = xmlresponse["mobile","auth","cvv"].text!

                    self._transRef = xmlresponse["mobile","auth","tranref"].text

                    self._transFirstRef = xmlresponse["mobile","auth","tranfirstref"].text

                    self._trace = xmlresponse["mobile","trace"].text

                    if statusMessage.text == "Authorised"{

                        completionHandler(true)

                    }else{

                        completionHandler(false)

                    }

                }
               
                if error != nil {
                    DispatchQueue.main.async {
                        self.delegate?.didPaymentFail(messge: "Network error!")
                           
                        self.dismiss(animated: true, completion: nil)
                           
                        let _ = self.navigationController?.popViewController(animated: true)
                    }
                }
                
            }).resume()
            
        }
    }
    private func initiatePaymentGateway(paymentRequest: PaymentRequest) -> String{
        let xmlString = """
        <?xml version=\"1.0\"?>
        <mobile>
            <store>\(paymentRequest.store)</store>
            <key>\(paymentRequest.key)</key>
            <device>
                <type>\(paymentRequest.deviceType)</type>
                <id>\(paymentRequest.deviceId)</id>
            </device>
            <app>
                <id>\(paymentRequest.appId)</id>
                <name>\(paymentRequest.appName)</name>
                <user>\(paymentRequest.appUser)</user>
                <version>\(paymentRequest.appVersion)</version>
                <sdk>SDK ver 2.0</sdk>
            </app>
            <tran>
                <test>\(paymentRequest.transTest)</test>
                <type>\(paymentRequest.transType)</type>
                <class>\(paymentRequest.transClass)</class>
                <cartid>\(paymentRequest.transCartid)</cartid>
                <description>\(paymentRequest.transDesc)</description>
                <currency>\(paymentRequest.transCurrency)</currency>
                <amount>\(paymentRequest.transAmount)</amount>
                <version>2</version>
                <language>\(paymentRequest.language)</language>
                <ref>\(paymentRequest.transRef)</ref>
                <firstref>\(paymentRequest.transFirstRef)</firstref>
            </tran>
            <billing>
                <email>\(paymentRequest.billingEmail)</email>
                <phone>\((paymentRequest.billingPhone))</phone>
                <name>
                    <first>\(paymentRequest.billingFName)</first>
                    <last>\(paymentRequest.billingLName)</last>
                    <title>\(paymentRequest.billingTitle)</title>
                </name>
                <address>
                    <city>\(paymentRequest.city)</city>
                    <country>\(paymentRequest.country)</country>
                    <region>\(paymentRequest.region)</region>
                    <line1>\(paymentRequest.address)</line1>
                </address>
            </billing>
        </mobile>
        """
        return xmlString
    }
   

}

extension TelrController : WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate{
    
     public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        actInd?.startAnimating()
        
        actInd?.isHidden = false
        
        decisionHandler(.allow)

     }

     public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
         
        actInd?.startAnimating()
              
        actInd?.isHidden = false

     }

     public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
         
        actInd?.stopAnimating()
        
        actInd?.isHidden = true
        
        DispatchQueue.main.async {
            self.delegate?.didPaymentFail(messge: "Network error!")
               
            self.dismiss(animated: true, completion: nil)
               
            let _ = self.navigationController?.popViewController(animated: true)
        }
        
    }

    func webViewDidStartLoad(_ : WKWebView) {
         
        actInd?.startAnimating()
         
        actInd?.isHidden = false
     
    }

    func webViewDidFinishLoad(_ : WKWebView){
         
        actInd?.stopAnimating()
        
        actInd?.isHidden = true
       
    }
       
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
          
        actInd?.stopAnimating()
           
        actInd?.isHidden = true
          
          
        if (webView.url?.path.contains("webview_close.html"))!{
            
               self.checkStatus(key: self.paymentRequest.key, store: self.paymentRequest.store, complete: self._code!)
               {
                   done in
                   let when = DispatchTime.now() + 0  // No waiting time
                   DispatchQueue.main.asyncAfter(deadline: when) {
                    let telrResponseModel = TelrResponseModel()
                    
                    if(done){
                           
                        telrResponseModel.message = "Your transaction is successful \(String(describing: self._trace))"
                        telrResponseModel.code = self._code
                                     
                        telrResponseModel.status = self._status
                                      
                        telrResponseModel.ca_valid = self._ca_valid
                                     
                        telrResponseModel.avs = self._avs
                                     
                        telrResponseModel.cardCode = self._cardCode
                                     
                        telrResponseModel.cardLast4 = self._cardLast4
                                    
                        telrResponseModel.cvv = self._cvv
                                     
                        telrResponseModel.trace = self._trace
                        
                        telrResponseModel.store = self.paymentRequest.store
                        
                        telrResponseModel.key = self.paymentRequest.key
                        
                        telrResponseModel.deviceType = self.paymentRequest.deviceType
                        
                        telrResponseModel.deviceId = self.paymentRequest.deviceId
                        
                        telrResponseModel.appId = self.paymentRequest.appId
                        
                        telrResponseModel.appName = self.paymentRequest.appName
                        
                        telrResponseModel.appUser = self.paymentRequest.appUser
                        
                        telrResponseModel.appVersion = self.paymentRequest.appVersion
                        
                        telrResponseModel.transTest = self.paymentRequest.transTest
                        
                        telrResponseModel.transType = self.paymentRequest.transType
                        
                        telrResponseModel.transClass = self.paymentRequest.transClass
                        
                        telrResponseModel.transCartid = self.paymentRequest.transCartid
                        
                        telrResponseModel.transDesc = self.paymentRequest.transDesc
                        
                        telrResponseModel.transCurrency = self.paymentRequest.transCurrency
                        
                        telrResponseModel.transAmount = self.paymentRequest.transAmount
                        
                        telrResponseModel.billingEmail = self.paymentRequest.billingEmail
                        
                        telrResponseModel.billingPhone = self.paymentRequest.billingPhone
                        
                        
                        telrResponseModel.billingFName = self.paymentRequest.billingFName
                        
                        telrResponseModel.billingLName = self.paymentRequest.billingLName
                        
                        telrResponseModel.billingTitle = self.paymentRequest.billingTitle
                        
                        telrResponseModel.city = self.paymentRequest.city
                        
                        telrResponseModel.country = self.paymentRequest.country
                        
                        telrResponseModel.region = self.paymentRequest.region
                        
                        telrResponseModel.address = self.paymentRequest.address
                        
                        telrResponseModel.language = self.paymentRequest.language
                        
                        telrResponseModel.transRef = self._transRef
                        
                        telrResponseModel.transFirstRef = self._transRef
                        
                        self.saveTheCard(card: telrResponseModel)
                       
                        self.delegate?.didPaymentSuccess(response: telrResponseModel)
                                                  
                        self.dismiss(animated: true, completion: nil)
                                                  
                        let _ = self.navigationController?.popViewController(animated: true)
                       
                    }else{
                          
                        DispatchQueue.main.async {
                            self.delegate?.didPaymentFail(messge: "Network error!")
                               
                            self.dismiss(animated: true, completion: nil)
                               
                            let _ = self.navigationController?.popViewController(animated: true)
                        }
                      
                    }
                       
           
    
                }
               
            }
           
        }
    }
    func saveTheCard(card:TelrResponseModel) {
       
        if let data = UserDefaults.standard.data(forKey: "cards") {
            do {
                let decoder = JSONDecoder()

                var telrResponseModels = try decoder.decode([TelrResponseModel].self, from: data)
                let filterdObject = telrResponseModels.filter { $0.cardLast4 == card.cardLast4 && $0.cardCode == card.cardCode}
                if filterdObject.count == 0 {
                    telrResponseModels.append(card)
                }
                let responseData = try JSONEncoder().encode(telrResponseModels)
                UserDefaults.standard.set(responseData, forKey: "cards")
            
            } catch {
                
                print("Unable to (\(error))")
               
            }
        }else{
            do {
                let responseData = try JSONEncoder().encode([card])
                UserDefaults.standard.set(responseData, forKey: "cards")
            } catch {
                print("Unable to (\(error))")
            }
        }
        
        
        
    }
   
 }
   

