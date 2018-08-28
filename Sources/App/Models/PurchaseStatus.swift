import Vapor
import FluentProvider
import HTTP

final class PurchaseStatus: Model {
    static let name = "PurchStat"
    
    let storage = Storage()
    
    // Columns
    var name: String
    
    // Column names
    static let idKey = "id"
    static let nameKey = "name"
    
    // Init
    init(
        name: String
        ) {
        self.name = name
    }
    
    init(row: Row) throws {
        name = try row.get(Product.nameKey)
    }
    
    // Serialize
    func makeRow() throws -> Row {
        var row = Row()
        
        try row.set(Product.nameKey, name)
        
        return row
    }
}

// Preparation
extension PurchaseStatus: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Product.nameKey)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// Json
extension PurchaseStatus: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            name: json.get(PurchaseStatus.nameKey)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        
        try json.set(PurchaseStatus.idKey, id)
        try json.set(PurchaseStatus.nameKey, name)
        
        return json
    }
    
    func makeJSONWithDetails() throws -> JSON {
        var json = JSON()
        
        try json.set(PurchaseStatus.idKey, id)
        try json.set(PurchaseStatus.nameKey, name)
        
        return json
    }
}

// Http
extension PurchaseStatus: ResponseRepresentable { }

// Update
extension PurchaseStatus: Updateable {
    public static var updateableKeys: [UpdateableKey<PurchaseStatus>] {
        return [
            UpdateableKey(PurchaseStatus.nameKey, String.self) { purchaseStatus, name in
                purchaseStatus.name = name
            }
        ]
    }
}
