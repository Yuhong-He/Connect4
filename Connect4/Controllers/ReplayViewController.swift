//
//  ReplayViewController.swift
//  Connect4
//
//  Created by Yuhong He on 07/12/2023.
//

import UIKit
import Alpha0C4
import AVFoundation

class ReplayViewController: UIViewController {
    public var sessionItem: CoreDataSession!
    private var botColor: GameSession.DiscColor = .red
    private var isBotFirst = false
    private var backHistoryPage = false
    
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
    
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        setGameBoard()
        isBotFirst = sessionItem.botIsFirst
        if sessionItem.discCount == 42 {
            messageLabel.text = "Draw"
            messageLabel.textColor = .black
        } else if sessionItem.botIsFirst { // bot start
            if sessionItem.discCount % 2 == 0 {
                messageLabel.text = "User wins!"
                messageLabel.textColor = userDiscBorderColor
            } else {
                messageLabel.text = "Bot wins!"
                messageLabel.textColor = botDiscContentColor
            }
        } else { // user start
            if sessionItem.discCount % 2 == 0 {
                messageLabel.text = "Bot wins!"
                messageLabel.textColor = botDiscContentColor
            } else {
                messageLabel.text = "User wins!"
                messageLabel.textColor = userDiscBorderColor
            }
        }
        messageLabel.font = UIFont(name: "AmericanTypewriter-Bold", size: 20.0)
        self.animationShowDetail()
    }
    
    func setupUI()  {
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
    }
    
    //MARK: Setting up the game board skeleton
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
    
    func animationShowDetail()  {
        guard let discs = sessionItem.discs?.objectEnumerator().allObjects as? [CoreDataDisc]  else{
            return
        }
        let firstPlayerColor: DiscColor = isBotFirst ? botColor : (botColor == .red ? .yellow : .red)
        let secondPlayerColor: DiscColor = firstPlayerColor == .red ? .yellow : .red
        var index = 0
        let timer = Timer(timeInterval: 0.5, repeats: true) { timer in
            if index >= discs.count || self.backHistoryPage {
                timer.invalidate()
                return
            }
            let item = discs[index]
            let color = index % 2 == 0 ? firstPlayerColor : secondPlayerColor
            self.showDropDisc(location: (Int(item.row), Int(item.column)), color: color, index: Int(item.index))
            index += 1
        }
        timer.fire()
        RunLoop.current.add(timer, forMode: .common)
    }
    
    private func showDropDisc(location:(row: Int, column: Int), color: DiscColor ,index: Int) {
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
        discsColumnView.addAnimationItem(discsView: discView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        backHistoryPage = true
    }
}
