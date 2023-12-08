//
//  GameViewController.swift
//  Connect4
//
//  Created by Yuhong He on 04/12/2023.
//

import UIKit
import Alpha0C4
import AVFoundation

class GameViewController: UIViewController {
    private var session = GameSession()
    private var botColor: GameSession.DiscColor = .red
    private var isBotFirst = false
    private var canUserPlay: Bool = true
    var droppingSound: AVPlayer!
    var didClickRestart: Bool = false
    
    lazy var screenWidth: CGFloat = {
        return UIScreen.main.bounds.size.width
    }()
    lazy var screenHeight: CGFloat = {
        return UIScreen.main.bounds.size.height
    }()
    lazy var discWidth: CGFloat = {
        return screenWidth / 7.0
    }()
    lazy var holeWidth: CGFloat = {
        return screenWidth / 7.0 - 10
    }()
    lazy var bubbleSize: CGSize = {
        return CGSize.init(width: discWidth, height: discWidth)
    }()
    
    lazy var gameBoard: UIView = {
        let gameBoard = UIView()
        gameBoard.backgroundColor = boardColor
        return gameBoard
    }()
    
    var discColumnViewList = [DiscColumnView]()
    var discViewList = [DiscView]()
    
    @IBOutlet weak var botActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        setGameBoard()
        startChoice()
        
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        rightSwipeGesture.direction = .right
        self.view.addGestureRecognizer(rightSwipeGesture)
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        leftSwipeGesture.direction = .left
        self.view.addGestureRecognizer(leftSwipeGesture)
    }
    
    func setupUI() {
        let topView = UIView()
        topView.backgroundColor = .white
        view.addSubview(topView)
        topView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight * 0.7)
        for i in 0 ..< 7 {
            let discsColumnView = DiscColumnView(frame: CGRect(x: discWidth * Double(i), y: 0, width: discWidth, height: topView.frame.height))
            discColumnViewList.append(discsColumnView)
            topView.addSubview(discsColumnView);
        }
        let gameBoardLength = screenWidth * 6 / 7.0
        topView.addSubview(self.gameBoard)
        gameBoard.frame = CGRect(x: 0, y: topView.frame.size.height - gameBoardLength, width: screenWidth, height: gameBoardLength)
        messageLabel.text = ""
    }
    
    func setGameBoard() {
        let maskPath = UIBezierPath(rect: self.gameBoard.bounds)
        for i in 0 ..< 42 {
            let rect = CGRect(x: 5 + discWidth * Double((i % 7)), y: 5 + discWidth * Double(i / 7), width: holeWidth, height: holeWidth)
            let holePath = UIBezierPath(roundedRect: rect, cornerRadius: discWidth / 2.0)
            maskPath.append(holePath)
        }
        let mask = CAShapeLayer()
        mask.fillRule = .evenOdd
        mask.path = maskPath.cgPath
        self.gameBoard.layer.mask = mask
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.canUserPlay == false {
            return
        }
        let touche = touches.first
        let point = touche!.location(in: self.gameBoard)
        self.calculateColumn(point: point)
    }
    
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.state == .ended {
            didClickRestart = true
            startChoice()
        }
    }
    
    func calculateColumn(point: CGPoint) {
        var column: Int = -1
        repeat {
            column += 1
        } while !((point.x >= discWidth * Double(column)) && (point.x <= discWidth * Double(column + 1)))
        column += 1
        if session.isValidMove(column) {
            session.dropDisc(atColumn: column)
        }
    }
    
    private func showDropDisc(location: (row: Int, column: Int), color: DiscColor, index: Int) {
        let discsColumnView = discColumnViewList[location.column - 1] // remove this column
        let frame = CGRect(origin: .zero, size: bubbleSize)
        var discView: DiscView!
        if color == .yellow {
            discView = DiscView(frame: frame, borderColor: userDiscBorderColor, contentColor: userDiscContentColor, text: "\(index)", textColor: UIColor.black, column: location.column)
        } else {
            discView = DiscView(frame: frame, borderColor: botDiscBorderColor, contentColor: botDiscContentColor, text: "\(index)", textColor: UIColor.white, column: location.column)
        }
        self.discViewList.append(discView)
        discsColumnView.addSubview(discView)
        discColumnViewList[location.column - 1].addAnimationItem(discsView: discView) // add gravity drop animation
    }
    
    func startChoice() {
        playFirstChoice(message: "Who plays first?") { index in
            if index == 2 {
                self.isBotFirst = true
                self.messageLabel.text = "Bot Turn"
                self.messageLabel.textColor = botDiscBorderColor
            } else {
                self.isBotFirst = false
                self.messageLabel.text = "Your Turn"
                self.messageLabel.textColor = userDiscBorderColor
            }
            self.messageLabel.font = UIFont(name: "AmericanTypewriter-Bold", size: 20.0)
            self.session.startGame(delegate: self, botPlays: self.botColor, first: self.isBotFirst, initialPositions: [(Int, Int)]())
        }
    }
    
    @IBAction func reStartGame(_ sender: UIBarButtonItem) {
        didClickRestart = true
        startChoice()
    }
}

