//
//  TabbyController.swift
//  Pods
//
//  Created by Admin on 22/12/20.
//


import UIKit
import WebKit
public protocol TabbyControllerDelegate {
    
    func didTabbyPaymentCancel()
    
    func didTabbyPaymentSuccess(response:[String:Any]?)
    
    func didTabbyPaymentFail(messge:String)
}
public class TabbyController: UIViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler,UIScrollViewDelegate {

    public var session: [String: Any]?
    public var productType: String?
    
    public var apiKey: String?
    
    public var delegate : TabbyControllerDelegate?
    
    @objc var webView : WKWebView = WKWebView()
    var actInd: UIActivityIndicatorView?
    public var customBackButton : UIButton?
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.presentationController?.presentedView?.gestureRecognizers?[0].isEnabled = false
        self.addBackButton()
        self.addWebview()
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
       
        self.delegate?.didTabbyPaymentCancel()
    
        self.dismiss(animated: true, completion: nil)
    
        let _ = self.navigationController?.popViewController(animated: true)
    }
    private func addWebview(){
        DispatchQueue.main.async {
            
            self.navigationController?.presentationController?.presentedView?.gestureRecognizers?[0].isEnabled = false
            
            self.createWebView()
                   
        }
        
    }
    @objc func createWebView() {

            
        let viewBack = UIView()
        
        viewBack.backgroundColor = .white
        
        viewBack.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.preferences.javaScriptEnabled = true
        
        // Please note tabbyAppListener, we're testing solution where this code won't be necessary
        // and tabbyAppListener will be a connection point between Tabby.SDK and Mobile App
        // please don't change tabbyAppListener naming
        let js = """
            var launchTabby = true;
            window.SDK = {
                config: {
                    direction: 'ltr',
                    onChange: function(data) {
                        window.webkit.messageHandlers.tabbyAppListener.postMessage(JSON.stringify(data));
                        if (data.status === 'created' && launchTabby) {
                            Tabby.launch({product: '\(productType ?? "")'});
                            launchTabby = false;
                        }
                    },
                    onClose: function() {
                        window.webkit.messageHandlers.tabbyAppListener.postMessage('close');
                    }
                }
            };
        """
        webConfiguration.userContentController.addUserScript(
            WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        )
        webConfiguration.userContentController.add(self, name: "tabbyAppListener")
        
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView = WKWebView(frame: CGRect.zero, configuration: webConfiguration)
            
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
        
        self.loadPaymentPage()
        
        viewBack.addSubview(webView)
        
        self.view.addSubview(viewBack)
        
    }
    
   
    @objc func loadPaymentPage(){
        
        webView.navigationDelegate = self
        
        let urlString = "https://checkout.tabby.ai/"
        if var urlComponents = URLComponents(string: urlString) {
            let queryItems: [URLQueryItem] = [
                URLQueryItem(name: "apiKey", value: apiKey ?? ""),
                URLQueryItem(name: "sessionId", value: session!["id"] as? String),
                URLQueryItem(name: "product", value: productType ?? ""),
            ]
            urlComponents.queryItems = queryItems
            let request = URLRequest(url: urlComponents.url!)
            print("url: \(request.url?.absoluteString ?? "")")
            webView.load(request)
        }
    }

    // MARK: - WKNavigationDelegate
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!)
    {
        print(#function)
       
    }
    
    // MARK: - WKScriptMessageHandler
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
       
      
       
       decisionHandler(.allow)

    }

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage)
    {
        print(message.body)
        if let msg = message.body as? String {
            if msg == "close" {
                   
                self.dismiss(animated: true, completion: nil)
                   
                let _ = self.navigationController?.popViewController(animated: true)
            } else {
                let session: CreatedCheckoutSession = try! JSONDecoder().decode(CreatedCheckoutSession.self, from: Data(msg.utf8))
                print("session: \(session)")
                // Here you get all the updetes from Tabby API
                // Save order when session.payment.status == "authorized"
                switch session.payment?.status {
                
                case .authorized, .rejected:
                    let json = try! JSONSerialization.jsonObject(with: Data(msg.utf8), options: .mutableContainers) as? [String: Any]
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                        self.delegate?.didTabbyPaymentSuccess(response: json)
                        self.dismiss(animated: true, completion: nil)
                           
                        let _ = self.navigationController?.popViewController(animated: true)
                    }
                default:
                   
                    break
                }
            }
        }
    }
    
    
}

public struct CreatedCheckoutSession: Decodable {
    var id: String?
    var status: String?
    var payment: Payment?
    var statusMessage : String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case status = "status"
        case payment = "payment"
    }
}

public struct Payment: Decodable {
    var status: PaymentStatus
    enum CodingKeys: String, CodingKey {
        case status = "status"
    }
}

public enum PaymentStatus: String, Decodable {
    case authorized = "authorized"
    case rejected = "rejected"
    case closed = "closed"
    case created = "CREATED"
    
}



public class Chekout {
    
    public init() {}
    
    public func getCheckoutSession(apikey: String,productType:String,body:String,_ completion: @escaping (_ isProductType:Bool,_ session: [String: Any]?) -> ()){
        
        var request = URLRequest(url: URL(string: "https://api.tabby.ai/api/v2/checkout")!)
        request.httpMethod = "post"
        let key = apikey
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
                    let session = json
                    if let configuration = json["configuration"] as? NSDictionary {
                        print(configuration)
                        
                        if let available_products = configuration["available_products"] as? NSDictionary {
                                for (key, _) in available_products {
                                        let type = key as! String
                                        switch type {
                                        case productType:
                                            completion(true,session)
                                            break
                                        default:
                                            continue
                                }
                               
                                
                            }
                            
                        }
                    }
         
                 }
              } catch let error {
                completion(false,nil)
                print(error.localizedDescription)
              }
           })

           task.resume()
        
    }
    
}
