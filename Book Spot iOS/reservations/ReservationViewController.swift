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
            showAuthenticationAlert()
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
        guard let userID = getCurrentUserID() else {
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
                    if let userID = reservationDict["userID"] as? String, userID == userID {
                        if let reservation = Reservation(dict: reservationDict) {
                            userReservations.append(reservation)
                        }
                    }
                }
            }
            self.reservations = userReservations
            self.loadBookDetails()
        }
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
    
    func getCurrentUserID() -> String? {
        if let user = Auth.auth().currentUser {
            return user.uid
        }
        return nil
    }
}

extension ReservationViewController {
    func showCancelConfirmation(forReservation reservation: Reservation, completion: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: "Confirmar cancelación", message: "¿Estás seguro de que deseas cancelar esta reserva?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel) { _ in
            completion(false)
        }
        
        let confirmAction = UIAlertAction(title: "Confirmar", style: .destructive) { _ in
            completion(true)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showSuccessAlert(message: String) {
        let alertController = UIAlertController(title: "Éxito", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showErrorAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAuthenticationAlert() {
        let alertController = UIAlertController(title: "No autenticado",
                                                message: "Necesitas iniciar sesión para ver tus prestamos",
                                                preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.goToLogin()
        }
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel) { _ in
            self.goToHome()
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension ReservationViewController {
    func goToLogin(){
        let stoyboard = UIStoryboard(name: "Main", bundle: nil)
        let view = stoyboard.instantiateViewController(withIdentifier: "LoginNavView") as! LoginNavViewController
        view.modalPresentationStyle = .fullScreen
        present(view, animated: true)
    }
    
    func goToHome() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view = storyboard.instantiateViewController(withIdentifier: "HomeView") as! HomeViewController
        view.modalPresentationStyle = .fullScreen
        present(view, animated: true)
    }
}

