import Vapor
import FluentProvider
import HTTP
import AuthProvider

final class User: Model {
    let storage = Storage()
    
    // Columns
    var email: String
    
    // Column names
    static let idKey = "id"
    static let emailKey = "email"
    
    // Init
    init(
        email: String
        ) {
        self.email = email
        
    }
    
    init(row: Row) throws {
        email = try row.get(User.emailKey)
    }
    
    // Serialize
    func makeRow() throws -> Row {
        var row = Row()
        
        try row.set(User.emailKey, email)
        
        return row
    }
}

// Preparation
extension User: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(User.emailKey)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// Json
extension User: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            email: json.get(User.emailKey)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        
        try json.set(User.idKey, id)
        try json.set(User.emailKey, email)
        
        return json
    }
}

// Http
extension User: ResponseRepresentable { }

// Update
extension User: Updateable {
    public static var updateableKeys: [UpdateableKey<User>] {
        return [
            UpdateableKey(User.emailKey, String.self) { user, email in
                user.email = email
            }
        ]
    }
}

// User token
extension User: TokenAuthenticatable {
    public typealias TokenType = Token
}
