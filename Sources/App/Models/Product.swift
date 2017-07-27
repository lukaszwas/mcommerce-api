import Vapor
import FluentProvider
import HTTP

final class Product: Model {
    let storage = Storage()
    
    // Columns
    var name: String
    var description: String
    
    // Column names
    static let idKey = "id"
    static let nameKey = "name"
    static let descriptionKey = "description"

    // Init
    init(
        name: String,
        description: String
        ) {
        self.name = name
        self.description = description;
        
    }

    init(row: Row) throws {
        name = try row.get(Product.nameKey)
        description = try row.get(Product.descriptionKey)
    }

    // Serialize
    func makeRow() throws -> Row {
        var row = Row()
        
        try row.set(Product.nameKey, name)
        try row.set(Product.descriptionKey, description)
        
        return row
    }
}

// Preparation
extension Product: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Product.nameKey)
            builder.string(Product.descriptionKey)
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
            description: json.get(Product.descriptionKey)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        
        try json.set(Product.idKey, id)
        try json.set(Product.nameKey, name)
        try json.set(Product.descriptionKey, description)
        
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
            }
        ]
    }
}
