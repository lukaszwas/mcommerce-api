import Vapor
import FluentProvider
import HTTP
import AuthProvider
import BCrypt

final class User: Model {
    let storage = Storage()
    
    // Columns
    var email: String
    var password: String
    var firstName: String
    var lastName: String
    var apiAccess: Bool
    var isAdmin: Bool
    
    // Column names
    static let idKey = "id"
    static let emailKey = "email"
    static let passwordKey = "password"
    static let firstNameKey = "firstName"
    static let lastNameKey = "lastName"
    static let apiAccessKey = "apiAccess"
    static let isAdminKey = "isAdmin"
    
    // Init
    init(
        email: String,
        password: String,
        firstName: String,
        lastName: String,
        apiAccess: Bool,
        isAdmin: Bool
        ) {
        self.email = email
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.apiAccess = apiAccess
        self.isAdmin = isAdmin
    }
    
    init(row: Row) throws {
        email = try row.get(User.emailKey)
        password = try row.get(User.passwordKey)
        firstName = try row.get(User.firstNameKey)
        lastName = try row.get(User.lastNameKey)
        apiAccess = try row.get(User.apiAccessKey)
        isAdmin = try row.get(User.isAdminKey)
    }
    
    // Serialize
    func makeRow() throws -> Row {
        var row = Row()
        
        try row.set(User.emailKey, email)
        try row.set(User.passwordKey, password)
        try row.set(User.firstNameKey, firstName)
        try row.set(User.lastNameKey, lastName)
        try row.set(User.apiAccessKey, apiAccess)
        try row.set(User.isAdminKey, isAdmin)
        
        return row
    }
}

// Preparation
extension User: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(User.emailKey)
            builder.string(User.passwordKey)
            builder.string(User.firstNameKey)
            builder.string(User.lastNameKey)
            builder.string(User.apiAccessKey)
            builder.string(User.isAdminKey)
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
            email: json.get(User.emailKey),
            password: json.get(User.passwordKey),
            firstName: json.get(User.firstNameKey),
            lastName: json.get(User.lastNameKey),
            apiAccess: json.get(User.apiAccessKey),
            isAdmin: json.get(User.isAdminKey)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        
        try json.set(User.idKey, id)
        try json.set(User.emailKey, email)
        try json.set(User.firstNameKey, firstName)
        try json.set(User.lastNameKey, lastName)
        
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
            },
            UpdateableKey(User.passwordKey, String.self) { user, password in
                user.password = password
            },
            UpdateableKey(User.firstNameKey, String.self) { user, firstName in
                user.firstName = firstName
            },
            UpdateableKey(User.lastNameKey, String.self) { user, lastName in
                user.lastName = lastName
            },
            UpdateableKey(User.apiAccessKey, Bool.self) { user, apiAccess in
                user.apiAccess = apiAccess
            },
            UpdateableKey(User.isAdminKey, Bool.self) { user, isAdmin in
                user.isAdmin = isAdmin
            }
        ]
    }
}

// User token
extension User: TokenAuthenticatable {
    public typealias TokenType = Token
}
