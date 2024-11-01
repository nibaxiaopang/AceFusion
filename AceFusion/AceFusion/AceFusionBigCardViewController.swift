//
//  BigCardViewController.swift
//  AceFusion
//
//  Created by jin fu on 2024/11/1.
//

import UIKit

class AceFusionBigCardViewController: UIViewController {
    
    @IBOutlet weak var cardAImg: UIImageView!
    @IBOutlet weak var cardBImg: UIImageView!
    
    var cardArr = ["ace_of_spades", "king_of_spades", "queen_of_spades", "jack_of_spades", "ace_of_clubs", "king_of_clubs", "queen_of_clubs", "jack_of_clubs", "ace_of_hearts", "king_of_hearts", "queen_of_hearts", "jack_of_hearts", "ace_of_diamonds", "king_of_diamonds", "queen_of_diamonds", "jack_of_diamonds"]
    
    var backCardImage = "back_card"
    var cardA: String?
    var cardB: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set both card images to the back of the card initially
        cardAImg.image = UIImage(named: backCardImage)
        cardBImg.image = UIImage(named: backCardImage)
    }
    
    @IBAction func checkCardbtn(_ sender: UIButton) {
        // Flip both cards to reveal random card images
        cardA = cardArr.randomElement()
        cardB = cardArr.randomElement()
        
        cardAImg.image = UIImage(named: cardA!)
        cardBImg.image = UIImage(named: cardB!)
        
        // Compare the cards based on the tag of the button pressed
        switch sender.tag {
        case 0: // A card is bigger
            if cardA == cardB {
                // If both cards are the same
                showResultAlert(message: "Wrong! Both cards are the same.")
            } else if isCardABigger() {
                // If A is indeed bigger
                showResultAlert(message: "Correct! Card A is bigger.")
            } else {
                // If B is bigger
                showResultAlert(message: "Wrong! Card B is bigger.")
            }
            
        case 1: // Both cards are the same
            if cardA == cardB {
                showResultAlert(message: "Correct! Both cards are the same.")
            } else {
                showResultAlert(message: "Wrong! The cards are different.")
            }
            
        case 2: // B card is bigger
            if cardA == cardB {
                // If both cards are the same
                showResultAlert(message: "Wrong! Both cards are the same.")
            } else if !isCardABigger() {
                // If B is indeed bigger
                showResultAlert(message: "Correct! Card B is bigger.")
            } else {
                // If A is bigger
                showResultAlert(message: "Wrong! Card A is bigger.")
            }
            
        default:
            break
        }
    }
    
    @IBAction func backBtn(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    // Updated ranking based on correct poker ranking
    func isCardABigger() -> Bool {
        let rankOrder: [String] = ["ace_of_spades", "ace_of_clubs", "ace_of_hearts", "ace_of_diamonds", "king_of_spades", "king_of_clubs", "king_of_hearts", "king_of_diamonds", "queen_of_spades", "queen_of_clubs", "queen_of_hearts", "queen_of_diamonds", "jack_of_spades", "jack_of_clubs", "jack_of_hearts", "jack_of_diamonds"]
        
        // Ensure both cards exist in the rankOrder
        guard let indexA = rankOrder.firstIndex(of: cardA!), let indexB = rankOrder.firstIndex(of: cardB!) else {
            return false
        }
        
        // The smaller index means the card is stronger
        return indexA < indexB
    }
    
    // Helper function to show result alert and reset the images
    func showResultAlert(message: String) {
        let alert = UIAlertController(title: "Result", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.resetCardsToBackImage()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    // Reset the card images to back of the card after the result alert
    func resetCardsToBackImage() {
        cardAImg.image = UIImage(named: backCardImage)
        cardBImg.image = UIImage(named: backCardImage)
    }
}