// MARK: - GameSessionDelegate
extension GameViewController: GameSessionDelegate
{
    // GameSessionDelegate update for game state changes
    func stateChanged(_ gameSession: Alpha0C4.GameSession, state: SessionState, textLog: String) {
        // Handle state transition
        switch state
        {
        // Inital state
        case .cleared:
            // Enable user action if player turn is user
            canUserPlay = true
            UIView.animate(withDuration: 0.5, animations: {
                for discView in self.discViewList {
                    discView.frame.origin.y = self.screenHeight
                }
            }, completion: { _ in
                if self.didClickRestart {
                    self.droppingSound = AVPlayer(url: Bundle.main.url(forResource: "fall", withExtension: "mp3")!)
                    self.droppingSound.play()
                }
                for (_, discView) in self.discViewList.enumerated() {
                    let discsColumnView = self.discColumnViewList[discView.column - 1]
                    discsColumnView.removeAnimationItem(discsView: discView)
                    discView.removeFromSuperview()
                }
                self.discViewList.removeAll()
            })
            
        // Player evaluating position to play
        case .busy(_):
            // Disable button while thinking
            canUserPlay = false
            
        // Waiting for player to play
        case .idle(let color):
            if color == botColor {
                canUserPlay = false
                self.messageLabel.text = "Bot Turn"
                self.messageLabel.textColor = botDiscBorderColor
                botActivityIndicator.startAnimating()
                Task {
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                    await MainActor.run {
                        botActivityIndicator.stopAnimating()
                        gameSession.dropDisc()
                    }
                }
            } else {
                canUserPlay = true
                self.messageLabel.text = "Your Turn"
                self.messageLabel.textColor = userDiscBorderColor
            }
            
        // End of game, update UI with game result, start new game
        case .ended(let outcome):
            // Disable button
            canUserPlay = false
            
            // Display game result
            var gameResult: String
            var textColor: UIColor
            switch outcome {
            case botColor:
                gameResult = "Bot wins!"
                textColor = botDiscBorderColor
                self.droppingSound = AVPlayer(url: Bundle.main.url(forResource: "fail", withExtension: "mp3")!)
                self.droppingSound.play()
            case !botColor:
                gameResult = "User wins!"
                textColor = userDiscBorderColor
                self.droppingSound = AVPlayer(url: Bundle.main.url(forResource: "win", withExtension: "mp3")!)
                self.droppingSound.play()
            default:
                gameResult = "Draw!"
                textColor = .black
            }
            messageLabel.text =  gameResult
            messageLabel.textColor = textColor
            self.canUserPlay = false
            gameOverMsg(message: "Game over \n \(gameResult)")

            // Save to core date
            let moc = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
            _ = CoreDataSession.save(botPlays: botColor, first: isBotFirst, layout: gameSession.boardLayout,
                                     positions: gameSession.playerPositions, winningPositions: gameSession.winningPositions,
                                     in: moc, timestamp: Date())
            
        @unknown default:
            break
        }
    }
    
    // GameSessionProtocol notifying of the result of a player action
    // textLog provides some string visualization of the game board for debug purposes
    func didDropDisc(_ gameSession: GameSession, color: DiscColor, at location: (row: Int, column: Int), index: Int, textLog: String) {
        print("\(color) drops at \(location)")
        self.showDropDisc(location: location, color: color, index: index)
    }
    
    // GameSessionProtocol notification of end of game
    func didEnd(_ gameSession: GameSession, color: DiscColor?, winningActions: [(row: Int, column: Int)]) {
        // Display winning disc positions
        print("Winning actions: " + winningActions.map({"\($0)"}).joined(separator: " "))
    }
}
