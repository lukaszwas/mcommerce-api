import Vapor

final class Payment {
    // Columns
    var cardNumber: String
    var cardExpirationMonth: String
    var cardExpirationYear: String
    var cardExpirationCvc: String
    
    // Column names
    static let cardNumberKey = "card_number"
    static let cardExpirationMonthKey = "card_expiration_month"
    static let cardExpirationYearKey = "card_expiration_year"
    static let cardExpirationCvcKey = "card_cvc"
    
    // Init
    init(
        cardNumber: String,
        cardExpirationMonth: String,
        cardExpirationYear: String,
        cardExpirationCvc: String
        ) {
        self.cardNumber = cardNumber
        self.cardExpirationMonth = cardExpirationMonth
        self.cardExpirationYear = cardExpirationYear
        self.cardExpirationCvc = cardExpirationCvc
    }
}

// Json
extension Payment: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            cardNumber: json.get(Payment.cardNumberKey),
            cardExpirationMonth: json.get(Payment.cardExpirationMonthKey),
            cardExpirationYear: json.get(Payment.cardExpirationYearKey),
            cardExpirationCvc: json.get(Payment.cardExpirationCvcKey)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        
        try json.set(Payment.cardNumberKey, cardNumber)
        try json.set(Payment.cardExpirationMonthKey, cardExpirationMonth)
        try json.set(Payment.cardExpirationYearKey, cardExpirationYear)
        try json.set(Payment.cardExpirationCvcKey, cardExpirationCvc)
        
        return json
    }
}
