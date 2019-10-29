//
//  BaseController.swift
//  MovilClub
//
//  Created by Donelkys Santana on 8/19/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import UIKit
import Rswift
import CoreLocation

class BaseController: UIViewController {
  var toolBar: UIToolbar = UIToolbar()
  var topMenu = UIView()
  var barTitle = Customization.nameShowed
  var hideTopMenu = false
  var hideMenuBtn = true
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let screenBounds = UIScreen.main.bounds
    
    //TOP MENU
    if !self.hideTopMenu{
      self.topMenu.removeFromSuperview()
      self.topMenu = UIView()
      self.topMenu.layer.cornerRadius = 15
      self.topMenu.frame = CGRect(x: 15, y: screenBounds.origin.y + 40, width: screenBounds.width - 30, height: 60)
      self.topMenu.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)
      self.topMenu.tintColor = .white
      
      let baseTitle = UILabel()
      baseTitle.frame = CGRect(x: screenBounds.width/2 - 50, y: 20, width: 220, height: 21)
      baseTitle.font = UIFont(name: "HelveticaNeue-Bold", size: 25)
      baseTitle.textColor = .white
      baseTitle.text = self.barTitle
      topMenu.addSubview(baseTitle)
      
      let closeBtn = UIButton(type: UIButton.ButtonType.system)
      closeBtn.frame = CGRect(x: topMenu.frame.width - 60, y: 15, width: 45, height: 35)
      closeBtn.setTitleColor(.black, for: .normal)
      closeBtn.setImage(UIImage(named: "salir2"), for: UIControl.State())
      closeBtn.addTarget(self, action: #selector(closeBtnAction), for: .touchUpInside)
      topMenu.addSubview(closeBtn)
      
      let homeBtn = UIButton(type: UIButton.ButtonType.system)
      homeBtn.frame = CGRect(x: 10, y: 15, width: 45, height: 35)
      homeBtn.setTitleColor(.black, for: .normal)
      homeBtn.setImage(UIImage(named: hideMenuBtn ? "home" : "menu"), for: UIControl.State())
      homeBtn.addTarget(self, action: #selector(homeBtnAction), for: .touchUpInside)
      topMenu.addSubview(homeBtn)
      
      self.view.addSubview(topMenu)
    }
    
    
  }
  
  //MENU BUTTONS FUNCTIONS
  @objc func closeBtnAction(){
    let fileAudio = FileManager()
    let AudioPath = NSHomeDirectory() + "/Library/Caches/Audio"
    do {
      try fileAudio.removeItem(atPath: AudioPath)
    }catch{
    }
    let datos = "#SocketClose," + GlobalVariables.cliente.idCliente + ",# \n"
    let vc = R.storyboard.main.inicioView()
    vc!.EnviarSocket(datos)
    exit(3)
  }
  
  @objc func homeBtnAction(){
    
  }
}

