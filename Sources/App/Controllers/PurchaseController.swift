import Vapor
import HTTP

// /purchase
final class PurchaseController {
    
    // Routes
    func makeRoutes(routes: RouteBuilder) {
        let group = routes.grouped("purchase")
        
        group.get(handler: getAllPurchases)
        group.get(Purchase.parameter, handler: getPurchaseDetails)
        group.post(handler: createPurchase)
        group.post("addproduct", handler: addProduct)
        group.post("pay", Purchase.parameter, handler: pay)
    }
    
    // METHODS
    
    // GET /
    // Get all purchases for user
    func getAllPurchases(req: Request) throws -> ResponseRepresentable {
        let user = try req.auth.assertAuthenticated(User.self)
        
        return try Purchase.makeQuery().filter(Purchase.userIdKey, .equals, user.id).all().makeJSON()
    }
    
    // GET /:id
    // Get purchase details
    func getPurchaseDetails(req: Request) throws -> ResponseRepresentable {
        let user = try req.auth.assertAuthenticated(User.self)
        let purchase = try req.parameters.next(Purchase.self)
        
        if (user.id != purchase.userId) {
            return Response(status: Status.unauthorized)
        }
        
        return try PurchaseProduct.makeQuery().filter(PurchaseProduct.purchaseIdKey, .equals, purchase.id).all().makeJSON()
    }
    
    // POST /
    // Create purchase
    func createPurchase(req: Request) throws -> ResponseRepresentable {
        let purchase = try req.purchase()
        try purchase.save()
        return purchase
    }
    
    // POST /pay
    // Purchase payment
    func pay(req: Request) throws -> ResponseRepresentable {
        let paymentInfo = try req.payment()
        let purchase = try req.parameters.next(Purchase.self)
        
        let products = try purchase.products.all()
        
        var price: Float = 0
        for product in products {
            price += product.price
        }
        price *= 100
        
        let user = try req.auth.assertAuthenticated(User.self)
        
        let stripeClient = try StripeClient(apiKey: "sk_test_QYeVSjIJJ5HNIujPjrUALzH0")
        stripeClient.initializeRoutes()
        
        let createCustomer = try stripeClient.customer.create(email: user.email)
        let customer = try createCustomer.serializedResponse()
        
        let addCard = try stripeClient.customer.addCard(customer: customer.id!, number: paymentInfo.cardNumber, expMonth: paymentInfo.cardExpirationMonth, expYear: paymentInfo.cardExpirationYear, cvc: paymentInfo.cardExpirationCvc)
        let cardResponse = try addCard.serializedResponse()
        
        let charge = try stripeClient.charge.create(amount: Int(price), in: .usd, for: ChargeType.customer(customer.id!), description: "")
        let chargeResponse = try charge.serializedResponse()
        
        // change purchase status
        purchase.statusId = 2
        try purchase.save()
        
        return "ok"
    }
    
    // POST /
    // Add product to purchase
    func addProduct(req: Request) throws -> ResponseRepresentable {
        let purchaseProduct = try req.purchaseProduct()
        try purchaseProduct.save()
        return purchaseProduct
    }
}

// Deserialize JSON
extension Request {
    func purchase() throws -> Purchase {
        guard let json = json else { throw Abort.badRequest }
        return try Purchase(json: json)
    }
    
    func purchaseProduct() throws -> PurchaseProduct {
        guard let json = json else { throw Abort.badRequest }
        return try PurchaseProduct(json: json)
    }
    
    func payment() throws -> Payment {
        guard let json = json else { throw Abort.badRequest }
        return try Payment(json: json)
    }
}

extension PurchaseController: EmptyInitializable { }
