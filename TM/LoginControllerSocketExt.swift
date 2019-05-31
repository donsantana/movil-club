//
//  LoginControllerSocketExt.swift
//  UnTaxi
//
//  Created by Donelkys Santana on 5/5/19.
//  Copyright © 2019 Done Santana. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import Rswift

extension LoginController{
    
    func SocketEventos(){
        myvariables.socket.on("connect"){data, ack in
            let read = myvariables.userDefaults.string(forKey: "\(Customization.nameShowed)-loginData") ?? "Vacio"
//            let filePath = NSHomeDirectory() + "/Library/Caches/log.txt"
//            do {
//                read = try NSString(contentsOfFile: filePath, encoding: String.Encoding.utf8.rawValue) as String
//            }catch {
//            }
            if read != "Vacio"{
                self.AutenticandoView.isHidden = false
                self.Login(loginData: read)
            }
            else{
                self.AutenticandoView.isHidden = true
            }
            
        }
        
        myvariables.socket.on("LoginPassword"){data, ack in
            self.EnviarTimer(estado: 0, datos: "Terminado")
            let temporal = String(describing: data).components(separatedBy: ",")
            switch temporal[1]{
            case "loginok":
                myvariables.cliente = CCliente(idUsuario: temporal[2],idcliente: temporal[4], user: self.login[1], nombre: temporal[5],email: temporal[3],empresa: temporal[temporal.count - 2])
                if temporal[6] != "0"{
                    self.ListSolicitudPendiente(temporal)
                }
                if CLLocationManager.locationServicesEnabled(){
                    switch(CLLocationManager.authorizationStatus()) {
                    case .notDetermined, .restricted, .denied:
                        let locationAlert = UIAlertController (title: "Error de Localización", message: "Estimado cliente es necesario que active la localización de su dispositivo.", preferredStyle: .alert)
                        locationAlert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                            if #available(iOS 10.0, *) {
                                let settingsURL = URL(string: UIApplication.openSettingsURLString)!
                                UIApplication.shared.open(settingsURL, options: [:], completionHandler: { success in
                                    exit(0)
                                })
                            } else {
                                if let url = NSURL(string:UIApplication.openSettingsURLString) {
                                    UIApplication.shared.openURL(url as URL)
                                    exit(0)
                                }
                            }
                        }))
                        locationAlert.addAction(UIAlertAction(title: "No", style: .default, handler: {alerAction in
                            exit(0)
                        }))
                        self.present(locationAlert, animated: true, completion: nil)
                    case .authorizedAlways, .authorizedWhenInUse:
                        DispatchQueue.main.async {
                            let vc = R.storyboard.main.transpMenuView() //UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "Inicio") as! InicioController
                            self.navigationController?.show(vc!, sender: nil)
                        }
                        break
                    }
                }else{
                    let locationAlert = UIAlertController (title: "Error de Localización", message: "Estimado cliente es necesario que active la localización de su dispositivo.", preferredStyle: .alert)
                    locationAlert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                        if #available(iOS 10.0, *) {
                            let settingsURL = URL(string: UIApplication.openSettingsURLString)!
                            UIApplication.shared.open(settingsURL, options: [:], completionHandler: { success in
                                exit(0)
                            })
                        } else {
                            if let url = NSURL(string:UIApplication.openSettingsURLString) {
                                UIApplication.shared.openURL(url as URL)
                                exit(0)
                            }
                        }
                    }))
                    locationAlert.addAction(UIAlertAction(title: "No", style: .default, handler: {alerAction in
                        exit(0)
                    }))
                    self.present(locationAlert, animated: true, completion: nil)
                }
            case "loginerror":
//                let fileManager = FileManager()
//                let filePath = NSHomeDirectory() + "/Library/Caches/log.txt"
//                do {
//                    try fileManager.removeItem(atPath: filePath)
//                }catch{
//
//                }
                myvariables.userDefaults.set(nil, forKey: "\(Customization.nameShowed)-loginData")
                
                let alertaDos = UIAlertController (title: "Autenticación", message: "Usuario y/o clave incorrectos", preferredStyle: UIAlertController.Style.alert)
                alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                    self.AutenticandoView.isHidden = true
                    self.Usuario.text?.removeAll()
                }))
                self.present(alertaDos, animated: true, completion: nil)
            default: print("Problemas de conexion")
            }
        }
        
        myvariables.socket.on("Registro") {data, ack in
            self.EnviarTimer(estado: 0, datos: "Terminado")
            let temporal = String(describing: data).components(separatedBy: ",")
            if temporal[1] == "registrook"{
                let alertaDos = UIAlertController (title: "Registro de Usuario", message: "Registro Realizado con éxito, puede loguearse en la aplicación, ¿Desea ingresar a la Aplicación?", preferredStyle: .alert)
                alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                    self.RegistroView.isHidden = true
                }))
                alertaDos.addAction(UIAlertAction(title: "Cancelar", style: .default, handler: {alerAction in
                    exit(0)
                }))
                self.present(alertaDos, animated: true, completion: nil)
            }else{
                let alertaDos = UIAlertController (title: "Registro de Usuario", message: "Error al registrar el usuario: \(temporal[2])", preferredStyle: UIAlertController.Style.alert)
                alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                    self.AutenticandoView.isHidden = true
                }))
                self.present(alertaDos, animated: true, completion: nil)
            }
        }
        
        //RECUPERAR CLAVES
        myvariables.socket.on("Recuperarclave"){data, ack in
            self.EnviarTimer(estado: 0, datos: "Terminado")
            let temporal = String(describing: data).components(separatedBy: ",")
            if temporal[1] == "ok"{
                let alertaDos = UIAlertController (title: "Recuperación de clave", message: "Su clave ha sido recuperada satisfactoriamente, en este momento ha recibido un correo electronico a la dirección: " + temporal[2], preferredStyle: UIAlertController.Style.alert)
                alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
                }))
                self.present(alertaDos, animated: true, completion: nil)
            }
        }
    }
}

