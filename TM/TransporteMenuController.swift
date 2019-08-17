//
//  TransporteMenuController.swift
//  TM
//
//  Created by Donelkys Santana on 5/24/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import UIKit

class TransporteMenuController: UIViewController{
  
  @IBOutlet weak var menuCollectionView: UICollectionView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    menuCollectionView.delegate = self
    navigationItem.setHidesBackButton(true, animated: false)
  }
  
}

extension TransporteMenuController: UICollectionViewDelegate, UICollectionViewDataSource{
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
     return GlobalConstants.tranporteArray.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "typeCell",for: indexPath) as! MenuCollectionViewCell
    cell.initContent(transporteImageName: GlobalConstants.tranporteArray[indexPath.row])
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let vc = R.storyboard.main.inicioView()
    vc?.transporteIndex = indexPath.row + 1
    self.navigationController?.pushViewController(vc!, animated: true)
//    let navController = UINavigationController(rootViewController: vc!)
//    let appdelegate = UIApplication.shared.delegate as! AppDelegate
//    appdelegate.window!.rootViewController = navController
  }
  
}
