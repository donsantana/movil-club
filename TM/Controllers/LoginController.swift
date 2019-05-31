//
//  LoginController.swift
//  UnTaxi
//
//  Created by Done Santana on 26/2/17.
//  Copyright © 2017 Done Santana. All rights reserved.
//

import UIKit
import SocketIO
import CoreLocation
import GoogleMobileAds

class LoginController: UIViewController, CLLocationManagerDelegate{
  
  var login = [String]()
  var solitudespdtes = [CSolicitud]()
  var coreLocationManager: CLLocationManager!
  var EnviosCount = 0
  var emitTimer = Timer()
  
  //    var ServersData = [String]()
  //    var ServerParser = XMLParser()
  //    var recordKey = ""
  //    let dictionaryKeys = ["ip","p"]
  
  var results = [[String: String]]()                // the whole array of dictionaries
  var currentDictionary = [String : String]()    // the current dictionary
  var currentValue: String = ""                   // the current value for one of the keys in the dictionary
  
  var socketIOManager: SocketManager! //SocketManager(socketURL: URL(string: "http://www.xoait.com:5803")!, config: [.log(true), .forcePolling(true)])
  
  var apiRequestService = ApiRequestController()
  
  //MARK:- VARIABLES INTERFAZ
  
  @IBOutlet weak var loginBackView: UIView!
  @IBOutlet weak var Usuario: UITextField!
  @IBOutlet weak var Clave: UITextField!
  @IBOutlet weak var AutenticandoView: UIView!
  
  
  @IBOutlet weak var DatosView: UIView!
  @IBOutlet weak var ClaveRecover: UIView!
  @IBOutlet weak var movilClaveRecover: UITextField!
  @IBOutlet weak var RecuperarClaveBtn: UIButton!
  
  
  @IBOutlet weak var RegistroView: UIView!
  @IBOutlet weak var nombreApText: UITextField!
  @IBOutlet weak var claveText: UITextField!
  @IBOutlet weak var confirmarClavText: UITextField!
  @IBOutlet weak var correoText: UITextField!
  @IBOutlet weak var telefonoText: UITextField!
  @IBOutlet weak var RegistroBtn: UIButton!
  @IBOutlet weak var correoTextTop: NSLayoutConstraint!
  
  
  //CONSTRAINTS DEFINITION
  @IBOutlet weak var textFieldHeight: NSLayoutConstraint!
  
  @IBOutlet weak var creaUsuarioBottom: NSLayoutConstraint!
  @IBOutlet weak var nombreTextBottom: NSLayoutConstraint!
  @IBOutlet weak var telefonoTextBottom: NSLayoutConstraint!
  @IBOutlet weak var claveTextBottom: NSLayoutConstraint!
  @IBOutlet weak var movilClaveRecoverHeight: NSLayoutConstraint!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.apiRequestService.delegate = self
    
    self.apiRequestService.loginToAPIService()
    
    myvariables.userDefaults = UserDefaults.standard
    
    self.coreLocationManager = CLLocationManager()
    coreLocationManager.delegate = self
    coreLocationManager.requestWhenInUseAuthorization()
    
