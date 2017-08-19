import Vapor
import FluentProvider
import HTTP

final class Product: Model {
    static let name = "Prod"
    
    let storage = Storage()
    
    // Columns
    var name: String
    var description: String
    var price: Float
    var thumbnailUrl: String
    var categoryId: Identifier
    var recommended: Bool
    
    var category: Parent<Product, Category> {
        return parent(id: categoryId)
    }
    
    var filterValues: Children<Product, ProductCategoryFilterValue> {
        return children(foreignIdKey: ProductCategoryFilterValue.productIdKey)
    }
    
    var images: Children<Product, ProductImage> {
        return children(foreignIdKey: ProductImage.productIdKey)
    }
    
    var rates: Children<Product, ProductRate> {
        return children(foreignIdKey: ProductRate.productIdKey)
    }
    
    // Column names
    static let idKey = "id"
    static let nameKey = "name"
    static let descriptionKey = "description"
    static let priceKey = "price"
    static let thumbnailUrlKey = "thumbnail_url"
    static let categoryIdKey = "category_id"
    static let categoryKey = "category"
    static let filterValuesKey = "filter_values"
    static let imagesKey = "images"
    static let ratesKey = "rates"
    static let recommendedKey = "recommended"

    // Init
    init(
        name: String,
        description: String,
        price: Float,
        thumbnailUrl: String,
        categoryId: Identifier,
        recommended: Bool
        ) {
        self.name = name
        self.description = description;
        self.price = price
        self.thumbnailUrl = thumbnailUrl
        self.categoryId = categoryId
        self.recommended = recommended
    }

    init(row: Row) throws {
        name = try row.get(Product.nameKey)
        description = try row.get(Product.descriptionKey)
        price = try row.get(Product.priceKey)
        thumbnailUrl = try row.get(Product.thumbnailUrlKey)
        categoryId = try row.get(Product.categoryIdKey)
        recommended = try row.get(Product.recommendedKey)
    }

    // Serialize
    func makeRow() throws -> Row {
        var row = Row()
        
        try row.set(Product.nameKey, name)
        try row.set(Product.descriptionKey, description)
        try row.set(Product.priceKey, price)
        try row.set(Product.thumbnailUrlKey, thumbnailUrl)
        try row.set(Product.categoryIdKey, categoryId)
        try row.set(Product.recommendedKey, recommended)
        
        return row
    }
}

// Preparation
extension Product: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Product.nameKey)
            builder.string(Product.descriptionKey, length: 1500)
            builder.float(Product.priceKey, precision: 10, digits: 2)
            builder.string(Product.thumbnailUrlKey)
            builder.parent(Category.self, optional: false, unique: false, foreignIdKey: Product.categoryIdKey)
            builder.bool(Product.recommendedKey)
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// Json
extension Product: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            name: json.get(Product.nameKey),
            description: json.get(Product.descriptionKey),
            price: json.get(Product.priceKey),
            thumbnailUrl: json.get(Product.thumbnailUrlKey),
            categoryId: json.get(Product.categoryIdKey),
            recommended: json.get(Product.recommendedKey)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        
        try json.set(Product.idKey, id)
        try json.set(Product.nameKey, name)
        try json.set(Product.descriptionKey, description)
        try json.set(Product.priceKey, price)
        try json.set(Product.thumbnailUrlKey, thumbnailUrl)
        try json.set(Product.categoryIdKey, categoryId)
        try json.set(Product.recommendedKey, recommended)
            
        return json
    }
    
    func makeJSONWithDetails() throws -> JSON {
        var json = JSON()
        
        try json.set(Product.idKey, id)
        try json.set(Product.nameKey, name)
        try json.set(Product.descriptionKey, description)
        try json.set(Product.priceKey, price)
        try json.set(Product.thumbnailUrlKey, thumbnailUrl)
        try json.set(Product.categoryIdKey, categoryId)
        try json.set(Product.categoryKey, category.get())
        try json.set(Product.filterValuesKey, filterValues.all().makeJSON())
        try json.set(Product.imagesKey, images.all().makeJSON())
        try json.set(Product.ratesKey, rates.all().makeJSON())
        try json.set(Product.recommendedKey, recommended)
        
        return json
    }
}

// Http
extension Product: ResponseRepresentable { }

// Update
extension Product: Updateable {
    public static var updateableKeys: [UpdateableKey<Product>] {
        return [
            UpdateableKey(Product.nameKey, String.self) { product, name in
                product.name = name
            },
            UpdateableKey(Product.descriptionKey, String.self) { product, description in
                product.description = description
            },
            UpdateableKey(Product.priceKey, Float.self) { product, price in
                product.price = price
            },
            UpdateableKey(Product.thumbnailUrlKey, String.self) { product, thumbnailUrl in
                product.thumbnailUrl = thumbnailUrl
            },
            UpdateableKey(Product.categoryIdKey, Identifier.self) { product, categoryId in
                product.categoryId = categoryId
            },
            UpdateableKey(Product.recommendedKey, Bool.self) { product, recommended in
                product.recommended = recommended
            }
        ]
    }
}
