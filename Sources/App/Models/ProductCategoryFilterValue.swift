import Vapor
import FluentProvider
import HTTP

final class ProductCategoryFilterValue: Model {
    static let name = "ProdCatFilVal"
    
    let storage = Storage()
    
    // Columns
    var productId: Identifier
    var valueId: Identifier
    
    var product: Parent<ProductCategoryFilterValue, Product> {
        return parent(id: productId)
    }
    
    var value: Parent<ProductCategoryFilterValue, CategoryFilterValue> {
        return parent(id: valueId)
    }
    
    // Column names
    static let idKey = "id"
    static let productIdKey = "product_id"
    static let valueIdKey = "value_id"
    static let valueKey = "value"
    static let valueNameKey = "name"
    
    // Init
    init(
        productId: Identifier,
        valueId: Identifier
        ) {
        self.productId = productId
        self.valueId = valueId
    }
    
    init(row: Row) throws {
        productId = try row.get(ProductCategoryFilterValue.productIdKey)
        valueId = try row.get(ProductCategoryFilterValue.valueIdKey)
    }
    
    // Serialize
    func makeRow() throws -> Row {
        var row = Row()
        
        try row.set(ProductCategoryFilterValue.productIdKey, productId)
        try row.set(ProductCategoryFilterValue.valueIdKey, valueId)
        
        return row
    }
}

// Preparation
extension ProductCategoryFilterValue: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.parent(Product.self, optional: false, unique: false, foreignIdKey: ProductCategoryFilterValue.productIdKey)
            builder.parent(CategoryFilterValue.self, optional: false, unique: false, foreignIdKey: ProductCategoryFilterValue.valueIdKey)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// Json
extension ProductCategoryFilterValue: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            productId: json.get(ProductCategoryFilterValue.productIdKey),
            valueId: json.get(ProductCategoryFilterValue.valueIdKey)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        
        try json.set(ProductCategoryFilterValue.valueNameKey, value.get()?.categoryFilter.get()?.name)
        try json.set(ProductCategoryFilterValue.valueKey, value.get()?.value)
        
        return json
    }
}

// Http
extension ProductCategoryFilterValue: ResponseRepresentable { }

// Update
extension ProductCategoryFilterValue: Updateable {
    public static var updateableKeys: [UpdateableKey<ProductCategoryFilterValue>] {
        return [
            UpdateableKey(ProductCategoryFilterValue.productIdKey, Identifier.self) { productCategoryFilterValue, productId in
                productCategoryFilterValue.productId = productId
            },
            UpdateableKey(ProductCategoryFilterValue.valueIdKey, Identifier.self) { productCategoryFilterValue, valueId in
                productCategoryFilterValue.valueId = valueId
            }
        ]
    }
}
