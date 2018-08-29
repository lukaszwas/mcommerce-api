//
//  Endpoints.swift
//  Stripe
//
//  Created by Anthony Castelli on 4/13/17.
//
//

import Foundation
import HTTP

internal let APIBase = "https://api.stripe.com/"
internal let APIVersion = "v1/"

internal let DefaultHeaders = [
    HeaderKey.contentType: "application/x-www-form-urlencoded",
    StripeHeader.Version: "2017-04-06"
]

internal struct StripeHeader {
    static let Version = HeaderKey("Stripe-Version")
    static let Authorization = HeaderKey("Authorization")
    static let Account = HeaderKey("Stripe-Account")
}

internal enum API {
    
    /**
     BALANCE
     This is an object representing your Stripe balance. You can retrieve it to see the balance 
     currently on your Stripe account. You can also retrieve a list of the balance history, which 
     contains a list of transactions that contributed to the balance 
     (e.g., charges, transfers, and so forth). The available and pending amounts for each currency 
     are broken down further by payment source types.
     */
    case balance
    case balanceHistory
    case balanceHistoryTransaction(String)
    
    /**
     CHARGES
     To charge a credit or a debit card, you create a charge object. You can retrieve and refund 
     individual charges as well as list all charges. Charges are identified by a unique random ID.
    */
    case charges
    case charge(String)
    case captureCharge(String)
    
    /**
     CUSTOMERS
     Customers allow you to perform recurring charges and track multiple charges that are
     associated with the same customer. The API allows you to create, delete, and update your customers. 
     You can retrieve individual customers as well as a list of all your customers.
    */
    case customers
    case customer(String)
    
    /**
     CARDS
    */
    case card(String, String)
    case createCard(String)
    
    var endpoint: String {
        switch self {
        case .balance: return APIBase + APIVersion + "balance"
        case .balanceHistory: return APIBase + APIVersion + "balance/history"
        case .balanceHistoryTransaction(let id): return APIBase + APIVersion + "balance/history/\(id)"
        
        case .charges: return APIBase + APIVersion + "charges"
        case .charge(let id): return APIBase + APIVersion + "charges/\(id)"
        case .captureCharge(let id): return APIBase + APIVersion + "charges/\(id)/capture"
            
        case .customers: return APIBase + APIVersion + "customers"
        case .customer(let id): return APIBase + APIVersion + "customers/\(id)"
            
        case .card(let customerId, let cardId): return APIBase + APIVersion + "customers/\(customerId)/sources/\(cardId)"
        case .createCard(let customerId): return APIBase + APIVersion + "customers/\(customerId)/sources"
        }
    }
    
}
