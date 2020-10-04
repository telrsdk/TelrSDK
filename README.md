<p align="center">
<img
src='https://github.com/telrsdk/TelrSDK/blob/master/Example/TelrSDK/Images.xcassets/logo.imageset/Telr-logo-green-rgb-2000w.png' width="200"/>
</p>

# TelrSDK

Our mission is to build connections that remove fragmentation in the e-commerce ecosystem. We make these connections to enable our customers to go cashless, digitising the way that they accept payments.
Use this  [link](https://telr.com/about-telr/) to started.

## Getting Started

Use this  [link](https://telr.com/support/article-categories/getting-started/) to started.

## Register with Telr

Use this  [link](https://telr.com/support/knowledge-base/admin-system/) to find the step to register in our system.

## Requirements

The Stripe iOS SDK requires Xcode 11 or later and is compatible with apps targeting iOS 9 or above. We support Catalyst on macOS 10.15 or later. 


## Custom Installation

Use this  [link](https://telr.com/support/knowledge-base/mobile-api-integration-guide/) to find the custom api.


[![Version](https://img.shields.io/cocoapods/v/TelrSDK.svg?style=flat)](https://cocoapods.org/pods/TelrSDK)
[![License](https://img.shields.io/cocoapods/l/TelrSDK.svg?style=flat)](https://cocoapods.org/pods/TelrSDK)
[![Platform](https://img.shields.io/cocoapods/p/TelrSDK.svg?style=flat)](https://cocoapods.org/pods/TelrSDK)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.



## Installation

TelrSDK is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'TelrSDK'
```

## For Call the payment page we use two methoads

```python

//Mark:-If you what change the back button as custome back button on navigation
let customBackButton = UIButton(type: .custom)
customBackButton.setTitle("Back", for: .normal)
customBackButton.setTitleColor(.black, for: .normal)

//Mark:-Use this for push the telr payment page.
paymentRequest = preparePaymentRequest()
let telrController = TelrController()
telrController.delegate = self
telrController.customBackButton = customBackButton
telrController.paymentRequest = paymentRequest!
self.navigationController?.pushViewController(telrController, animated: true)

//Mark:-Use this for present the telr payment page.
paymentRequest = preparePaymentRequestSaveCard(lastresponse: cardDetails)
let telrController = TelrController()
telrController.delegate = self
telrController.paymentRequest = paymentRequest!
let nav = UINavigationController(rootViewController: telrController)
self.navigationController?.present(nav, animated: true, completion: nil)

```

## For getting the saved card you can use
### (Its work locally using user default card will deleted when app is deleted)
```python

//Mark:- This return card details of saved card.
let savedCard = TelrResponseModel().getSavedCards()

```


## Delegate method for get response from payment gateway

```python

//Mark:-This call when payment cancel by user
func didPaymentCancel()

//Mark:-This call when payment successful.
func didPaymentSuccess(response:TelrResponseModel)

//Mark:-This call when payment getting failed with any reason.
func didPaymentFail(messge:String)

```






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

Telr Sdk, telrsdk@gmail.com

## License

TelrSDK is available under the MIT license. See the LICENSE file for more info.
