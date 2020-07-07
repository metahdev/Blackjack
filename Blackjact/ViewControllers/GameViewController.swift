//
//  GameViewController.swift
//  Blackjact
//
//  Created by PVZS on 11/30/19.
//  Copyright © 2020 SanzharIndustries. All rights reserved.
//

import UIKit
import QuartzCore

protocol GameVCProtocol: class {
    var model: String { get set }
}

struct Card: Equatable {
    var imageName: String
    var value: Int
}

class GameViewController: UIViewController, GameVCProtocol {
    // MARK:- Properties
    var model = ""
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var betLabel: UILabel!
    @IBOutlet weak var enemyScoreLbl: UILabel!
    @IBOutlet weak var playerScoreLbl: UILabel!
    
    @IBOutlet weak var modelImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var forwardBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var dollar10BetBtn: UIButton!
    @IBOutlet weak var dollar50BetBtn: UIButton!
    @IBOutlet weak var dollar100BetBtn: UIButton!
    @IBOutlet weak var betBtn: UIButton!
    
    @IBOutlet weak var standBtn: UIButton!
    @IBOutlet weak var hitBtn: UIButton!
    @IBOutlet weak var doubleBtn: UIButton!
    @IBOutlet weak var splitBtn: UIButton!
    
    @IBOutlet weak var enemyCardsCV: UICollectionView!
    @IBOutlet weak var playerCardsCV: UICollectionView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    private var currentImageIndex: Int?
    private var userSelectedImage: Int? {
        didSet {
            pageControl.currentPage = userSelectedImage!
        }
    }
    
    private var currentDeck = [Card]()
    private var enemyCards = [Card]()
    private var playerCards = [Card]()
    
    private var suits = ["clubs", "diamonds", "hearts", "spades"]
    
    private var enemyScore = 0
    private var playerScore = 0
    
    private var didBet = false
    private var currentBalance = 500
    private var balance = 500
    private var currentBet = 0 {
        didSet {
            updateBetLabel()
        }
    }
    private func updateBetLabel() {
        betLabel.text = "Your bet: \(currentBet)$"
        betBtn.isEnabled = true
        
        balanceLabel.text = "Balance: \(currentBalance)$"
    }
    private var openedCard = false
    
    
    // MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        linkCVToSelf(enemyCardsCV)
        linkCVToSelf(playerCardsCV)
        setupScrollView()
        makeFrameRound(dollar10BetBtn)
        makeFrameRound(dollar50BetBtn)
        makeFrameRound(dollar100BetBtn)
        
