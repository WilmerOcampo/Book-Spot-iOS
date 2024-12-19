//
//  Category.swift
//  Book Spot iOS
//
//  Created by Wilmer Ocampo on 18/12/24.
//


struct Category {
    var name: String
    var description: String
    
    init(name: String, description: String) {
        self.name = name
        self.description = description
    }
    
    // Inicializador a partir de un diccionario (Firebase)
    init?(dict: [String: Any]) {
        guard let name = dict["name"] as? String,
              let description = dict["description"] as? String else {
            return nil
        }
        
        self.name = name
        self.description = description
    }
}