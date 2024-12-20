//
//  ReservationViewController.swift
//  Book Spot iOS
//
//  Created by Wilmer Ocampo on 17/12/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SDWebImage

struct SimpleBook {
    var title: String
    var image: String
}

class ReservationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var reservationsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var reservations: [Reservation] = []
    var books: [String: SimpleBook] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reservationsTableView.dataSource = self
        reservationsTableView.delegate = self
        self.findAllReservations()
        
        if Auth.auth().currentUser == nil {
            AlertManager.showAuthenticationAlert(on: self, message: "Necesitas iniciar sesión para ver tus préstamos", loginAction: {
                NavigationManager.goToLogin(from: self)
            }, cancelAction: {
                NavigationManager.goToHome(from: self)
            })
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reservations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reservationCell", for: indexPath) as! ReservationTableViewCell
        
        let reservation = reservations[indexPath.row]
        let bookID = reservation.bookID
        
        cell.dateLabel.text = reservation.reservationDate
        cell.statusLabel.text = reservation.status
        
        if let book = books[bookID] {
            cell.titleBookLabel.text = book.title
            cell.imageBookView.sd_setImage(with: URL(string: book.image), placeholderImage: UIImage(named: "placeholder"))
        } else {
            cell.titleBookLabel.text = "Cargando título..."
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let reservation = reservations[indexPath.row]
        let cancelAction = UIContextualAction(style: .destructive, title: "Cancelar") { _, _, completionHandler in
            self.showCancelConfirmation(forReservation: reservation) { shouldCancel in
                if shouldCancel {
                    self.cancelReservation(reservationID: reservation.bookID)
                }
            }
            completionHandler(true)
        }
        cancelAction.backgroundColor = .red
        let swipeActions = UISwipeActionsConfiguration(actions: [cancelAction])
        return swipeActions
    }
}

extension ReservationViewController {
    func findAllReservations() {
        guard let userID = UserManager.getCurrentUserID() else {
            print("Usuario no autenticado")
            return
        }
        
        let ref = Database.database().reference().child("reservations")
        
        ref.observeSingleEvent(of: .value) { snapshot in
            if !snapshot.exists() {
                print("No se encontraron reservas.")
                return
            }
            
            var userReservations: [Reservation] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let reservationDict = snapshot.value as? [String: Any] {
                    if let reservationUserID = reservationDict["userID"] as? String, reservationUserID == userID {
                        if let reservation = Reservation(dict: reservationDict) {
                            userReservations.append(reservation)
                        }
                    }
                }
            }
            self.reservations = userReservations
            self.loadBookDetails()
            self.reservationsTableView.reloadData()
        }
        self.reservationsTableView.reloadData()
    }
    
    func loadBookDetails() {
        var bookIDs: [String] = []
        for reservation in reservations {
            bookIDs.append(reservation.bookID)
        }
        let ref = Database.database().reference().child("books")
        ref.observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let bookDict = snapshot.value as? [String: Any],
                   let bookID = snapshot.key as? String,
                   bookIDs.contains(bookID) {
                    if let title = bookDict["title"] as? String,
                       let image = bookDict["image"] as? String {
                        let book = SimpleBook(title: title, image: image)
                        self.books[bookID] = book
                    }
                }
            }
            self.reservationsTableView.reloadData()
        }
    }
    
    func cancelReservation(reservationID: String) {
        let ref = Database.database().reference().child("reservations")
        ref.queryOrdered(byChild: "bookID").queryEqual(toValue: reservationID).observeSingleEvent(of: .childAdded) { snapshot in
            if let reservationDict = snapshot.value as? [String: Any] {
                let reservationUpdate = [
                    "status": "Cancelada"
                ]
                snapshot.ref.updateChildValues(reservationUpdate) { error, _ in
                    if let error = error {
                        self.showErrorAlert(message: "Error al cancelar la reserva: \(error.localizedDescription)")
                    } else {
                        self.incrementBookStock(bookID: reservationDict["bookID"] as! String)
                        self.showSuccessAlert(message: "Reserva cancelada exitosamente.")
                        self.findAllReservations()
                    }
                }
            }
        }
    }
    
    func incrementBookStock(bookID: String) {
        let ref = Database.database().reference().child("books").child(bookID)
        ref.observeSingleEvent(of: .value) { snapshot in
            if let bookDict = snapshot.value as? [String: Any], let stock = bookDict["stock"] as? Int {
                ref.updateChildValues(["stock": stock + 1]) { error, _ in
                    if let error = error {
                        self.showErrorAlert(message: "Error al actualizar el stock: \(error.localizedDescription)")
                    } else {
                        self.showSuccessAlert(message: "Stock actualizado exitosamente para el libro con ID \(bookID).")
                    }
                }
            }
        }
    }
}

extension ReservationViewController {
    func showCancelConfirmation(forReservation reservation: Reservation, completion: @escaping (Bool) -> Void) {
        AlertManager.showConfirmationAlert(on: self, title: "Confirmar cancelación", message: "¿Estás seguro de que deseas cancelar esta reserva?", confirmButtonTitle: "Confirmar", cancelButtonTitle: "Cancelar", confirmHandler: {
            completion(true)
        })
    }
    
    func showSuccessAlert(message: String) {
        AlertManager.showSuccessAlert(on: self, message: message)
    }
    
    func showErrorAlert(message: String) {
        AlertManager.showErrorAlert(on: self, message: message)
    }
}