    telefonoText.delegate = self
    claveText.delegate = self
    correoText.delegate = self
    self.movilClaveRecover.delegate = self
    confirmarClavText.delegate = self
    Clave.delegate = self
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ocultarTeclado))
    
    self.DatosView.addGestureRecognizer(tapGesture)
    self.ClaveRecover.addGestureRecognizer(tapGesture)
    self.RegistroView.addGestureRecognizer(tapGesture)
    self.view.addGestureRecognizer(tapGesture)
    //Put Background image to View
    //self.loginBackView.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
    
    //Calculate the custom constraints
    if UIScreen.main.bounds.height < 736{
      self.textFieldHeight.constant = 40
    }else{
      self.textFieldHeight.constant = 45
    }
    
    let spaceBetween = (UIScreen.main.bounds.height - self.textFieldHeight.constant * 9) / 15
    
    self.claveTextBottom.constant = -spaceBetween
    self.telefonoTextBottom.constant = -spaceBetween
    self.nombreTextBottom.constant = -spaceBetween
    self.creaUsuarioBottom.constant = -spaceBetween
    
    self.correoTextTop.constant = spaceBetween
    
    self.movilClaveRecoverHeight.constant = 40
    
    //        if CConexionInternet.isConnectedToNetwork() == true{
    //            myvariables.socket = self.socketIOManager.defaultSocket
    //            myvariables.socket.connect()
    //
    //            myvariables.socket.on("connect"){data, ack in
    //                var loginData = "Vacio"
    //                let filePath = NSHomeDirectory() + "/Library/Caches/log.txt"
    //                do {
    //                    loginData = try NSString(contentsOfFile: filePath, encoding: String.Encoding.utf8.rawValue) as String
    //                }catch {
    //                }
    //                if loginData != "Vacio"{
    //                    self.Login(loginData: loginData)
    //                }else{
    //                    self.AutenticandoView.isHidden = true
    //                }
    //                self.SocketEventos()
    //            }
    //        }else{
    //            ErrorConexion()
    //        }
    self.telefonoText.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    
  }
  
  func connectToSocket(){
    //print(Customization.serverData!)
    self.socketIOManager = SocketManager(socketURL: URL(string: Customization.serverData! )!, config: [.log(false), .forcePolling(true)]) //Customization.serverData
    
    if CConexionInternet.isConnectedToNetwork() == true{
      myvariables.socket = self.socketIOManager.socket(forNamespace: "/")
      
      myvariables.socket.connect()
      
      self.SocketEventos()
    }else{
      ErrorConexion()
    }
  }
  
  
  //FUNCION PARA LISTAR SOLICITUDES PENDIENTES
  func ListSolicitudPendiente(_ listado : [String]){
    //#LoginPassword,loginok,idusuario,idrol,idcliente,nombreapellidos,cantsolpdte,idsolicitud,idtaxi,cod,fechahora,lattaxi,lngtaxi, latorig,lngorig,latdest,lngdest,telefonoconductor
    
    var lattaxi = String()
    var longtaxi = String()
    var i = 7
    
    while i <= listado.count-10 {
      var solicitudpdte = CSolicitud()
      if listado[i+4] == "null"{
        lattaxi = "0"
        longtaxi = "0"
      }else{
        lattaxi = listado[i + 4]
        longtaxi = listado[i + 5]
      }
      solicitudpdte.idSolicitud = listado[i]
      solicitudpdte.DatosCliente(cliente: myvariables.cliente)
      solicitudpdte.DatosSolicitud(dirorigen: "", referenciaorigen: "", dirdestino: "", latorigen: listado[i + 6], lngorigen: listado[i + 7], latdestino: listado[i + 8], lngdestino: listado[i + 9],FechaHora: listado[i + 3])
      solicitudpdte.DatosTaxiConductor(idtaxi: listado[i + 1], matricula: "", codigovehiculo: listado[i + 2], marcaVehiculo: "", colorVehiculo: "", lattaxi: lattaxi, lngtaxi: longtaxi, idconductor: "", nombreapellidosconductor: "", movilconductor: listado[i + 10], foto: "")
      myvariables.solpendientes.append(solicitudpdte)
      if solicitudpdte.idTaxi != ""{
        myvariables.solicitudesproceso = true
      }
      i += 11
    }
  }
  
  
  //MARK:- FUNCIONES PROPIAS
  
  func Login(loginData: String){
    self.AutenticandoView.isHidden = false
    self.login = String(loginData).components(separatedBy: ",")
    EnviarSocket(loginData)
    //self.EnviarTimer(estado: 1, datos: loginData)
  }
  
  //FUNCTION ENVIO CON TIMER
  func EnviarTimer(estado: Int, datos: String){
    if estado == 1{
      if !self.emitTimer.isValid{
        self.emitTimer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(EnviarSocket1(_:)), userInfo: ["datos": datos], repeats: true)
      }
    }else{
      self.emitTimer.invalidate()
      self.EnviosCount = 0
    }
  }
  
  //FUNCIÓN ENVIAR AL SOCKET
  func EnviarSocket(_ datos: String){
    if CConexionInternet.isConnectedToNetwork() == true{
      if myvariables.socket.status.active{
        myvariables.socket.emit("data",datos)
        self.EnviarTimer(estado: 1, datos: datos)
      }
      else{
        let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor intentar otra vez.", preferredStyle: UIAlertController.Style.alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
          exit(0)
        }))
        
        self.present(alertaDos, animated: true, completion: nil)
      }
    }else{
      self.ErrorConexion()
    }
  }
  
  @objc func EnviarSocket1(_ timer: Timer){
    if CConexionInternet.isConnectedToNetwork() == true{
      if myvariables.socket.status.active && self.EnviosCount <= 3 {
        self.EnviosCount += 1
        let userInfo = timer.userInfo as! Dictionary<String, AnyObject>
        let datos: String = (userInfo["datos"] as! String)
        myvariables.socket.emit("data",datos)
        //let result = myvariables.socket.emitWithAck("data", datos)
      }else{
        let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor intentar otra vez.", preferredStyle: UIAlertController.Style.alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
          exit(0)
        }))
        self.present(alertaDos, animated: true, completion: nil)
      }
    }else{
      ErrorConexion()
    }
  }
  
  func ErrorConexion(){
    let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor revise su conexión a Internet.", preferredStyle: UIAlertController.Style.alert)
    alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
      exit(0)
    }))
    self.present(alertaDos, animated: true, completion: nil)
  }
  
  
  //MARK:- ACCIONES DE LOS BOTONES
  //LOGIN Y REGISTRO DE CLIENTE
  @IBAction func Autenticar(_ sender: AnyObject) {
    
    let loginData = "#LoginPassword," + self.Usuario.text! + "," + self.Clave.text! + ",# \n"
    
    myvariables.userDefaults.set(loginData, forKey: "\(Customization.nameShowed)-loginData")
    
    self.Clave.endEditing(true)
    self.Clave.text?.removeAll()
    //CREAR EL FICHERO DE LOGÍN
    //        let filePath = NSHomeDirectory() + "/Library/Caches/log.txt"
    //        do {
    //            _ = try loginData.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
    //
    //        } catch {
    //
    //        }
    self.Login(loginData: loginData)
  }
  
  @IBAction func OlvideClave(_ sender: AnyObject) {
    ClaveRecover.isHidden = false
    self.movilClaveRecover.becomeFirstResponder()
  }
  
  @IBAction func RecuperarClave(_ sender: AnyObject) {
    //"#Recuperarclave,numero de telefono,#"
    if !self.movilClaveRecover.text!.isEmpty{
      self.Usuario.resignFirstResponder()
      self.Clave.resignFirstResponder()
      let recuperarDatos = "#Recuperarclave," + movilClaveRecover.text! + ",# \n"
      EnviarSocket(recuperarDatos)
      //self.EnviarTimer(estado: 1, datos: recuperarDatos)
      ClaveRecover.isHidden = true
      movilClaveRecover.endEditing(true)
      movilClaveRecover.text?.removeAll()
    }else{
      let alertaDos = UIAlertController (title: "Recuperar Clave", message: "Debe llenar todos los campos del formulario", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        self.movilClaveRecover.becomeFirstResponder()
      }))
      
      self.present(alertaDos, animated: true, completion: nil)
    }
  }
  
  @IBAction func CancelRecuperarclave(_ sender: AnyObject) {
    ClaveRecover.isHidden = true
    self.movilClaveRecover.endEditing(true)
    self.movilClaveRecover.text?.removeAll()
  }
  
  @IBAction func RegistrarCliente(_ sender: AnyObject) {
    self.Usuario.resignFirstResponder()
    self.Clave.resignFirstResponder()
    RegistroView.isHidden = false
    self.nombreApText.becomeFirstResponder()
    
  }
  @IBAction func EnviarRegistro(_ sender: AnyObject) {
    if (nombreApText.text!.isEmpty || telefonoText.text!.isEmpty || claveText.text!.isEmpty) {
      let alertaDos = UIAlertController (title: "Registro de Usuario", message: "Debe llenar todos los campos del formulario", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        self.RegistroView.isHidden = false
        self.nombreApText.becomeFirstResponder()
      }))
      
      self.present(alertaDos, animated: true, completion: nil)
    }else{
      //let temporal = "," + telefonoText.text! + "," + telefonoText.text! + "," + claveText.text!
      var correo = ",Sin correo"
      if !(correoText.text?.isEmpty)!{
        correo = "," + correoText.text!
      }
//      if let posTemp = coreLocationManager.location{
//        posicion = String(posTemp.coordinate.latitude) + "," + String(posTemp.coordinate.longitude)
//      }
      let registroDatos = "#Registro,\(nombreApText.text!),\(telefonoText.text!),\(telefonoText.text!),\(claveText.text!),\(correo),# \n"
      myvariables.socket.emit("data", registroDatos)
      //self.EnviarTimer(estado: 1, datos: registroDatos)
    }
    RegistroView.isHidden = true
    claveText.resignFirstResponder()
    confirmarClavText.resignFirstResponder()
    correoText.resignFirstResponder()

  }
  
  @IBAction func CancelarRegistro(_ sender: AnyObject) {
    RegistroView.isHidden = true
    claveText.endEditing(true)
    confirmarClavText.endEditing(true)
    correoText.endEditing(true)
    nombreApText.text?.removeAll()
    telefonoText.text?.removeAll()
    
    claveText.text?.removeAll()
    confirmarClavText.text?.removeAll()
    correoText.text?.removeAll()
  }
  
  
  
}