        pageControl.numberOfPages = Content.modelsMax[model]! + 1
    }
    
    private func linkCVToSelf(_ cv: UICollectionView) {
        cv.dataSource = self
        cv.delegate = self
    }
    
    private func setupScrollView() {
        scrollView.delegate = self
        
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0

        scrollView.contentSize = .init(width: 2000, height: 2000)
    }
    
    private func makeFrameRound(_ view: UIView) {
        view.clipsToBounds = true
        view.layer.masksToBounds = false
        view.layer.cornerRadius = view.frame.height / 2 - 2
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 2
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateMinZoomScaleForSize(view.bounds.size)
    }
    
    func updateMinZoomScaleForSize(_ size: CGSize) {
        let widthScale = size.width / modelImageView.bounds.width
        let heightScale = size.height / modelImageView.bounds.height
        let minScale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setProperties()
        setImage()
        updateScore()
        
        AudioPlayer.initWellDoneAudio()
        AudioPlayer.initTryAgainAudio()
    }
    
    private func setProperties() {
        titleLabel.text = model
    }
    
    private func setImage() {
        var imageName = model
        if let index = userSelectedImage {
            imageName += "\(index)"
        } else {
            userSelectedImage = 0
            currentImageIndex = 0
        }
        if userSelectedImage == 0 {
            imageName = model
        }
        modelImageView.image = UIImage(named: imageName)
    }
    
    private func updateScore() {
        parseScore(enemyScore, enemyScoreLbl, action: {
            let score = (openedCard) ? "\(enemyScore)" : "?"
            enemyScoreLbl.text = "\(model)'s Score: \(score)"
        })
        
        parseScore(playerScore, playerScoreLbl, action: {
            playerScoreLbl.text = "Your Score: \(playerScore)"
        })
    }
    
    private func parseScore(_ score: Int, _ label: UILabel, action: () -> ()) {
        if score != 0 {
            action()
        } else {
            label.text = ""
        }
    }
    
    
    // MARK:- Actions
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backImage(_ sender: Any) {
        userSelectedImage! -= 1
        setImage()
        forwardBtn.isEnabled = true
        
        if userSelectedImage == 0 {
            backBtn.isEnabled = false
        }
    }
    
    @IBAction func nextImage(_ sender: Any) {
        userSelectedImage! += 1
        setImage()
        backBtn.isEnabled = true
        
        if userSelectedImage == Content.modelsMax[model] || (userSelectedImage! == currentImageIndex!) {
            forwardBtn.isEnabled = false
        }
    }
        
    
    // MARK:- Game Logic
    @IBAction func place10Bet(_ sender: Any) {
        saveBalance()
        guard currentBalance - 10 >= 0 else { return }
        updateBalance(bet: 10)
    }
    
    private func saveBalance() {
        if !didBet {
            balance = currentBalance
            didBet = true
        }
    }
    
    @IBAction func place50Bet(_ sender: Any) {
        saveBalance()
        guard currentBalance - 50 >= 0 else { return }
        updateBalance(bet: 50)
    }
    
    @IBAction func place100Bet(_ sender: Any) {
        saveBalance()
        guard currentBalance - 100 >= 0 else { return }
        updateBalance(bet: 100)
    }
    
    private func updateBalance(bet: Int) {
        currentBalance -= bet
        currentBet += bet
    }
    
    @IBAction func bet(_ sender: Any) {
        changeViewsState(hideBetBtn: true)
        changeBetsAbility(unlockBets: false)
        
        startGame()
        updateScore()
        
        enemyCardsCV.reloadData()
        playerCardsCV.reloadData()
    }
    
    private func changeViewsState(hideBetBtn: Bool) {
        betBtn.isHidden = hideBetBtn
        
        standBtn.isHidden = !hideBetBtn
        hitBtn.isHidden = !hideBetBtn
        doubleBtn.isHidden = !hideBetBtn
    }
    
    private func changeBetsAbility(unlockBets: Bool) {
        dollar10BetBtn.isEnabled = unlockBets
        dollar50BetBtn.isEnabled = unlockBets
        dollar100BetBtn.isEnabled = unlockBets
    }
        
    private func changeActionsAbility(unlockActions: Bool) {
        standBtn.isEnabled = unlockActions
        hitBtn.isEnabled = unlockActions
        doubleBtn.isEnabled = unlockActions
    }
    
    private func startGame() {
        for _ in 0...1 {
            playerCards.append(generateCard(isPlayer: true))
            enemyCards.append(generateCard(isPlayer: false))
        }
        if playerCards[0].value == playerCards[1].value {
            toHideSplitBtn(false)
        }
    }
    
    private func generateCard(isPlayer: Bool) -> Card {
        let randomNum = Int.random(in: 2...14)
        let randomSuit = suits[Int.random(in: 0...3)]
        
        var imageName = ""
        var convertedCard = "\(randomNum)"
        
        var supply = randomNum
        
        var score = (isPlayer) ? playerScore : enemyScore

        if randomNum == 14 {
            supply = 11
            if (score + supply) > 21 {
                supply = 1
            }
        } else if randomNum > 10 {
            supply = 10
        }
                
        let cards = (isPlayer) ? playerCards : enemyCards
        var indexOfAce: Int?
        if (score + supply) > 21 {
            for i in 0..<cards.count {
                if cards[i].imageName.hasPrefix("ace") && cards[i].value != 1 {
                    score -= 10
                    indexOfAce = i
                }
            }
        }
        
        score += supply
        
        switch (randomNum) {
        case 11:
            convertedCard = "jack"
        case 12:
            convertedCard = "queen"
        case 13:
            convertedCard = "king"
        case 14:
            convertedCard = "ace"
        default: break
        }
        
        imageName = convertedCard + "_of_" + randomSuit
        let card = Card(imageName: imageName, value: supply)
        if !currentDeck.contains(card) {
            currentDeck.append(card)

            if isPlayer {
                playerScore = score
            } else {
                enemyScore = score
            }
            if let index = indexOfAce {
                if isPlayer {
                    playerCards[index].value = 1
                } else {
                    enemyCards[index].value = 1
                }
            }
            return card
        } else {
            return generateCard(isPlayer: isPlayer)
        }
    }
    
    private func toHideSplitBtn(_ hide: Bool) {
        splitBtn.isHidden = hide
    }
    
    
    @IBAction func stand(_ sender: Any) {
        openedCard = true
        enemyCardsCV.reloadData()
        updateScore()
        changeActionsAbility(unlockActions: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
            self?.botMove(previousTime: 0.5)
        })
    }
    
    private func botMove(previousTime: Double) {
        enemyCardsCV.scrollToItem(at: IndexPath(row: enemyCards.count - 1, section: 0), at: .right, animated: true)

        guard enemyScore < 22 else {
            announceResults(playerWon: true)
            return
        }
        
        guard enemyScore != playerScore else {
            announceResults(playerWon: nil, startingTime: 0.5)
            return
        }
        
        guard enemyScore < playerScore else {
            announceResults(playerWon: false, startingTime: 0.5)
            return
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + previousTime, execute: { [weak self] in
            self?.enemyCards.append(self?.generateCard(isPlayer: false) ?? Card(imageName: "two_of_spades", value: 2))
            self?.enemyCardsCV.reloadData()
            self?.updateScore()
            self?.botMove(previousTime: previousTime + 0.5)
        })
    }
    
    private func announceResults(playerWon: Bool?, startingTime: Double = 0.0) {
        var title = ""
        var jackpot = 0
        
        if let playerWon = playerWon {
            if playerWon {
                self.backBtn.isEnabled = true
                if currentImageIndex == Content.modelsMax[model]! - 1 {
                    title = "Congratulations, you won the Game! \(model) has run out of balance!"
                } else {
                    title = "You won this round!"
                }
                currentBalance = balance + currentBet + (currentBet / 2)
                jackpot = currentBet + currentBet / 2
            } else {
                title = "You lost in this round!"
                jackpot = -currentBet
            }
        } else {
            title = "It's a Draw!"
            currentBalance = balance
        }
        
        if currentBalance < 10 {
            title = "Game Over"
        }
        
        var state = "Prize"
        if let playerWon = playerWon {
            if !playerWon {
                state = "Loss"
            }
        }
        let message = "Remaining balance: \(currentBalance)$\n\(state): \(jackpot)$"
                
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: {(action) in
            self.resetGame()
            guard playerWon == true else {
                AudioPlayer.tryAgainAudioPlayer.prepareToPlay()
                AudioPlayer.tryAgainAudioPlayer.play()
                if self.currentBalance < 10 {
                    self.dismiss(animated: true, completion: nil)
                }
                return
            }
            AudioPlayer.wellDoneAudioPlayer.prepareToPlay()
            AudioPlayer.wellDoneAudioPlayer.play()
            if self.currentImageIndex! <= Content.modelsMax[self.model]! - 1 {
                self.currentImageIndex! += 1
                self.userSelectedImage = self.currentImageIndex
                self.setImage()
            }
            if self.currentImageIndex! == Content.modelsMax[self.model]! {
                self.changeBetsAbility(unlockBets: false)
                self.changeActionsAbility(unlockActions: false)
                self.betBtn.isEnabled = false
                return
            }
        })
        
        alert.addAction(action)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + startingTime + 0.5, execute: {[weak self] in
            self?.show(alert, sender: nil)
        })
    }
    
    private func resetGame() {
        openedCard = false
        didBet = false
        
        playerCards = []
        enemyCards = []
        currentDeck = []
        
        playerCardsCV.reloadData()
        enemyCardsCV.reloadData()
        
        playerScore = 0
        enemyScore = 0
        updateScore()
        
        currentBet = 0
        updateBetLabel()
                
        toHideSplitBtn(true)
        changeViewsState(hideBetBtn: false)
        changeBetsAbility(unlockBets: true)
        changeActionsAbility(unlockActions: true)
        
        betBtn.isEnabled = false
    }
    
    @IBAction func hit(_ sender: Any) {
        doubleBtn.isEnabled = false
        playerMove(unlockActions: true)
        playerCardsCV.scrollToItem(at: IndexPath(row: playerCards.count - 1, section: 0), at: .right, animated: true)
    }
    
    private func playerMove(unlockActions: Bool) {
        changeActionsAbility(unlockActions: false)
        playerCards.append(generateCard(isPlayer: true))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {[weak self] in
            self?.playerCardsCV.reloadData()
            self?.updateScore()
            self?.changeActionsAbility(unlockActions: unlockActions)
        })
        if self.playerScore > 21 {
            self.announceResults(playerWon: false)
        }
    }
    
    @IBAction func double(_ sender: Any) {
        playerMove(unlockActions: false)
        guard self.playerScore < 22 else {
            return
        }
        botMove(previousTime: 1.0)
    }
    
    @IBAction func split(_ sender: Any) {
        let alert = UIAlertController(title: "Buy a full version of the app.", message: "The dev of the application is too lazy to work on the 'split' functionality. Send him money plz, so maybe he will change his decision.", preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay :(", style: .default, handler: {(action) in
            self.dismiss(animated: true, completion: nil)
        })
        
        alert.addAction(action)
        show(alert, sender: nil)
    }
}


extension GameViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 1 {
            return enemyCards.count
        } else {
            return playerCards.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let comCell = collectionView.dequeueReusableCell(withReuseIdentifier: "reuseID", for: indexPath) as! ImageCollectionViewCell
        if collectionView.tag == 1 {
            if !openedCard && indexPath.row == 1 {
                comCell.imageName = "backCard"
            } else {
                comCell.imageName = enemyCards[indexPath.row].imageName
            }
        } else {
            comCell.imageName = playerCards[indexPath.row].imageName
        }
        return comCell
    }
}

extension GameViewController: UICollectionViewDelegate {}

extension GameViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var constant = collectionView.frame.width
        if collectionView.tag == 1 {
            constant *= 0.25
        } else {
            constant *= 0.2
        }
        return CGSize(width: constant, height: collectionView.frame.height)
    }
}

extension GameViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return modelImageView
    }
}
