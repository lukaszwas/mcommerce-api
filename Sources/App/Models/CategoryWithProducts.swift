import Vapor
import FluentProvider
import HTTP

final class CategoryWithProducts: Model {
    static let name = "Cat"
    
    let storage = Storage()
    
    // Columns
    var name: String
    var description: String
    var parentId: Identifier?
    
    var parent: Parent<CategoryWithProducts, Category> {
        return parent(id: parentId)
    }
    
    var products: Children<CategoryWithProducts, Product> {
        return children(foreignIdKey: Product.categoryIdKey)
    }
    
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

// Json
extension CategoryWithProducts: JSONConvertible {
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
        try json.set("test", "test")
        
        return json
    }
}
