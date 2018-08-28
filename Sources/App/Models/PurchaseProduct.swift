import Vapor
import FluentProvider
import HTTP

final class PurchaseProduct: Model {
    static let name = "PurchProd"
    
    let storage = Storage()
    
    // Columns
    var purchaseId: Identifier
    var productId: Identifier
    var price: Float
    
    var purchase: Parent<PurchaseProduct, Purchase> {
        return parent(id: purchaseId)
    }
    
    var product: Parent<PurchaseProduct, Product> {
        return parent(id: productId)
    }
    
    // Column names
    static let idKey = "id"
    static let purchaseIdKey = "purchase_id"
    static let productIdKey = "product_id"
    static let productKey = "product"
    static let priceKey = "price"
    
    // Init
    init(
        purchaseId: Identifier,
        productId: Identifier,
        price: Float
        ) {
        self.purchaseId = purchaseId
        self.productId = productId;
        self.price = price
    }
    
    var user: Parent<PurchaseProduct, Product> {
        return parent(id: productId)
    }
    
    init(row: Row) throws {
        purchaseId = try row.get(PurchaseProduct.purchaseIdKey)
        productId = try row.get(PurchaseProduct.productIdKey)
        price = try row.get(PurchaseProduct.priceKey)
    }
    
    // Serialize
    func makeRow() throws -> Row {
        var row = Row()
        
        try row.set(PurchaseProduct.purchaseIdKey, purchaseId)
        try row.set(PurchaseProduct.productIdKey, productId)
        try row.set(PurchaseProduct.priceKey, price)
        
        return row
    }
}

// Preparation
extension PurchaseProduct: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.parent(Purchase.self, optional: false, unique: false, foreignIdKey: PurchaseProduct.purchaseIdKey)
            builder.parent(Product.self, optional: false, unique: false, foreignIdKey: PurchaseProduct.productIdKey)
            builder.float(PurchaseProduct.priceKey, precision: 10, digits: 2)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// Json
extension PurchaseProduct: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            purchaseId: json.get(PurchaseProduct.purchaseIdKey),
            productId: json.get(PurchaseProduct.productIdKey),
            price: json.get(PurchaseProduct.priceKey)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        
        try json.set(PurchaseProduct.idKey, id)
        try json.set(PurchaseProduct.purchaseIdKey, purchaseId)
        try json.set(PurchaseProduct.productIdKey, productId)
        try json.set(PurchaseProduct.productKey, product.get())
        try json.set(PurchaseProduct.priceKey, price)

        return json
    }
}

// Http
extension PurchaseProduct: ResponseRepresentable { }

// Update
extension PurchaseProduct: Updateable {
    public static var updateableKeys: [UpdateableKey<PurchaseProduct>] {
        return [
            UpdateableKey(PurchaseProduct.purchaseIdKey, Identifier.self) { purchaseProduct, purchaseId in
                purchaseProduct.purchaseId = purchaseId
            },
            UpdateableKey(PurchaseProduct.productIdKey, Identifier.self) { purchaseProduct, productId in
                purchaseProduct.productId = productId
            },
            UpdateableKey(Product.priceKey, Float.self) { purchaseProduct, price in
                purchaseProduct.price = price
            }
        ]
    }
}
