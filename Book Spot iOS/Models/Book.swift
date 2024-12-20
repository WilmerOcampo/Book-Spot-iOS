//
//  Book.swift
//  Book Spot iOS
//
//  Created by Wilmer Ocampo on 18/12/24.
//


struct Book {
    var uid: String
    var author: String
    var category: String
    var description: String
    var image: String
    var pages: Int
    var publicationDate: String
    var status: Bool
    var stock: Int
    var title: String
    
    // Inicializador para crear un libro a partir de los datos de Firebase
    init?(dict: [String: Any], uid: String) {
        guard let author = dict["author"] as? String,
              let category = dict["category"] as? String,
              let description = dict["description"] as? String,
              let image = dict["image"] as? String,
              let pages = dict["pages"] as? Int,
              let publicationDate = dict["publicationDate"] as? String,
              let status = dict["status"] as? Bool,
              let stock = dict["stock"] as? Int,
              let title = dict["title"] as? String else {
            return nil
        }
        
        self.uid = uid
        self.author = author
        self.category = category
        self.description = description
        self.image = image
        self.pages = pages
        self.publicationDate = publicationDate
        self.status = status
        self.stock = stock
        self.title = title
    }
}
