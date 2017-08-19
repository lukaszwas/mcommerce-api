import Vapor
import FluentProvider
import HTTP

final class ProductImage: Model {
    static let name = "ProdImage"
    
    let storage = Storage()
    
    // Columns
    var productId: Identifier
    var imageUrl: String
    
    var product: Parent<ProductImage, Product> {
        return parent(id: productId)
    }
    
    // Column names
    static let idKey = "id"
    static let productIdKey = "product_id"
    static let imageUrlKey = "image_url"
    
    // Init
    init(
        productId: Identifier,
        imageUrl: String
        ) {
        self.productId = productId
        self.imageUrl = imageUrl
    }
    
    init(row: Row) throws {
        productId = try row.get(ProductImage.productIdKey)
        imageUrl = try row.get(ProductImage.imageUrlKey)
    }
    
    // Serialize
    func makeRow() throws -> Row {
        var row = Row()
        
        try row.set(ProductImage.productIdKey, productId)
        try row.set(ProductImage.imageUrlKey, imageUrl)
        
        return row
    }
}

// Preparation
extension ProductImage: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.parent(Product.self, optional: false, unique: false, foreignIdKey: ProductImage.productIdKey)
            builder.string(ProductImage.imageUrlKey)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// Json
extension ProductImage: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            productId: json.get(ProductImage.productIdKey),
            imageUrl: json.get(ProductImage.imageUrlKey)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        
        try json.set(ProductImage.imageUrlKey, imageUrl)
        
        return json
    }
}

// Http
extension ProductImage: ResponseRepresentable { }

// Update
extension ProductImage: Updateable {
    public static var updateableKeys: [UpdateableKey<ProductImage>] {
        return [
            UpdateableKey(ProductImage.productIdKey, Identifier.self) { productImage, productId in
                productImage.productId = productId
            },
            UpdateableKey(ProductImage.imageUrlKey, String.self) { productImage, imageUrl in
                productImage.imageUrl = imageUrl
            }
        ]
    }
}
