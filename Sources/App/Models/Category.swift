import Vapor
import FluentProvider
import HTTP

final class Category: Model {
    static let name = "Cat"
    
    let storage = Storage()
    
    // Columns
    var name: String
    var description: String
    var parentId: Identifier?
    
    var parent: Parent<Category, Category> {
        return parent(id: parentId)
    }
    
    
    func recommendedProducts() throws -> [Product]? {
        return try Product.makeQuery().filter(Product.self, Product.categoryIdKey, id).filter(Product.self, Product.recommendedKey, true).all()
    }
    
    // Column names
    static let idKey = "id"
    static let nameKey = "name"
    static let descriptionKey = "description"
    static let parentIdKey = "parent_id"
    static let productsKey = "products"
    
    // Init
    init(
        name: String,
        description: String,
        parentId: Identifier?
        ) {
        self.name = name
        self.description = description;
        self.parentId = parentId
    }
    
    init(row: Row) throws {
        name = try row.get(Category.nameKey)
        description = try row.get(Category.descriptionKey)
        parentId = try row.get(Category.parentIdKey)
    }
    
    // Serialize
    func makeRow() throws -> Row {
        var row = Row()
        
        try row.set(Category.nameKey, name)
        try row.set(Category.descriptionKey, description)
        try row.set(Category.parentIdKey, parentId)
        
        return row
    }
}

// Preparation
extension Category: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Category.nameKey)
            builder.string(Category.descriptionKey)
            builder.parent(Category.self, optional: true, unique: false, foreignIdKey: Category.parentIdKey)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// Json
extension Category: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            name: json.get(Category.nameKey),
            description: json.get(Category.descriptionKey),
            parentId: json.get(Category.parentIdKey)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        
        try json.set(Category.idKey, id)
        try json.set(Category.nameKey, name)
        try json.set(Category.descriptionKey, description)
        try json.set(Category.parentIdKey, parentId)
        
        return json
    }
    
    func makeJSONWithProducts() throws -> JSON {
        var json = JSON()
        
        try json.set(Category.idKey, id)
        try json.set(Category.nameKey, name)
        try json.set(Category.descriptionKey, description)
        try json.set(Category.parentIdKey, parentId)
        try json.set(Category.productsKey, recommendedProducts()?.makeJSON())
        
        return json
    }
}

// Http
extension Category: ResponseRepresentable { }

// Update
extension Category: Updateable {
    public static var updateableKeys: [UpdateableKey<Category>] {
        return [
            UpdateableKey(Category.nameKey, String.self) { Category, name in
                Category.name = name
            },
            UpdateableKey(Category.descriptionKey, String.self) { Category, description in
                Category.description = description
            },
            UpdateableKey(Category.parentIdKey, Identifier.self) { Category, parentId in
                Category.parentId = parentId
            }
        ]
    }
}
