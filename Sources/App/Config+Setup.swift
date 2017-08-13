import FluentProvider
import MySQLProvider
import AuthProvider

extension Config {
    public func setup() throws {
        Node.fuzzy = [Row.self, JSON.self, Node.self]

        try setupProviders()
        try setupPreparations()
    }
    
    // Setup providers
    private func setupProviders() throws {
        try addProvider(FluentProvider.Provider.self)
        try addProvider(MySQLProvider.Provider.self)
        try addProvider(AuthProvider.Provider.self)
    }
    
    // Setup preparations
    private func setupPreparations() throws {
        // Auth
        preparations.append(User.self)
        preparations.append(Token.self)
        
        // Content
        preparations.append(Product.self)
        preparations.append(Category.self)
    }
}