//extension LoginController: XMLParserDelegate {
//    func parserDidEndDocument(_ parser: XMLParser) {
//        //print("Person str is:: " + self.serverStr)
//        //TODO: You have to build your json object from the PersonStr now
//    }
//    func parser(_ parser: XMLParser, foundCharacters string: String) {
//        currentValue += string
//    }
//
//    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
//        if elementName == "untaxi" {
//            self.recordKey = "untaxi"
//            self.currentDictionary = [String : String]()
//        } else if dictionaryKeys.contains(elementName) {
//            self.currentValue = String()
//        }
//    }
//
//    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
//        if elementName == "cliente"{
//            if self.recordKey == "untaxi"{
//            self.results.append(self.currentDictionary)
//            self.currentDictionary = [String:String]()
//                self.recordKey = ""
//            }
//        } else if dictionaryKeys.contains(elementName) {
//            self.currentDictionary[elementName] = currentValue
//            self.currentValue = ""
//        }
//    }
//    // Just in case, if there's an error, report it. (We don't want to fly blind here.)
//
//    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
//        self.currentValue = ""
//        self.currentDictionary = [String:String]()
//        self.results = [[String:String]]()
//    }
//
//    func ServerSelect(completionHandler:@escaping (Bool)->()){
//        let url = NSURL(string: "http://www.xoait.com/dirtablesios.xml")
//        let ServerXml = XMLParser(contentsOf: url! as URL)
//        //print(ServerXml)
//        ServerXml?.delegate = self
//        let result = ServerXml?.parse()
//        var writeString = "http://www.xoait.com:5803"
//        if result!{
//            for server in results {
//                writeString = server["ip"]!+":"+server["p"]!+","
//            }
//            //CREAR EL FICHERO DE LOGÍN
//        }
//        let filePath = NSHomeDirectory() + "/Library/Caches/servers.txt"
//
//        do {
//            _ = try writeString.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
//        } catch {
//
//        }
//        self.ServersData = String(describing: writeString).components(separatedBy: ",")
//        completionHandler(true)
//    }
//    func ServerConect(completionHandler:@escaping (Bool)->()){
//        var i = 0
//        while i < self.ServersData.count - 1{
//            myvariables.socket = self.socketIOManager.defaultSocket
//            myvariables.socket.connect()
//            i += 1
//        }
//        completionHandler(true)
//    }
//}
