//
//  CustomerRoutes.swift
//  Stripe
//
//  Created by Anthony Castelli on 4/20/17.
//
//

import Foundation
import Node
import HTTP

public final class CustomerRoutes {
    
    let client: StripeClient
    
    init(client: StripeClient) {
        self.client = client
    }
    
    /**
     Create a customer
     Creates a new customer object.
     
     - parameter email:       The Customer’s email address. It’s displayed alongside the customer in your
                              dashboard and can be useful for searching and tracking.
     
     - parameter description: An arbitrary string that you can attach to a customer object. It is displayed 
                              alongside the customer in the dashboard. This will be unset if you POST an 
                              empty value.
     
     - parameter metadata:    A set of key/value pairs that you can attach to a customer object. It can be 
                              useful for storing additional information about the customer in a structured 
                              format. You can unset individual keys if you POST an empty value for that key. 
                              You can clear all keys if you POST an empty value for metadata.
     
     - returns: A StripeRequest<> item which you can then use to convert to the corresponding node
    */
    public func create(email: String, currency: StripeCurrency? = nil, description: String? = nil, metadata: [String : String]? = nil) throws -> StripeRequest<Customer> {
        var body = Node([:])
        
        body["email"] = Node(email)
        
        if let currency = currency {
            body["curency"] = Node(currency.rawValue)
        }
        
        if let description = description {
            body["description"] = Node(description)
        }
        
        if let metadata = metadata {
            for (key, value) in metadata {
                body["metadata[\(key)]"] = try Node(node: value)
            }
        }
        
        return try StripeRequest(client: self.client, method: .post, route: .customers, query: [:], body: Body.data(body.formURLEncoded()), headers: nil)
    }
    
    /**
     Create a customer
     Creates a new customer object.
     
     - parameter customer: A customer class created with appropiate values set. Any unset parameters (nil) 
                           will unset the value on stripe
     
     - returns: A StripeRequest<> item which you can then use to convert to the corresponding node
     */
    public func create(customer: Customer) throws -> StripeRequest<Customer> {
        var body = Node([:])
        
        if let email = customer.email {
            body["email"] = Node(email)
        }
        
        if let description = customer.description {
            body["description"] = Node(description)
        }
        
        if let bussinessVATId = customer.bussinessVATId {
            body["business_vat_id"] = Node(bussinessVATId)
        }
        
        if let defaultSourceId = customer.defaultSourceId {
            body["source"] = Node(defaultSourceId)
        }
        
        if let currency = customer.currency {
            body["currency"] = Node(currency.rawValue)
        }
        
        if let metadata = customer.metadata {
            for (key, value) in metadata {
                body["metadata[\(key)]"] = try Node(node: "\(value)")
            }
        }
        
        return try StripeRequest(client: self.client, method: .post, route: .customers, query: [:], body: Body.data(body.formURLEncoded()), headers: nil)
    }
    
    /**
     Retrieve a customer
     Retrieves the details of an existing customer. You need only supply the unique customer identifier 
     that was returned upon customer creation.
     
     - parameter customerId: The Customer's ID
     
     - returns: A StripeRequest<> item which you can then use to convert to the corresponding node
    */
    public func retrieve(customer customerId: String) throws -> StripeRequest<Customer> {
        return try StripeRequest(client: self.client, method: .get, route: .customer(customerId), query: [:], body: nil, headers: nil)
    }
    
    /**
     Update a customer
     Updates the specified customer by setting the values of the parameters passed. Any parameters not 
     provided will be left unchanged. For example, if you pass the source parameter, that becomes the 
     customer’s active source (e.g., a card) to be used for all charges in the future. When you update a 
     customer to a new valid source: for each of the customer’s current subscriptions, if the subscription 
     is in the past_due state, then the latest unpaid, unclosed invoice for the subscription will be retried 
     (note that this retry will not count as an automatic retry, and will not affect the next regularly 
     scheduled payment for the invoice). (Note also that no invoices pertaining to subscriptions in the 
     unpaid state, or invoices pertaining to canceled subscriptions, will be retried as a result of updating 
     the customer’s source.)
     
     This request accepts mostly the same arguments as the customer creation call.
     
     - parameter customer: A customer class created with appropiate values set. Any unset parameters (nil)
     will unset the value on stripe
     
     - returns: A StripeRequest<> item which you can then use to convert to the corresponding node
     */
    public func update(customer: Customer, forCustomerId customerId: String) throws -> StripeRequest<Customer> {
        var body = Node([:])
        
        if let email = customer.email {
            body["email"] = Node(email)
        }
        
        if let description = customer.description {
            body["description"] = Node(description)
        }
        
        if let bussinessVATId = customer.bussinessVATId {
            body["business_vat_id"] = Node(bussinessVATId)
        }
        
        if let defaultSourceId = customer.defaultSourceId {
            body["source"] = Node(defaultSourceId)
        }
        
        if let metadata = customer.metadata {
            for (key, value) in metadata {
                body["metadata[\(key)]"] = try Node(node: "\(String(describing: value))")
            }
        }
        
        return try StripeRequest(client: self.client, method: .post, route: .customer(customerId), query: [:], body: Body.data(body.formURLEncoded()), headers: nil)
    }
    
    /**
     Delete a customer
     Permanently deletes a customer. It cannot be undone. Also immediately cancels any active subscriptions on the customer.
     
     - parameter customerId: The Customer's ID
     
     - returns: A StripeRequest<> item which you can then use to convert to the corresponding node
     */
    public func delete(customer customerId: String) throws -> StripeRequest<DeletedObject> {
        return try StripeRequest(client: self.client, method: .delete, route: .customer(customerId), query: [:], body: nil, headers: nil)
    }
    
    /**
     List all customers
     Returns a list of your customers. The customers are returned sorted by creation date, with the 
     most recent customers appearing first.
     
     - parameter filter: A Filter item to ass query parameters when fetching results
     
     - returns: A StripeRequest<> item which you can then use to convert to the corresponding node
     */
    public func listAll(filter: Filter?=nil) throws -> StripeRequest<CustomerList> {
        var query = [String : NodeRepresentable]()
        if let data = try filter?.createQuery() {
            query = data
        }
        return try StripeRequest(client: self.client, method: .get, route: .customers, query: query, body: nil, headers: nil)
    }
    
    /**
     Retrieve customer's card
     */
    public func retrieveCard(customer customerId: String, cardId: String) throws -> StripeRequest<Card> {
        return try StripeRequest(client: self.client, method: .get, route: .card(customerId, cardId), query: [:], body: nil, headers: nil)
    }
    
    /**
     Add customer's card
     */
    public func addCard(customer customerId: String, number: String, expMonth: String, expYear: String, cvc: String) throws -> StripeRequest<Card> {
        
        var body = Node([:])
        
        body["card"] = Node([:])
        try body["card"]?.set("number", number)
        try body["card"]?.set("exp_month", expMonth)
        try body["card"]?.set("exp_year", expYear)
        try body["card"]?.set("cvc", cvc)
        
        return try StripeRequest(client: self.client, method: .post, route: .createCard(customerId), query: [:], body: Body.data(body.formURLEncoded()), headers: nil)
    }
}
