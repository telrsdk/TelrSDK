//
//  TelrResponseModel.swift
//  TelrSDK
//
//  Created by Telr Sdk on 10/02/2020.
//  Copyright (c) 2020 Telr Sdk. All rights reserved.
//
import Foundation

public class TelrResponseModel : Encodable & Decodable{

    public init(){
        
    }
    @objc public var message:String?// The authorisation or processing error message.
      
    @objc public var trace:String?
          
    @objc public var status:String?      // Authorisation status. A indicates an authorised transaction. H also indicates an authorised transaction, but where the transaction has been placed on hold. Any other value indicates that the request could not be processed.
    @objc public var avs:String?         /* Result of the AVS check:-
           Y = AVS matched OK
           P = Partial match (for example, post-code only)
           N = AVS not matched
           X = AVS not checked
           E = Error, unable to check AVS */
    @objc public var code:String?        // If the transaction was authorised, this contains the authorisation code from the card issuer. Otherwise it contains a code indicating why the transaction could not be processed.
          
    @objc public var ca_valid:String?
          
    @objc public var cardCode:String?    // Code to indicate the card type used in the transaction. See the code list at the end of the document for a list of card codes.
          
    @objc public var cardLast4:String?   // The last 4 digits of the card number used in the transaction. This is supplied for all payment types (including the Hosted Payment Page method) except for PayPal.
          
    @objc public var month:String?
    
    @objc public var year:String?
    
    @objc public var cvv:String?         /* Result of the CVV check:
           Y = CVV matched OK
           N = CVV not matched
           X = CVV not checked
           E = Error, unable to check CVV */
        
    @objc public var store : String?
        
    @objc public var key : String?
        
    @objc public var deviceType : String?
        
    @objc public var deviceId : String?
        
    @objc public var appId : String?
        
    @objc public var appName : String?
        
    @objc public var appUser : String?

    @objc public var appVersion : String?
        
    @objc public var transTest : String?
        
    @objc public var transType : String?
        
    @objc public var transClass : String?
        
    @objc public var transCartid : String?
        
    @objc public var transDesc : String?
        
    @objc public var transCurrency : String?
        
    @objc public var transAmount : String?
        
    @objc public var billingEmail : String?
    
    @objc public var billingPhone : String?
        
    @objc public var billingFName : String?
        
    @objc public var billingLName : String?
        
    @objc public var billingTitle : String?
        
    @objc public var city : String?
        
    @objc public var country : String?

    @objc public var region : String?
        
    @objc public var address : String?
    
    @objc public var zip : String?
        
    @objc public var language : String?
        
    @objc public var transRef : String?
        
    @objc public var transFirstRef : String?
      
    
    public func getSavedCards() -> [TelrResponseModel] {
        
        if let data = UserDefaults.standard.data(forKey: "cards") {
            do {
                let decoder = JSONDecoder()

                let telrResponseModels = try decoder.decode([TelrResponseModel].self, from: data)
                
                return telrResponseModels.reversed()
            
            } catch {
                
                print("Unable to Decode Note (\(error))")
                return []
            
            }
        }else{
            return []
        }
        
        
    }
    
}
