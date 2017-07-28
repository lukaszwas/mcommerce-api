import Vapor

final class Credentials {
    // Columns
    var email: String
    var password: String

    // Column names
    static let emailKey = "email"
    static let passwordKey = "password"
    
    // Init
    init(
        email: String,
        password: String
        ) {
        self.email = email
        self.password = password
    }
}

// Json
extension Credentials: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            email: json.get(Credentials.emailKey),
            password: json.get(Credentials.passwordKey)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        
        try json.set(Credentials.emailKey, email)
        try json.set(Credentials.passwordKey, password)
        
        return json
    }
}
