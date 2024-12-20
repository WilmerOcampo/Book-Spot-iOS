//
//  User.swift
//  Book Spot iOS
//
//  Created by Wilmer Ocampo on 17/12/24.
//


struct User {
    var name: String
    var lastname: String
    var dni: String
    var number: String
    
    // Inicializador para crear un User desde los datos del formulario
    init(name: String, lastname: String, dni: String, number: String) {
        self.name = name
        self.lastname = lastname
        self.dni = dni
        self.number = number
    }
    
    // Método que convierte el objeto User en un diccionario para poder guardarlo en Firebase
    func toDictionary() -> [String: Any] {
        return [
            "name": self.name,
            "lastname": self.lastname,
            "dni": self.dni,
            "number": self.number
        ]
    }
}
