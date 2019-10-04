//
//  TabBarController.swift
//  yolov3
//
//  Created by Rémi Hillairet on 10/3/19.
//  Copyright © 2019 Alexander. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

  override func viewDidLoad() {
    super.viewDidLoad()
    if var viewControllers = viewControllers, !UserDefaults.standard.bool(forKey: "liveModeEnabled") {
      viewControllers.remove(at: 0)
      setViewControllers(viewControllers, animated: false)
    }
    setupItems()
  }
  
  override func setViewControllers(_ viewControllers: [UIViewController]?, animated: Bool) {
    super.setViewControllers(viewControllers, animated: animated)
    setupItems()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setupItems()
  }
  
  func setupItems() {
    tabBar.selectionIndicatorImage = UIImage(named: "item-selection")
    if let items = tabBar.items {
      for item in items {
        if UIDevice.current.userInterfaceIdiom == .phone {
          item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -22.5)
        } else {
          item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 0)
        }
        item.setTitleTextAttributes([
          NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium),
          NSAttributedString.Key.foregroundColor: UIColor.black
        ], for: .normal)
        item.setTitleTextAttributes([
          NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium),
          NSAttributedString.Key.foregroundColor: UIColor.white
        ], for: .selected)
      }
    }
  }
  
  override func viewDidLayoutSubviews() {
    tabBar.frame.origin.y = view.frame.height - 64
    tabBar.frame.size.height = 64
    super.viewDidLayoutSubviews()
  }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
