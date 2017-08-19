import Vapor
import FluentProvider
import HTTP

final class ProductRate: Model {
    static let name = "ProdRate"
    
    let storage = Storage()
    
    // Columns
    var productId: Identifier
    var userId: Identifier
    var rate: Int
    var comment: String
    
    var product: Parent<ProductRate, Product> {
        return parent(id: productId)
    }
    
    // Column names
    static let idKey = "id"
    static let productIdKey = "product_id"
    static let userIdKey = "user_id"
    static let rateKey = "rate"
    static let commentKey = "comment"
    
    // Init
    init(
        productId: Identifier,
        userId: Identifier,
        rate: Int,
        comment: String
        ) {
        self.productId = productId
        self.userId = userId
        self.rate = rate
        self.comment = comment
    }
    
    init(row: Row) throws {
        productId = try row.get(ProductRate.productIdKey)
        userId = try row.get(ProductRate.userIdKey)
        rate = try row.get(ProductRate.rateKey)
        comment = try row.get(ProductRate.commentKey)
    }
    
    // Serialize
    func makeRow() throws -> Row {
        var row = Row()
        
        try row.set(ProductRate.productIdKey, productId)
        try row.set(ProductRate.userIdKey, userId)
        try row.set(ProductRate.rateKey, rate)
        try row.set(ProductRate.commentKey, comment)
        
        return row
    }
}

// Preparation
extension ProductRate: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.parent(Product.self, optional: false, unique: false, foreignIdKey: ProductRate.productIdKey)
            builder.parent(User.self, optional: false, unique: false, foreignIdKey: ProductRate.userIdKey)
            builder.int(ProductRate.rateKey)
            builder.string(ProductRate.commentKey)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// Json
extension ProductRate: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            productId: json.get(ProductRate.productIdKey),
            userId: json.get(ProductRate.userIdKey),
            rate: json.get(ProductRate.rateKey),
            comment: json.get(ProductRate.commentKey)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        
        try json.set(ProductRate.rateKey, rate)
        try json.set(ProductRate.commentKey, comment)
        
        return json
    }
}

// Http
extension ProductRate: ResponseRepresentable { }

// Update
extension ProductRate: Updateable {
    public static var updateableKeys: [UpdateableKey<ProductRate>] {
        return [
            UpdateableKey(ProductRate.productIdKey, Identifier.self) { productRate, productId in
                productRate.productId = productId
            },
            UpdateableKey(ProductRate.userIdKey, Identifier.self) { productRate, userId in
                productRate.userId = userId
            },
            UpdateableKey(ProductRate.rateKey, Int.self) { productRate, rate in
                productRate.rate = rate
            },
            UpdateableKey(ProductRate.commentKey, String.self) { productRate, comment in
                productRate.comment = comment
            }
        ]
    }
}
