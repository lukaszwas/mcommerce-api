import Vapor
import FluentProvider
import HTTP

final class CategoryFilter: Model {
    static let name = "CatFil"
    
    let storage = Storage()
    
    // Columns
    var categoryId: Identifier
    var name: String
    var description: String
    
    var categoryFilterValues: Children<CategoryFilter, CategoryFilterValue> {
        return children(foreignIdKey: CategoryFilterValue.categoryFilterIdKey)
    }
    
    // Column names
    static let idKey = "id"
    static let categoryIdKey = "category_id"
    static let nameKey = "name"
    static let descriptionKey = "description"
    static let valuesKey = "values"
    
    // Init
    init(
        categoryId: Identifier,
        name: String,
        description: String
        ) {
        self.categoryId = categoryId
        self.name = name
        self.description = description
    }
    
    init(row: Row) throws {
        categoryId = try row.get(CategoryFilter.categoryIdKey)
        name = try row.get(CategoryFilter.nameKey)
        description = try row.get(CategoryFilter.descriptionKey)
    }
    
    // Serialize
    func makeRow() throws -> Row {
        var row = Row()
        
        try row.set(CategoryFilter.categoryIdKey, categoryId)
        try row.set(CategoryFilter.nameKey, name)
        try row.set(CategoryFilter.descriptionKey, description)
        
        return row
    }
}

// Preparation
extension CategoryFilter: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.parent(Category.self, optional: true, unique: false, foreignIdKey: CategoryFilter.categoryIdKey)
            builder.string(CategoryFilter.nameKey)
            builder.string(CategoryFilter.descriptionKey)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// Json
extension CategoryFilter: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            categoryId: json.get(CategoryFilter.categoryIdKey),
            name: json.get(CategoryFilter.nameKey),
            description: json.get(CategoryFilter.descriptionKey)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        
        try json.set(CategoryFilter.idKey, id)
        try json.set(CategoryFilter.categoryIdKey, categoryId)
        try json.set(CategoryFilter.nameKey, name)
        try json.set(CategoryFilter.descriptionKey, description)
        try json.set(CategoryFilter.valuesKey, categoryFilterValues.all().makeJSON())
        
        return json
    }
}

// Http
extension CategoryFilter: ResponseRepresentable { }

// Update
extension CategoryFilter: Updateable {
    public static var updateableKeys: [UpdateableKey<CategoryFilter>] {
        return [
            UpdateableKey(CategoryFilter.nameKey, String.self) { categoryFilter, name in
                categoryFilter.name = name
            },
            UpdateableKey(CategoryFilter.descriptionKey, String.self) { categoryFilter, description in
                categoryFilter.description = description
            },
            UpdateableKey(CategoryFilter.categoryIdKey, Identifier.self) { categoryFilter, categoryId in
                categoryFilter.categoryId = categoryId
            }
        ]
    }
}
