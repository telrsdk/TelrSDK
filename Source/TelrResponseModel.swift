//
//  TelrResponseModel.swift
//  TelrSDK
//
//  Created by Telr Sdk on 10/02/2020.
//  Copyright (c) 2020 Telr Sdk. All rights reserved.
//
import Foundation

public class TelrResponseModel{

    public init(){
        
    }
    @objc public var message:String?// The authorisation or processing error message.
      
      @objc public var trace:String?
      
      @objc public var status:String?      // Authorisation status. A indicates an authorised transaction. H also indicates an authorised transaction, but where the transaction has been placed on hold. Any other value indicates that the request could not be processed.
      
      @objc public var avs:String?         /* Result of the AVS check:
       Y = AVS matched OK
       P = Partial match (for example, post-code only)
       N = AVS not matched
       X = AVS not checked
       E = Error, unable to check AVS */
      @objc public var code:String?        // If the transaction was authorised, this contains the authorisation code from the card issuer. Otherwise it contains a code indicating why the transaction could not be processed.
      
      @objc public var ca_valid:String?
      
      @objc public var cardCode:String?    // Code to indicate the card type used in the transaction. See the code list at the end of the document for a list of card codes.
      
      @objc public var cardLast4:String?   // The last 4 digits of the card number used in the transaction. This is supplied for all payment types (including the Hosted Payment Page method) except for PayPal.
      
      @objc public var cvv:String?         /* Result of the CVV check:
       Y = CVV matched OK
       N = CVV not matched
       X = CVV not checked
       E = Error, unable to check CVV */
      @objc public var tranRef:String?
      
      
      @objc public var cardFirst6:String?  // The first 6 digits of the card number used in the transaction
      

}
