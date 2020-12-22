//
//  TabbyController.swift
//  Pods
//
//  Created by Admin on 22/12/20.
//


import UIKit
import WebKit
public protocol TabbyControllerDelegate {
    
    func didPaymentCancel()
    
    func didPaymentSuccess(response:CreatedCheckoutSession)
    
    func didPaymentFail(messge:String)
}
class TabbyController: UIViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler,UIScrollViewDelegate {

    var session: [String: Any]?
    var productType: String?
    
    
    @objc var webView : WKWebView = WKWebView()
    var actInd: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.presentationController?.presentedView?.gestureRecognizers?[0].isEnabled = false
        self.addWebview()
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
                URLQueryItem(name: "apiKey", value: "pk_test_d878b6de-9f6f-4c2c-bc8c-fde1b249b9c4"),
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
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!)
    {
        print(#function)
       
    }
    
    // MARK: - WKScriptMessageHandler
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
       
      
       
       decisionHandler(.allow)

    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage)
    {
        print(message.body)
        if let msg = message.body as? String {
            if msg == "close" {
                self.navigationController?.popViewController(animated: true)
            } else {
                let session: CreatedCheckoutSession = try! JSONDecoder().decode(CreatedCheckoutSession.self, from: Data(msg.utf8))
                print("session: \(session)")
                // Here you get all the updetes from Tabby API
                // Save order when session.payment.status == "authorized"
                switch session.payment?.status {
                case .authorized, .rejected:
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                            self.navigationController?.popViewController(animated: true)
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
