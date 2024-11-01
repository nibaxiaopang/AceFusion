//
//  CardMatchViewController.swift
//  AceFusion
//
//  Created by jin fu on 2024/11/1.
//

import UIKit

class AceFusionCardMatchViewController: UIViewController {
    
    @IBOutlet weak var cradMatchCollection: UICollectionView!
    @IBOutlet weak var timeLbl: UILabel!
    
    var aceArr = ["ace_of_spades", "king_of_spades", "queen_of_spades", "jack_of_spades"]
    var clubArr = ["ace_of_clubs", "king_of_clubs", "queen_of_clubs", "jack_of_clubs"]
    var heartArr = ["ace_of_hearts", "king_of_hearts", "queen_of_hearts", "jack_of_hearts"]
    var diamondArr = ["ace_of_diamonds", "king_of_diamonds", "queen_of_diamonds", "jack_of_diamonds"]
    
    var card = [String]()
    var timer: Timer?
    var startTime: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showInstructions()
        cradMatchCollection.dataSource = self
        cradMatchCollection.delegate = self
        setupInitialGrid()
        cradMatchCollection.isUserInteractionEnabled = true
        addSwipeGestures()
    }
    
    @IBAction func backBtn(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func setupInitialGrid() {
        card = []
        
        // Combine the four arrays to form a 4x4 grid.
        for i in 0..<4 {
            card.append(contentsOf: [aceArr[i], clubArr[i], heartArr[i], diamondArr[i]])
        }
        
        card.shuffle() // Shuffle the cards to make the game challenging.
        cradMatchCollection.reloadData()
    }
    
    func addSwipeGestures() {
        let swipeDirections: [UISwipeGestureRecognizer.Direction] = [.left, .right, .up, .down]
        
        for direction in swipeDirections {
            let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
            swipeGesture.direction = direction
            cradMatchCollection.addGestureRecognizer(swipeGesture)
        }
    }
    
    @objc func handleSwipeGesture(_ gesture: UISwipeGestureRecognizer) {
        let location = gesture.location(in: cradMatchCollection)
        
        guard let selectedIndexPath = cradMatchCollection.indexPathForItem(at: location) else { return }
        
        var targetIndexPath: IndexPath?
        
        switch gesture.direction {
        case .left:
            targetIndexPath = IndexPath(item: selectedIndexPath.item - 1, section: selectedIndexPath.section)
        case .right:
            targetIndexPath = IndexPath(item: selectedIndexPath.item + 1, section: selectedIndexPath.section)
        case .up:
            targetIndexPath = IndexPath(item: selectedIndexPath.item - 4, section: selectedIndexPath.section)
        case .down:
            targetIndexPath = IndexPath(item: selectedIndexPath.item + 4, section: selectedIndexPath.section)
        default:
            break
        }
        
        if let targetIndexPath = targetIndexPath, isValidIndexPath(targetIndexPath), isAdjacent(from: selectedIndexPath, to: targetIndexPath) {
            swapCards(from: selectedIndexPath, to: targetIndexPath)
        }
    }
    
    func isValidIndexPath(_ indexPath: IndexPath) -> Bool {
        return indexPath.item >= 0 && indexPath.item < card.count
    }
    
    func isAdjacent(from: IndexPath, to: IndexPath) -> Bool {
        let difference = abs(from.item - to.item)
        
        let isAdjacentHorizontally = (difference == 1) && (from.item / 4 == to.item / 4)
        let isAdjacentVertically = (difference == 4)
        
        return isAdjacentHorizontally || isAdjacentVertically
    }
    
    func swapCards(from: IndexPath, to: IndexPath) {
        card.swapAt(from.item, to.item)
        cradMatchCollection.reloadData()
        checkForWinningCondition()
    }
    
    func checkForWinningCondition() {
        // Check if each column has matching cards from one suit.
        for i in 0..<4 {
            let column = [card[i], card[i + 4], card[i + 8], card[i + 12]]
            if column.allSatisfy({ aceArr.contains($0) }) ||
                column.allSatisfy({ clubArr.contains($0) }) ||
                column.allSatisfy({ heartArr.contains($0) }) ||
                column.allSatisfy({ diamondArr.contains($0) }) {
                continue
            } else {
                return
            }
        }
        stopTimer()
        showWinningAlert()
    }
    
    func showWinningAlert() {
        let alert = UIAlertController(title: "You Won!", message: "All cards matched! Your time: \(String(describing: timeLbl.text ?? "00"))", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Restart", style: .default) { [weak self] _ in
            self?.resetGame()
        })
        present(alert, animated: true, completion: nil)
    }
    
    func resetGame() {
        setupInitialGrid()
        startTimer()
        cradMatchCollection.reloadData()
    }
    
    func startTimer() {
        startTime = Date()
        timeLbl.text = "Time: 00:00"
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        guard let startTime = startTime else { return }
        let elapsedTime = Int(Date().timeIntervalSince(startTime))
        let minutes = elapsedTime / 60
        let seconds = elapsedTime % 60
        timeLbl.text = String(format: "Time: %02d:%02d", minutes, seconds)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func showInstructions() {
        let alert = UIAlertController(title: "How to Play", message: "Match all cards from the same suit in each column by swapping them. Swipe on a card to swap with an adjacent one.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Start Game", style: .default, handler: { _ in
            self.resetGame()
        }))
        present(alert, animated: true, completion: nil)
    }
}

extension AceFusionCardMatchViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return card.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cradMatchCollection.dequeueReusableCell(withReuseIdentifier: "CardCollectionViewCell", for: indexPath) as! CardCollectionViewCell
        let imageName = card[indexPath.item]
        cell.cardImg.image = UIImage(named: imageName)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing: CGFloat = 10 * 3
        let width = (collectionView.bounds.width - totalSpacing) / 4 - 10
        let height = (collectionView.bounds.height - totalSpacing) / 4 - 10
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
