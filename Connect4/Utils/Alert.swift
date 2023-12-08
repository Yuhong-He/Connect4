//
//  Alert.swift
//  Connect4
//
//  Created by Yuhong He on 04/12/2023.
//

import Foundation
import UIKit

private func getRootWindow() -> UIWindow {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let delegate = windowScene.delegate as? SceneDelegate, let window = delegate.window else { return UIWindow() }
    return window
}

func gameOverMsg(message: String)  {
    let alertController = UIAlertController.init(title: "", message: message, preferredStyle: .alert);
    let action = UIAlertAction.init(title: "OK", style: .default)
    alertController.addAction(action)
    getRootWindow().rootViewController?.present(alertController, animated: true, completion: nil)
}

func confirmDeleteMsg(title: String, message: String, handler: (()->())?)  {
    let alertController = UIAlertController.init(title: title, message:message , preferredStyle: .alert);
    let actionLeft = UIAlertAction.init(title: "Cancel", style: .cancel)
    let actionRight = UIAlertAction.init(title: "Yes", style: .default){
      _ in
        handler?()
    }
    alertController.addAction(actionLeft)
    alertController.addAction(actionRight)
    getRootWindow().rootViewController?.present(alertController, animated: true, completion: nil)
}

func playFirstChoice(message: String, handler: ((_ index:Int)->())?)  {
    let alertController = UIAlertController.init(title: "", message: message, preferredStyle: .alert);
    let actionLeft = UIAlertAction.init(title: "You", style: .default){
      _ in
        handler?(1)
    }
    let actionRight = UIAlertAction.init(title: "α-C4 Bot", style: .default){
      _ in
        handler?(2)
    }
    alertController.addAction(actionLeft)
    alertController.addAction(actionRight)
    getRootWindow().rootViewController?.present(alertController, animated: true, completion: nil)
}
