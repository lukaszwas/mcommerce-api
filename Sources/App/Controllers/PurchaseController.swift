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
}

extension PurchaseController: EmptyInitializable { }
