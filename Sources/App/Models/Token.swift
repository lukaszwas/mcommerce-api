import Vapor
import FluentProvider
import HTTP

final class Token: Model {
    let storage = Storage()
    
    // Columns
    var token: String
    var userId: Identifier
    
    var user: Parent<Token, User> {
        return parent(id: userId)
    }
    
    // Column names
    static let idKey = "id"
    static let tokenKey = "token"
    static let userIdKey = "user_id"
    
    // Init
    init(
        token: String,
        userId: Identifier
        ) {
        self.token = token
        self.userId = userId
        
    }
    
    init(row: Row) throws {
        token = try row.get(Token.tokenKey)
        userId = try row.get(Token.userIdKey)
    }
    
    // Serialize
    func makeRow() throws -> Row {
        var row = Row()
        
        try row.set(Token.tokenKey, token)
        try row.set(Token.userIdKey, userId)
        
        return row
    }
}

// Preparation
extension Token: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Token.tokenKey)
            builder.string(Token.userIdKey)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
