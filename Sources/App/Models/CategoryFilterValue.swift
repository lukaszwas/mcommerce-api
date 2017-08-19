import Vapor
import FluentProvider
import HTTP

final class CategoryFilterValue: Model {
    static let name = "CatFilVal"
    
    let storage = Storage()
    
    // Columns
    var categoryFilterId: Identifier
    var value: String
    
    var categoryFilter: Parent<CategoryFilterValue, CategoryFilter> {
        return parent(id: categoryFilterId)
    }
    
    // Column names
    static let idKey = "id"
    static let categoryFilterIdKey = "category_filter_id"
    static let valueKey = "value"
    static let categoryFilterKey = "category_filter"
    
    // Init
    init(
        categoryFilterId: Identifier,
        value: String
        ) {
        self.categoryFilterId = categoryFilterId
        self.value = value
    }
    
    init(row: Row) throws {
        categoryFilterId = try row.get(CategoryFilterValue.categoryFilterIdKey)
        value = try row.get(CategoryFilterValue.valueKey)
    }
    
    // Serialize
    func makeRow() throws -> Row {
        var row = Row()
        
        try row.set(CategoryFilterValue.categoryFilterIdKey, categoryFilterId)
        try row.set(CategoryFilterValue.valueKey, value)
        
        return row
    }
}

// Preparation
extension CategoryFilterValue: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.parent(CategoryFilter.self, optional: true, unique: false, foreignIdKey: CategoryFilterValue.categoryFilterIdKey)
            builder.string(CategoryFilterValue.valueKey)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// Json
extension CategoryFilterValue: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            categoryFilterId: json.get(CategoryFilterValue.categoryFilterIdKey),
            value: json.get(CategoryFilterValue.valueKey)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        
        try json.set(CategoryFilterValue.idKey, id)
        try json.set(CategoryFilterValue.categoryFilterIdKey, categoryFilterId)
        try json.set(CategoryFilterValue.valueKey, value)
        
        return json
    }
}

// Http
extension CategoryFilterValue: ResponseRepresentable { }

// Update
extension CategoryFilterValue: Updateable {
    public static var updateableKeys: [UpdateableKey<CategoryFilterValue>] {
        return [
            UpdateableKey(CategoryFilterValue.categoryFilterIdKey, Identifier.self) { categoryFilterValue, categoryFilterId in
                categoryFilterValue.categoryFilterId = categoryFilterId
            },
            UpdateableKey(CategoryFilterValue.valueKey, String.self) { categoryFilterValue, value in
                categoryFilterValue.value = value
            }
        ]
    }
}
