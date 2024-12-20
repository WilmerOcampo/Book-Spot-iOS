//
//  Reservation.swift
//  Book Spot iOS
//
//  Created by Wilmer Ocampo on 18/12/24.
//

struct Reservation {
    var uid: String
    var bookID: String
    var userID: String
    var reservationDate: String
    var status: String

    init(bookID: String, userID: String, reservationDate: String, status: String) {
        self.uid = ""
        self.bookID = bookID
        self.userID = userID
        self.reservationDate = reservationDate
        self.status = status
    }

    // Inicializador a partir de un diccionario (Firebase)
    init?(dict: [String: Any], uid: String) {
        guard let bookID = dict["bookID"] as? String,
              let userID = dict["userID"] as? String,
              let reservationDate = dict["reservationDate"] as? String,
              let status = dict["status"] as? String else {
            return nil
        }

        self.uid = uid
        self.bookID = bookID
        self.userID = userID
        self.reservationDate = reservationDate
        self.status = status
    }
}
