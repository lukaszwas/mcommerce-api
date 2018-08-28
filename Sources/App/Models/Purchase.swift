import Vapor
import FluentProvider
import HTTP

final class Purchase: Model {
    static let name = "Purch"
    
    let storage = Storage()
    
    // Columns
    var userId: Identifier
    var statusId: Identifier
    var firstName: String
    var lastName: String
    var address1: String
    var address2: String
    var zipCode: String
    var city: String
    
    var user: Parent<Purchase, User> {
        return parent(id: userId)
    }
    
    var status: Parent<Purchase, PurchaseStatus> {
        return parent(id: statusId)
    }
    
    var products: Children<Purchase, PurchaseProduct> {
        return children(foreignIdKey: PurchaseProduct.purchaseIdKey)
    }
    
    // Column names
    static let idKey = "id"
    static let userIdKey = "user_id"
    static let statusIdKey = "statusId"
    static let statusKey = "status"
    static let firstNameKey = "first_name"
    static let lastNameKey = "last_name"
    static let address1Key = "address1"
    static let address2Key = "address2"
    static let zipCodeKey = "zip_code"
    static let cityKey = "city"
    
    // Init
    init(
        userId: Identifier,
        statusId: Identifier,
        firstName: String,
        lastName: String,
        address1: String,
        address2: String,
        zipCode: String,
        city: String
        ) {
        self.userId = userId
        self.statusId = statusId;
        self.firstName = firstName
        self.lastName = lastName
        self.address1 = address1
        self.address2 = address2
        self.zipCode = zipCode
        self.city = city
    }
    
    init(row: Row) throws {
        userId = try row.get(Purchase.userIdKey)
        statusId = try row.get(Purchase.statusIdKey)
        firstName = try row.get(Purchase.firstNameKey)
        lastName = try row.get(Purchase.lastNameKey)
        address1 = try row.get(Purchase.address1Key)
        address2 = try row.get(Purchase.address2Key)
        zipCode = try row.get(Purchase.zipCodeKey)
        city = try row.get(Purchase.cityKey)
    }
    
    // Serialize
    func makeRow() throws -> Row {
        var row = Row()
        
        try row.set(Purchase.userIdKey, userId)
        try row.set(Purchase.statusIdKey, statusId)
        try row.set(Purchase.firstNameKey, firstName)
        try row.set(Purchase.lastNameKey, lastName)
        try row.set(Purchase.address1Key, address1)
        try row.set(Purchase.address2Key, address2)
        try row.set(Purchase.zipCodeKey, zipCode)
        try row.set(Purchase.cityKey, city)

        return row
    }
}

// Preparation
extension Purchase: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.parent(User.self, optional: false, unique: false, foreignIdKey: Purchase.userIdKey)
            builder.parent(PurchaseStatus.self, optional: false, unique: false, foreignIdKey: Purchase.statusIdKey)
            builder.string(Purchase.firstNameKey)
            builder.string(Purchase.lastNameKey)
            builder.string(Purchase.address1Key)
            builder.string(Purchase.address2Key)
            builder.string(Purchase.zipCodeKey)
            builder.string(Purchase.cityKey)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// Json
extension Purchase: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            userId: json.get(Purchase.userIdKey),
            statusId: json.get(Purchase.statusIdKey),
            firstName: json.get(Purchase.firstNameKey),
            lastName: json.get(Purchase.lastNameKey),
            address1: json.get(Purchase.address1Key),
            address2: json.get(Purchase.address2Key),
            zipCode: json.get(Purchase.zipCodeKey),
            city: json.get(Purchase.cityKey)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        
        try json.set(Purchase.idKey, id)
        try json.set(Purchase.userIdKey, userId)
        try json.set(Purchase.statusIdKey, statusId)
        try json.set(Purchase.statusKey, status.get())
        try json.set(Purchase.firstNameKey, firstName)
        try json.set(Purchase.lastNameKey, lastName)
        try json.set(Purchase.address1Key, address1)
        try json.set(Purchase.address2Key, address2)
        try json.set(Purchase.zipCodeKey, zipCode)
        try json.set(Purchase.cityKey, city)

        return json
    }
}

// Http
extension Purchase: ResponseRepresentable { }

// Update
extension Purchase: Updateable {
    public static var updateableKeys: [UpdateableKey<Purchase>] {
        return [
            UpdateableKey(Purchase.userIdKey, Identifier.self) { purchase, userId in
                purchase.userId = userId
            },
            UpdateableKey(Purchase.statusIdKey, Identifier.self) { purchase, statusId in
                purchase.statusId = statusId
            },
            UpdateableKey(Purchase.firstNameKey, String.self) { purchase, firstName in
                purchase.firstName = firstName
            },
            UpdateableKey(Purchase.lastNameKey, String.self) { purchase, lastName in
                purchase.lastName = lastName
            },
            UpdateableKey(Purchase.address1Key, String.self) { purchase, address1 in
                purchase.address1 = address1
            },
            UpdateableKey(Purchase.address2Key, String.self) { purchase, address2 in
                purchase.address2 = address2
            },
            UpdateableKey(Purchase.zipCodeKey, String.self) { purchase, zipCode in
                purchase.zipCode = zipCode
            },
            UpdateableKey(Purchase.cityKey, String.self) { purchase, city in
                purchase.city = city
            }
        ]
    }
}
