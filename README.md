<p align="center">
<img
src='https://github.com/telrsdk/TelrSDK/blob/master/Example/TelrSDK/Images.xcassets/logo.imageset/Telr-logo-green-rgb-2000w.png' width="200"/>
</p>

# TelrSDK


[![Version](https://img.shields.io/cocoapods/v/TelrSDK.svg?style=flat)](https://cocoapods.org/pods/TelrSDK)
[![License](https://img.shields.io/cocoapods/l/TelrSDK.svg?style=flat)](https://cocoapods.org/pods/TelrSDK)
[![Platform](https://img.shields.io/cocoapods/p/TelrSDK.svg?style=flat)](https://cocoapods.org/pods/TelrSDK)


Our mission is to build connections that remove fragmentation in the e-commerce ecosystem. We make these connections to enable our customers to go cashless, digitising the way that they accept payments.
Use this  [link](https://telr.com/about-telr/) to started.

## Getting Started

Use this  [link](https://telr.com/support/article-categories/getting-started/) to started.

![](https://github.com/telrsdk/TelrSDK/blob/master/Example/TelrSDK/demo.gif)

## Register with Telr

Use this  [link](https://telr.com/support/knowledge-base/admin-system/) to find the step to register in our system.

## Requirements

The Telr iOS SDK requires Xcode 11 or later and is compatible with apps targeting iOS 9 or above. We support Catalyst on macOS 10.15 or later. 


## Custom Installation

Use this  [link](https://telr.com/support/knowledge-base/mobile-api-integration-guide/) to find the custom api.



## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.



## Installation

TelrSDK is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby

pod 'TelrSDK', "0.1.6"

```

Make sure you import the sdk where you want use it using below code

```ruby
import TelrSDK
```
Use this to set the details of store. Make sure you are using your store details

```ruby

let tabbyKEY:String = "pk_test_d878b6de-9f6f-4c2c-bc8c-fde1b249b9c4"

let KEY:String = " jT4F2^PjBp-n8jbr" // TODO fill key
let STOREID:String = "24717"  // TODO fill store id
let EMAIL:String = "test@test.com" // TODO fill email id

```

## To call the payment page you can use either of the two methods

```python

//Mark:-If you want to change the back button as custom back button on navigation
let customBackButton = UIButton(type: .custom)
customBackButton.setTitle("Back", for: .normal)
customBackButton.setTitleColor(.black, for: .normal)

//Mark:-Use this to push the telr payment page.
paymentRequest = preparePaymentRequest()
let telrController = TelrController()
telrController.delegate = self
telrController.customBackButton = customBackButton
telrController.paymentRequest = paymentRequest!
self.navigationController?.pushViewController(telrController, animated: true)

//Mark:-Use this to present the telr payment page.
paymentRequest = preparePaymentRequestSaveCard(lastresponse: cardDetails)
let telrController = TelrController()
telrController.delegate = self
telrController.paymentRequest = paymentRequest!
let nav = UINavigationController(rootViewController: telrController)
self.navigationController?.present(nav, animated: true, completion: nil)

```


## Delegate method for get response from payment gateway

```python

//Mark:-This call when the payment is cancelled by user
func didPaymentCancel()
//Mark:-This call when the payment is successful.
func didPaymentSuccess(response:TelrResponseModel)
//Mark:-This call when the payment is declined due to any reason.
func didPaymentFail(messge:String)


```

Also confirm the delegate methods

```ruby
extension ViewController:TelrControllerDelegate{
    
    
    //Mark:- This method will be called when user clicks on back button
    func didPaymentCancel() {
        print("didPaymentCancel")
        
    }
    
    //Mark:- This method will be called when the payment is completed successfully
    func didPaymentSuccess(response: TelrResponseModel) {
        
        print("didPaymentSuccess")
           
        print("month \(String(describing: response.month))")
           
        print("year \(String(describing: response.year))")
              
        print("Trace \(String(describing: response.trace))")
        
        print("Status \(String(describing: response.status))")
        
        print("Avs \(String(describing: response.avs))")
        
        print("Code \(String(describing: response.code))")
        
        print("Ca_valid \(String(describing: response.ca_valid))")
        
        print("Card Code \(String(describing: response.cardCode))")
        
        print("Card Last4 \(String(describing: response.cardLast4))")
        
        print("CVV \(String(describing: response.cvv))")
        
        print("TransRef \(String(describing: response.transRef))")
        
        //To save the card for future transactions, you will be required to store tranRef. 
        //When the customer will be attempting transaction using the previously used card tranRef will be used
        
        self.displaySavedCard()
      
      
    }
    
    //Mark:- This method will be called when user clicks on cancel button and the
    payment gets failed
    func didPaymentFail(messge: String) {
        print("didPaymentFail  \(messge)")
        
    }
    
   
        
}

```

## Saved cards
### (It works locally using user default. Masked Card details will be deleted when app is deleted)
```python

//Mark:- This returns masked card details of saved card.
let savedCard = TelrResponseModel().getSavedCards()

```

## To use Saved Card without CVV, please use below code while binding the payment request
```python

//Mark:- Set type as ‘sale’, class as ‘cont’ and send previous transaction reference in ‘ref’ parameter

paymentReq.transType = "sale"
paymentReq.transClass = "cont"
paymentReq.transRef = lastresponse.transRef ?? ""

```

## To use Saved Card with CVV, please use below code while binding the payment request
```python

//Mark:- Set type as ‘paypage’ and class as ‘ecom’ and send previous transaction reference in ‘firstref’ parameter


paymentReq.transType = "paypage"
paymentReq.transClass = "ecom"
paymentReq.transFirstRef = lastresponse.transFirstRef ?? ""

```

## Payment request builder for both saved card and new card

```python

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
    
        paymentReq.transTest = "1"//0
   
        paymentReq.transType = "paypage"
   
        paymentReq.transClass = "ecom"
    
        paymentReq.transCartid = String(arc4random())
    
        paymentReq.transDesc = "Test API"
    
        paymentReq.transCurrency = "AED"
    
        paymentReq.transAmount = amountTxt.text!
    
        paymentReq.billingEmail = EMAIL
        
        paymentReq.billingPhone = "8888888888"
    
        paymentReq.billingFName = self.firstNameTxt.text!
    
        paymentReq.billingLName = self.lastNameTxt.text!
    
        paymentReq.billingTitle = "Mr"
    
        paymentReq.city = "Dubai"
    
        paymentReq.country = "AE"
    
        paymentReq.region = "Dubai"
    
        paymentReq.address = "line 1"
    
        paymentReq.language = "en"
    
        return paymentReq

    }
    
    private func preparePaymentRequestSaveCard(lastresponse:TelrResponseModel) -> PaymentRequest{

     
        let paymentReq = PaymentRequest()
     
        paymentReq.key = lastresponse.key ?? ""
     
        paymentReq.store = lastresponse.store ?? ""
     
        paymentReq.appId = lastresponse.appId ?? ""
     
        paymentReq.appName = lastresponse.appName ?? ""
     
        paymentReq.appUser = lastresponse.appUser ?? ""
     
        paymentReq.appVersion = lastresponse.appVersion ?? ""
     
        paymentReq.transTest = lastresponse.transTest ?? ""
        
//        //Mark:- Without CVV
//
//        paymentReq.transType = "sale"
//
//        paymentReq.transClass = "cont"
        
//        paymentReq.transRef = lastresponse.transRef ?? ""
        
        
        //Mark:- With CVV

        paymentReq.transType = "paypage"

        paymentReq.transClass = "ecom"
        
        paymentReq.transFirstRef = lastresponse.transFirstRef ?? ""
        
        //
        
        paymentReq.transCartid = String(arc4random())
     
        paymentReq.transDesc = lastresponse.transDesc ?? ""
     
        paymentReq.transCurrency = lastresponse.transCurrency ?? ""
     
        paymentReq.billingFName = lastresponse.billingFName ?? ""
     
        paymentReq.billingLName = lastresponse.billingLName ?? ""
     
        paymentReq.billingTitle = lastresponse.billingTitle ?? ""
     
        paymentReq.city = lastresponse.city ?? ""
     
        paymentReq.country = lastresponse.country ?? ""
     
        paymentReq.region = lastresponse.region ?? ""
     
        paymentReq.address = lastresponse.address ?? ""
     
        paymentReq.transAmount = amountTxt.text!
            
        paymentReq.billingEmail = lastresponse.billingEmail ?? ""
     
        paymentReq.billingPhone = lastresponse.billingPhone ?? ""
     
        paymentReq.language = "en"
     
        return paymentReq

     }


}


```
## Authorisation response

| Field  | Description |
| :------------- | :------------- |
| status  | Authorisation status. A indicates an authorised transaction. H also indicates an authorised transaction, but where the transaction has been placed on hold. Any other value indicates that the request could not be processed.  |
| code  | If the transaction was authorised, this contains the authorisation code from the card issuer. Otherwise it contains a code indicating why the transaction could not be processed.  |
| message  | The authorisation or processing error message.  |
|  tranref  | The payment gateway transaction reference allocated to this request.  |
| cvv  | Result of the CVV check: Y = CVV matched OK N = CVV not matched X = CVV not checked E = Error, unable to check CVV  |
| avs  | Result of the AVS check: Y = AVS matched OK P = Partial match (for example, post-code only) N = AVS not matched X = AVS not checked E = Error, unable to check AVS  |
| cardcode  | Code to indicate the card type used in the transaction. See the code list at the end of the document for a list of card codes. |
| cardlast4  | The last 4 digits of the card number used in the transaction. This is supplied for all payment types (including the Hosted Payment Page method) except for PayPal. |


## Test Cards

These card numbers can be used when testing your integration to the payment gateway. These cards will not work for live transactions.


| Card number  | Type  | CVV | MPI |
| :------------ |:---------------|:-----|:-----|
| 4111 1111 1111 1111 | Visa | 123 | Yes |
| 4444 3333 2222 1111 | Visa | 123 | Yes |
| 4444 4244 4444 4440 | Visa | 123 | Yes |
| 4444 4444 4444 4448 | Visa | 123 | Yes |
| 4012 8888 8888 1881 | Visa | 123 | Yes |
| 5105 1051 0510 5100 | Mastercard | 123 | No |
| 5454 5454 5454 5454 | Mastercard | 123 | Yes |
| 5555 5555 5555 4444 | Mastercard | 123 | Yes |
| 5555 5555 5555 5557 | Mastercard | 123 | Yes |
| 5581 5822 2222 2229 | Mastercard | 123 | Yes |
| 5641 8209 0009 7002 | Maestro UK | 123 | Yes |
| 6767 0957 4000 0005 | Solo | 123 | No |
| 3434 343434 34343 | American Express | 1234 | No |
| 3566 0020 2014 0006 | JCB | 123 | No |




## Author

Telr SDK, support@telr.com

## License

TelrSDK is available under the MIT license. See the LICENSE file for more info.
