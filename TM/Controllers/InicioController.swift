//
//  InicioController.swift
//  UnTaxi
//
//  Created by Done Santana on 2/3/17.
//  Copyright © 2017 Done Santana. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import SocketIO
import Canvas
import AddressBook
import AVFoundation
import CoreData
import GoogleMobileAds

struct MenuData {
  var imagen: String
  var title: String
}

class InicioController: UIViewController, CLLocationManagerDelegate, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate, UIApplicationDelegate, UIGestureRecognizerDelegate {
  var coreLocationManager : CLLocationManager!
  var miposicion = MKPointAnnotation()
  var origenAnotacion = MKPointAnnotation()
  var taxiLocation = MKPointAnnotation()
  var taxi : CTaxi!
  var login = [String]()
  var idusuario : String = ""
  var indexselect = Int()
  var contador = 0
  var centro = CLLocationCoordinate2D()
  var TelefonosCallCenter = [CTelefono]()
  var opcionAnterior : IndexPath!
  var evaluacion: CEvaluacion!
  var tipoTransporte: String!
  
  //var SMSVoz = CSMSVoz()
  
  //Reconect Timer
  var timer = Timer()
  //var fechahora: String!
  
  
  
  //Timer de Envio
  var EnviosCount = 0
  var emitTimer = Timer()
  
  var keyboardHeight:CGFloat!
  
  var DireccionesArray = [[String]]()//[["Dir 1", "Ref1"],["Dir2","Ref2"],["Dir3", "Ref3"],["Dir4","Ref4"],["Dir 5", "Ref5"]]//["Dir 1", "Dir2"]
  
  //Menu variables
  var MenuArray = [MenuData(imagen: "solicitud", title: "En proceso"), MenuData(imagen: "callCenter", title: "Operadora"),MenuData(imagen: "clave", title: "Perfil"),MenuData(imagen: "infoMenu", title: "Información"),MenuData(imagen: "transporteMenu", title: "Tipo de Transporte"),MenuData(imagen: "compartir", title: "Compartir app"), MenuData(imagen: "sesion", title: "Cerrar Sesion"), MenuData(imagen: "salir2", title: "Salir")]
  //variables de interfaz
  
  
  //CONSTRAINTS
  var btnViewTop: NSLayoutConstraint!
  
  @IBOutlet weak var origenIcono: UIImageView!
  @IBOutlet weak var mapaVista: MKMapView!
  @IBOutlet weak var adsBannerView: GADBannerView!

  @IBOutlet weak var transportIcon: UIImageView!

  @IBOutlet weak var LocationBtn: UIButton!
  @IBOutlet weak var SolicitarBtn: UIButton!
  @IBOutlet weak var formularioSolicitud: UIView!
  @IBOutlet weak var SolicitudView: CSAnimationView!
  
  
  //MENU BUTTONS
  @IBOutlet weak var MenuView1: UIView!
  @IBOutlet weak var MenuTable: UITableView!
  @IBOutlet weak var NombreUsuario: UILabel!
  @IBOutlet weak var TransparenciaView: UIVisualEffectView!
  
  
  @IBOutlet weak var SolPendientesView: UIView!
  
  
  
  @IBOutlet weak var AlertaEsperaView: UIView!
  @IBOutlet weak var MensajeEspera: UITextView!

  
  @IBOutlet weak var CancelarSolicitudProceso: UIButton!
  
  @IBOutlet weak var solicitudFormTable: UITableView!
  
  //CUSTOM CONSTRAINTS
//  @IBOutlet weak var textFieldHeight: NSLayoutConstraint!
//  //@IBOutlet weak var recordarViewBottom: NSLayoutConstraint!
//  //@IBOutlet weak var origenTextBottom: NSLayoutConstraint!
//  @IBOutlet weak var datosSolictudBottom: NSLayoutConstraint!
//  @IBOutlet weak var contactoViewTop: NSLayoutConstraint!
//  @IBOutlet weak var contactViewHeight: NSLayoutConstraint!
//  @IBOutlet weak var voucherViewTop: NSLayoutConstraint!
  
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    //LECTURA DEL FICHERO PARA AUTENTICACION
    
    mapaVista.delegate = self
    coreLocationManager = CLLocationManager()
    coreLocationManager.delegate = self
    self.referenciaText.delegate = self
    self.NombreContactoText.delegate = self
    self.TelefonoContactoText.delegate = self
    self.origenText.delegate = self
    self.destinoText.delegate = self
    self.solicitudFormTable.delegate = self
    
    self.navigationItem.title = Customization.nameShowed
    
    //solicitud de autorización para acceder a la localización del usuario
    self.NombreUsuario.text = myvariables.cliente.nombreApellidos
    self.NombreUsuario.textColor = .white
    self.MenuTable.delegate = self
    self.MenuView1.layer.borderColor = UIColor.lightGray.cgColor
    self.MenuView1.layer.borderWidth = 0.3
    self.MenuView1.layer.masksToBounds = false
    self.NombreContactoText.setBottomBorder(borderColor: UIColor.lightGray)
    self.TelefonoContactoText.setBottomBorder(borderColor: UIColor.lightGray)
    
    self.MenuView1.backgroundColor = Customization.primaryColor
    self.SolPendientesView.backgroundColor = Customization.primaryColor
    
    coreLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    coreLocationManager.startUpdatingLocation()  //Iniciar servicios de actualiación de localización del usuario
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ocultarTeclado))
    tapGesture.delegate = self
    self.SolicitudView.addGestureRecognizer(tapGesture)
    
    let MenuTapGesture = UITapGestureRecognizer(target: self, action: #selector(ocultarMenu))
    self.TransparenciaView.addGestureRecognizer(MenuTapGesture)
    
    self.transportIcon.image = UIImage(named: self.tipoTransporte)
    
//    //Calculate the custom constraints
//    var spaceBetween = CGFloat(20)
//    if UIScreen.main.bounds.height < 736{
//      self.textFieldHeight.constant = 40
//      spaceBetween = 10
//    }else{
//      self.textFieldHeight.constant = 45
//    }
//
//    //self.recordarViewBottom.constant = -spaceBetween
//    //self.origenTextBottom.constant = -spaceBetween
//    self.datosSolictudBottom.constant = -spaceBetween
//    self.contactoViewTop.constant = spaceBetween
//    self.voucherViewTop.constant = spaceBetween
    
    if let tempLocation = self.coreLocationManager.location?.coordinate{
      self.origenAnotacion.coordinate = (coreLocationManager.location?.coordinate)!
      self.origenAnotacion.title = "origen"
    }else{
      coreLocationManager.requestWhenInUseAuthorization()
      self.origenAnotacion.coordinate = (CLLocationCoordinate2D(latitude: -2.173714, longitude: -79.921601))
    }
    
    let span = MKCoordinateSpan.init(latitudeDelta: 0.005, longitudeDelta: 0.005)
    let region = MKCoordinateRegion(center: self.origenAnotacion.coordinate, span: span)
    self.mapaVista.setRegion(region, animated: true)
    
    if myvariables.socket.status.active{
      let ColaHilos = OperationQueue()
      let Hilos : BlockOperation = BlockOperation (block: {
        self.SocketEventos()
        self.timer.invalidate()
        let url = "#U,# \n"
        self.EnviarSocket(url)
        let telefonos = "#Telefonos,# \n"
        self.EnviarSocket(telefonos)
        let datos = "OT"
        self.EnviarSocket(datos)
      })
      ColaHilos.addOperation(Hilos)
    }else{
      self.Reconect()
    }
    
    //self.referenciaText.enablesReturnKeyAutomatically = false
    //self.origenText.delegate = self
    self.TablaDirecciones.delegate = self
    
    self.origenText.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    
    //PEDIR PERMISO PARA EL MICROPHONO
    switch AVAudioSession.sharedInstance().recordPermission {
    case AVAudioSession.RecordPermission.granted:
      print("Permission granted")
    case AVAudioSession.RecordPermission.denied:
      print("Pemission denied")
    case AVAudioSession.RecordPermission.undetermined:
      AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
        if granted {
          
        } else{
          
        }
      })
    default:
      break
    }
     self.addEnvirSolictudBtn()
    
  }
  
  override func viewDidAppear(_ animated: Bool){
    self.NombreContactoText.setBottomBorder(borderColor: UIColor.black)
    self.TelefonoContactoText.setBottomBorder(borderColor: UIColor.black)
    self.btnViewTop = NSLayoutConstraint(item: self.BtnsView, attribute: .top, relatedBy: .equal, toItem: self.origenText, attribute: .bottom, multiplier: 1, constant: 0)
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    self.miposicion.coordinate = (locations.last?.coordinate)!
    self.SolicitarBtn.isHidden = false
  }
  
  
  
  //MARK:- FUNCIONES PROPIAS
  
  func appUpdateAvailable() -> Bool
  {
    let storeInfoURL: String = GlobalConstants.storeInfoURL
    var upgradeAvailable = false
    
    // Get the main bundle of the app so that we can determine the app's version number
    let bundle = Bundle.main
    if let infoDictionary = bundle.infoDictionary {
      // The URL for this app on the iTunes store uses the Apple ID for the  This never changes, so it is a constant
      let urlOnAppStore = URL(string: storeInfoURL)
      if let dataInJSON = try? Data(contentsOf: urlOnAppStore!) {
        // Try to deserialize the JSON that we got
        if let lookupResults = try? JSONSerialization.jsonObject(with: dataInJSON, options: JSONSerialization.ReadingOptions()) as! Dictionary<String, Any>{
          // Determine how many results we got. There should be exactly one, but will be zero if the URL was wrong
          if let resultCount = lookupResults["resultCount"] as? Int {
            if resultCount == 1 {
              // Get the version number of the version in the App Store
              //self.selectedRoute = (dictionary["routes"] as! Array<Dictionary<String, AnyObject>>)[0]
              if let appStoreVersion = (lookupResults["results"]as! Array<Dictionary<String, AnyObject>>)[0]["version"] as? String {
                // Get the version number of the current version
                if let currentVersion = infoDictionary["CFBundleShortVersionString"] as? String {
                  // Check if they are the same. If not, an upgrade is available.
                  if appStoreVersion > currentVersion {
                    upgradeAvailable = true
                  }
                }
              }
            }
          }
        }
      }
    }
    ///Volumes/Datos/Ecuador/Desarrollo/UnTaxi/UnTaxi/LocationManager.swift:635:31: Ambiguous use of 'indexOfObject'
    return upgradeAvailable
  }
  
  
  
  //RECONECT SOCKET
  @objc func Reconect(){
    if contador <= 5 {
      myvariables.socket.connect()
      contador += 1
    }
    else{
      let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor intentar otra vez.", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        exit(0)
      }))
      self.present(alertaDos, animated: true, completion: nil)
    }
  }
  
  //FUNCTION ENVIO CON TIMER
  func EnviarTimer(estado: Int, datos: String){
    if estado == 1{
      self.EnviarSocket(datos)
      if !self.emitTimer.isValid{
        self.emitTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(EnviarSocket1(_:)), userInfo: ["datos": datos], repeats: true)
      }
    }else{
      self.emitTimer.invalidate()
      self.EnviosCount = 0
    }
  }
  
  //FUNCIÓN ENVIAR AL SOCKET
  @objc func EnviarSocket(_ datos: String){
    if CConexionInternet.isConnectedToNetwork() == true{
      if myvariables.socket.status.active && self.EnviosCount <= 3{
        myvariables.socket.emit("data",datos)
        //self.EnviarTimer(estado: 1, datos: datos)
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
  
  @objc func EnviarSocket1(_ timer: Timer){
    if CConexionInternet.isConnectedToNetwork() == true{
      if myvariables.socket.status.active && self.EnviosCount <= 3 {
        self.EnviosCount += 1
        let userInfo = timer.userInfo as! Dictionary<String, AnyObject>
        var datos = (userInfo["datos"] as! String)
        myvariables.socket.emit("data",datos)
      }else{
        let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor intentar otra vez.", preferredStyle: UIAlertController.Style.alert)
        alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
          self.EnviarTimer(estado: 0, datos: "Terminado")
          exit(0)
        }))
        self.present(alertaDos, animated: true, completion: nil)
      }
    }else{
      ErrorConexion()
    }
  }
  
  //FUNCIONES ESCUCHAR SOCKET
  func ErrorConexion(){
    //self.CargarTelefonos()
    //AlertaSinConexion.isHidden = false
    
    let alertaDos = UIAlertController (title: "Sin Conexión", message: "No se puede conectar al servidor por favor revise su conexión a Internet.", preferredStyle: UIAlertController.Style.alert)
    alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
      exit(0)
    }))
    self.present(alertaDos, animated: true, completion: nil)
  }
  
  func Inicio(){
    mapaVista.removeAnnotations(self.mapaVista.annotations)
    self.view.endEditing(true)
    self.coreLocationManager.startUpdatingLocation()
    self.origenAnotacion.coordinate = (self.coreLocationManager.location?.coordinate)!
    self.origenIcono.image = UIImage(named: "origen2")
    self.origenIcono.isHidden = true
    self.origenAnotacion.title = "origen"
    let span = MKCoordinateSpan.init(latitudeDelta: 0.005, longitudeDelta: 0.005)
    let region = MKCoordinateRegion(center: self.origenAnotacion.coordinate, span: span)
    self.mapaVista.setRegion(region, animated: true)
    self.mapaVista.addAnnotation(self.origenAnotacion)
    
    self.formularioSolicitud.isHidden = true
    self.SolicitarBtn.isHidden = false
    SolPendientesView.isHidden = true
    CancelarSolicitudProceso.isHidden = true
    AlertaEsperaView.isHidden = true
  }
  
  //DIRECCIONES FAVORITAS
  func CargarFavoritas(){
    let path = NSHomeDirectory() + "/Library/Caches/"
    let url = NSURL(fileURLWithPath: path)
    let filePath = url.appendingPathComponent("dir.plist")?.path
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: filePath!) {
      let filePath = NSURL(fileURLWithPath: NSHomeDirectory() + "/Library/Caches/dir.plist") as URL
      do {
        self.DireccionesArray = NSArray(contentsOf: filePath) as! [[String]]
      }catch{
        
      }
    }
  }
  
  func GuardarFavorita(newFavorita: [String]){
    self.DireccionesArray.append(newFavorita)
    //CREAR EL FICHERO DE LOGÍN
    let filePath = NSURL(fileURLWithPath: NSHomeDirectory() + "/Library/Caches/dir.plist")
    
    do {
      _ = try (self.DireccionesArray as NSArray).write(to: filePath as URL, atomically: true)
      
    } catch {
      
    }
  }
  
  func EliminarFavorita(posFavorita: Int){
    self.DireccionesArray.remove(at: posFavorita)
    //CREAR EL FICHERO DE LOGÍN
    let filePath = NSURL(fileURLWithPath: NSHomeDirectory() + "/Library/Caches/dir.plist")
    
    do {
      _ = try (self.DireccionesArray as NSArray).write(to: filePath as URL, atomically: true)
    } catch {
      
    }
  }
  
  
  //FUNCION PARA LISTAR SOLICITUDES PENDIENTES
  func ListSolicitudPendiente(_ listado : [String]){
    //#LoginPassword,loginok,idusuario,idrol,idcliente,nombreapellidos,cantsolpdte,idsolicitud,idtaxi,cod,fechahora,lattaxi,lngtaxi, latorig,lngorig,latdest,lngdest,telefonoconductor
    print("pendiente pinga \(listado)")
    var lattaxi = String()
    var longtaxi = String()
    var i = 7
    
    while i <= listado.count-10 {
      let solicitudpdte = CSolicitud()
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
      if listado[i + 1] != "null"{
        solicitudpdte.DatosTaxiConductor(idtaxi: listado[i + 1], matricula: "", codigovehiculo: listado[i + 2], marcaVehiculo: "", colorVehiculo: "", lattaxi: lattaxi, lngtaxi: longtaxi, idconductor: "", nombreapellidosconductor: "", movilconductor: listado[i + 10], foto: "")
      }
      myvariables.solpendientes.append(solicitudpdte)
      if solicitudpdte.idTaxi != ""{
        myvariables.solicitudesproceso = true
      }
      i += 11
    }
  }
  
  //Funcion para Mostrar Datos del Taxi seleccionado
  func AgregarTaxiSolicitud(_ temporal : [String]){
    //#Aceptada, idsolicitud, idconductor, nombreApellidosConductor, movilConductor, URLfoto, idTaxi, Codvehiculo, matricula, marca_modelo, color, latTaxi, lngTaxi
    for solicitud in myvariables.solpendientes{
      if solicitud.idSolicitud == temporal[1]{
        myvariables.solicitudesproceso = true
        solicitud.DatosTaxiConductor(idtaxi: temporal[6], matricula: temporal[8], codigovehiculo: temporal[7], marcaVehiculo: temporal[9],colorVehiculo: temporal[10], lattaxi: temporal[11], lngtaxi: temporal[12], idconductor: temporal[2], nombreapellidosconductor: temporal[3], movilconductor: temporal[4], foto: temporal[5])
      }
    }
  }
  
  
  //FUNCIÓN BUSCA UNA SOLICITUD DENTRO DEL ARRAY DE SOLICITUDES PENDIENTES DADO SU ID
  func BuscarSolicitudID(_ id : String)->CSolicitud{
    var temporal : CSolicitud!
    for solicitudpdt in myvariables.solpendientes{
      if solicitudpdt.idSolicitud == id{
        temporal = solicitudpdt
      }
    }
    return temporal
  }
  //devolver posicion de solicitud
  func BuscarPosSolicitudID(_ id : String)->Int{
    var temporal = 0
    var posicion = -1
    for solicitudpdt in myvariables.solpendientes{
      if solicitudpdt.idSolicitud == id{
        posicion = temporal
      }
      temporal += 1
    }
    return posicion
  }
  
  //Respuesta de solicitud
  func ConfirmaSolicitud(_ Temporal : [String]){
    //Trama IN: #Solicitud, ok, idsolicitud, fechahora
    
    if Temporal[1] == "ok"{
      myvariables.solpendientes.last!.RegistrarFechaHora(IdSolicitud: Temporal[2], FechaHora: Temporal[3])
    }
    else{
      if Temporal[1] == "error"{
        
      }
    }
  }
  //FUncion para mostrar los taxis
  func MostrarTaxi(_ temporal : [String]){
    //TRAMA IN: #Posicion,idtaxi,lattaxi,lngtaxi
    var i = 2
    var taxiscercanos = [MKPointAnnotation]()
    while i  <= temporal.count - 6{
      let taxiTemp = MKPointAnnotation()
      taxiTemp.coordinate = CLLocationCoordinate2DMake(Double(temporal[i + 2])!, Double(temporal[i + 3])!)
      taxiTemp.title = temporal[i]
      taxiscercanos.append(taxiTemp)
      i += 6
    }
    DibujarIconos(taxiscercanos)
  }
  
  
  //CREAR SOLICITUD CON LOS DATOS DEL CIENTE, SU LOCALIZACIÓN DE ORIGEN Y DESTINO
  func CrearSolicitud(_ nuevaSolicitud: CSolicitud, voucher: String){
    //#Solicitud, idcliente, nombrecliente, movilcliente, dirorig, referencia, dirdest,latorig,lngorig, latdest, lngdest, distancia, costo, #
    formularioSolicitud.isHidden = true
    origenIcono.isHidden = true
    myvariables.solpendientes.append(nuevaSolicitud)
    
    let datoscliente = nuevaSolicitud.idCliente + "," + nuevaSolicitud.nombreApellidos + "," + nuevaSolicitud.user
    let datossolicitud = nuevaSolicitud.dirOrigen + "," + nuevaSolicitud.referenciaorigen + "," + "null"
    let datosgeo = String(nuevaSolicitud.distancia) + "," + nuevaSolicitud.costo
    let Datos = "#Solicitud" + "," + datoscliente + "," + datossolicitud + "," + String(nuevaSolicitud.origenCarrera.latitude) + "," + String(nuevaSolicitud.origenCarrera.longitude) + "," + "0.0" + "," + "0.0" + "," + datosgeo + "," + voucher + ",# \n"
    //EnviarSocket(Datos)
    self.EnviarTimer(estado: 1, datos: Datos)
    MensajeEspera.text = "Procesando..."
    self.AlertaEsperaView.isHidden = false
    self.origenText.text?.removeAll()
    self.RecordarSwitch.isOn = false
    self.referenciaText.text?.removeAll()
  }
  
  
  
  //CANCELAR SOLICITUDES
  func MostrarMotivoCancelacion(){
    //["No necesito","Demora el servicio","Tarifa incorrecta","Solo probaba el servicio", "Cancelar"]
    let motivoAlerta = UIAlertController(title: "", message: "Seleccione el motivo de cancelación.", preferredStyle: UIAlertController.Style.actionSheet)
    motivoAlerta.addAction(UIAlertAction(title: "No necesito", style: .default, handler: { action in
      
      self.CancelarSolicitudes("No necesito")
      
    }))
    motivoAlerta.addAction(UIAlertAction(title: "Demora el servicio", style: .default, handler: { action in
      
      self.CancelarSolicitudes("Demora el servicio")
      
    }))
    motivoAlerta.addAction(UIAlertAction(title: "Tarifa incorrecta", style: .default, handler: { action in
      
      self.CancelarSolicitudes("Tarifa incorrecta")
      
    }))
    motivoAlerta.addAction(UIAlertAction(title: "Vehículo en mal estado", style: .default, handler: { action in
      
      self.CancelarSolicitudes("Vehículo en mal estado")
      
    }))
    motivoAlerta.addAction(UIAlertAction(title: "Solo probaba el servicio", style: .default, handler: { action in
      
      self.CancelarSolicitudes("Solo probaba el servicio")
      
    }))
    motivoAlerta.addAction(UIAlertAction(title: "Cancelar", style: UIAlertAction.Style.destructive, handler: { action in
    }))
    self.present(motivoAlerta, animated: true, completion: nil)
  }
  
  /*func CancelarSolicitudes(_ motivo: String){
   //#Cancelarsolicitud, idSolicitud, idTaxi, motivo, "# \n"
   let temp = (myvariables.solpendientes.last?.idTaxi)! + "," + motivo + "," + "# \n"
   let Datos = "#Cancelarsolicitud" + "," + (myvariables.solpendientes.last?.idSolicitud)! + "," + temp
   myvariables.solpendientes.removeLast()
   if myvariables.solpendientes.count == 0 {
   self.SolPendImage.isHidden = true
   CantSolPendientes.isHidden = true
   myvariables.solicitudesproceso = false
   }
   if motivo != "Conductor"{
   EnviarSocket(Datos)
   }
   }*/
  
  func CancelarSolicitudes(_ motivo: String){
    //#Cancelarsolicitud, idSolicitud, idTaxi, motivo, "# \n"
    //let temp = (myvariables.solpendientes.last?.idTaxi)! + "," + motivo + "," + "# \n"
    let Datos = "#Cancelarsolicitud" + "," + (myvariables.solpendientes.last?.idSolicitud)! + "," + "null" + "," + motivo + "," + "# \n"
    myvariables.solpendientes.removeLast()
    if myvariables.solpendientes.count == 0 {
      myvariables.solicitudesproceso = false
    }
    if motivo != "Conductor"{
      EnviarSocket(Datos)
    }
  }
  
  func CloseAPP(){
    let fileAudio = FileManager()
    let AudioPath = NSHomeDirectory() + "/Library/Caches/Audio"
    do {
      try fileAudio.removeItem(atPath: AudioPath)
    }catch{
    }
    let datos = "#SocketClose," + myvariables.cliente.idCliente + ",# \n"
    EnviarSocket(datos)
    exit(3)
  }
  
  
  //FUNCION PARA DIBUJAR LAS ANOTACIONES
  
  func DibujarIconos(_ anotaciones: [MKPointAnnotation]){
    if anotaciones.count == 1{
      self.mapaVista.addAnnotations([self.origenAnotacion,anotaciones[0]])
      self.mapaVista.fitAll(in: self.mapaVista.annotations, andShow: true)
    }else{
      self.mapaVista.addAnnotations(anotaciones)
      self.mapaVista.fitAll(in: anotaciones, andShow: true)
    }
  }
  
  
  //Validar los formularios
  func SoloLetras(name: String) -> Bool {
    // (1):
    let pat = "[0-9,.!@#$%^&*()_+-]"
    // (2):
    //let testStr = "x.wu@strath.ac.uk, ak123@hotmail.com     e1s59@oxford.ac.uk, ee123@cooleng.co.uk, a.khan@surrey.ac.uk"
    // (3):
    let regex = try! NSRegularExpression(pattern: pat, options: [])
    // (4):
    let matches = regex.matches(in: name, options: [], range: NSRange(location: 0, length: name.count))
    print(matches.count)
    if matches.count == 0{
      return true
    }else{
      return false
    }
  }
  
  @objc func ocultarMenu(){
    self.MenuView1.isHidden = true
    self.TransparenciaView.isHidden = true
    self.Inicio()
  }
  
  //ADD FOOTER TO SOLICITDFORMTABLE
  func addEnvirSolictudBtn(){
    let enviarBtnView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 35))
    let button:UIButton = UIButton.init(frame: CGRect(x: 0, y: 15, width: UIScreen.main.bounds.width, height: 20))
    button.setTitleColor(UIColor.darkGray, for: .normal)
    button.setTitle("ENVIAR SOLICITUD", for: .normal)
    button.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 20)
    button.addTarget(self, action: #selector(self.enviarSolicitud), for: .touchUpInside)
    let separatorView = UIView(frame: CGRect(x: 5, y: 0, width: UIScreen.main.bounds.width - 5, height: 1))
    separatorView.backgroundColor = .darkGray
    enviarBtnView.addSubview(separatorView)
    enviarBtnView.addSubview(button)
    self.solicitudFormTable.tableFooterView = enviarBtnView
  }
  
  @objc func enviarSolicitud(){
    if !self.destinoText.isHidden && self.destinoText.text!.isEmpty{
      let alertaDos = UIAlertController (title: "Dirección de Destino", message: "Si desea pagar con Voucher necesita escribir su dirección de Destino.", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        self.destinoText.becomeFirstResponder()
      }))
      self.present(alertaDos, animated: true, completion: nil)
    }else{
      if !(self.origenText.text?.isEmpty)! {
        var voucher = "0"
        let origen = self.cleanTextField(textfield: self.origenText)
        
        let referencia = self.cleanTextField(textfield: self.referenciaText)
        
        let destino = self.cleanTextField(textfield: self.destinoText)
        
        let nombreContactar = self.NombreContactoText.text!.isEmpty ? myvariables.cliente.nombreApellidos : self.cleanTextField(textfield: self.NombreContactoText)
        
        let telefonoContactar = self.TelefonoContactoText.text!.isEmpty ? myvariables.cliente.user : self.cleanTextField(textfield: self.TelefonoContactoText)
        
        let clienteSolicitud = self.NombreContactoText.text!.isEmpty ? myvariables.cliente : CCliente(idUsuario: myvariables.cliente.idUsuario, idcliente: myvariables.cliente.idCliente, user: telefonoContactar!, nombre: nombreContactar!, email: myvariables.cliente.email, empresa: myvariables.cliente.empresa)
        
        mapaVista.removeAnnotations(mapaVista.annotations)
        let nuevaSolicitud = CSolicitud()
        
        nuevaSolicitud.DatosCliente(cliente: clienteSolicitud!)
        
        nuevaSolicitud.DatosSolicitud(dirorigen: origen, referenciaorigen: referencia, dirdestino: destino,latorigen: String(Double(origenAnotacion.coordinate.latitude)), lngorigen: String(Double(origenAnotacion.coordinate.longitude)), latdestino: "0", lngdestino: "0",FechaHora: "")
        
        if self.VoucherView.isHidden == false && self.VoucherCheck.isOn{
          voucher = "1"
        }
        
        if self.RecordarView.isHidden == false && self.RecordarSwitch.isOn{
          let newFavorita = [self.origenText.text, referenciaText.text]
          self.GuardarFavorita(newFavorita: newFavorita as! [String])
        }
        
        self.CrearSolicitud(nuevaSolicitud,voucher: voucher)
        DibujarIconos([self.origenAnotacion])
        view.endEditing(true)
      }else{
        
      }
    }
  }
  
  //MARK:- CONTROL DE TECLADO VIRTUAL
  //Funciones para mover los elementos para que no queden detrás del teclado
  
  @objc func keyboardWillShow(notification: NSNotification) {
    if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
      self.keyboardHeight = keyboardSize.height
    }
  }
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    animateViewMoving(false, moveValue: 60, view: self.view)
  }
  
  func textViewDidChange(_ textView: UITextView) {
    
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    self.referenciaText.resignFirstResponder()
  }
  
  @objc func ocultarTeclado(sender: UITapGestureRecognizer){
    //sender.cancelsTouchesInView = false
    //self.SolicitudView.endEditing(true)
  }
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    if touch.view?.isDescendant(of: self.TablaDirecciones) == true {
      gestureRecognizer.cancelsTouchesInView = false
    }else{
      self.SolicitudView.endEditing(true)
    }
    return true
  }
  
  func cleanTextField(textfield: UITextField)->String{
    var cleanedTextField = textfield.text?.uppercased()
    cleanedTextField = cleanedTextField!.replacingOccurrences(of: "Ñ", with: "N",options: .regularExpression, range: nil)
    cleanedTextField = cleanedTextField!.replacingOccurrences(of: "[,.]", with: "-",options: .regularExpression, range: nil)
    cleanedTextField = cleanedTextField!.replacingOccurrences(of: "[\n]", with: " ",options: .regularExpression, range: nil)
    cleanedTextField = cleanedTextField!.replacingOccurrences(of: "[#]", with: "No",options: .regularExpression, range: nil)
    return cleanedTextField!.folding(options: .diacriticInsensitive, locale: .current)
  }
  
  func showFormularioSolicitud(){
    self.CargarFavoritas()
    self.TablaDirecciones.reloadData()
    self.origenIcono.isHidden = true
    self.origenAnotacion.coordinate = mapaVista.centerCoordinate
    coreLocationManager.stopUpdatingLocation()
    self.SolicitarBtn.isHidden = true
    self.origenText.becomeFirstResponder()
    if myvariables.cliente.empresa != "null"{
      self.VoucherView.isHidden = false
      self.VoucherEmpresaName.text = myvariables.cliente.empresa
      NSLayoutConstraint(item: self.BtnsView, attribute: .top, relatedBy: .equal, toItem: self.VoucherView, attribute:.bottom, multiplier: 1.0, constant:43.0).isActive = true
    }else{
      NSLayoutConstraint(item: self.BtnsView, attribute: .top, relatedBy: .equal, toItem: self.ContactoView, attribute:.bottom, multiplier: 1.0, constant:10.0).isActive = true
      
    }
    self.formularioSolicitud.isHidden = false
  }
  
  
  
  
  
  
  
  
  //MARK:- BOTONES GRAFICOS ACCIONES
  @IBAction func MostrarMenu(_ sender: Any) {
    self.MenuView1.isHidden = !self.MenuView1.isHidden
    self.MenuView1.startCanvasAnimation()
    self.TransparenciaView.isHidden = self.MenuView1.isHidden
    //self.Inicio()
    self.TransparenciaView.startCanvasAnimation()
    
  }
  @IBAction func SalirApp(_ sender: Any) {
    let fileAudio = FileManager()
    let AudioPath = NSHomeDirectory() + "/Library/Caches/Audio"
    do {
      try fileAudio.removeItem(atPath: AudioPath)
    }catch{
    }
    let datos = "#SocketClose," + myvariables.cliente.idCliente + ",# \n"
    EnviarSocket(datos)
    exit(3)
  }
  
  @IBAction func RelocateBtn(_ sender: Any) {
    let span = MKCoordinateSpan.init(latitudeDelta: 0.005, longitudeDelta: 0.005)
    let region = MKCoordinateRegion(center: self.origenAnotacion.coordinate, span: span)
    self.mapaVista.setRegion(region, animated: true)
    
  }
  //SOLICITAR BUTTON
  @IBAction func Solicitar(_ sender: AnyObject) {
    //TRAMA OUT: #Posicion,idCliente,latorig,lngorig
    self.addEnvirSolictudBtn()
    let datos = "#Posicion," + myvariables.cliente.idCliente + "," + "\(self.origenAnotacion.coordinate.latitude)," + "\(self.origenAnotacion.coordinate.longitude)," + "# \n"
    EnviarSocket(datos)
    
  }
  
  //Voucher check
  @IBAction func SwicthVoucher(_ sender: Any) {
    if self.VoucherCheck.isOn{
      self.destinoText.isHidden = false
      self.destinoText.becomeFirstResponder()
    }else{
      self.destinoText.isHidden = true
      self.destinoText.resignFirstResponder()
    }
  }
  
  //Aceptar y Enviar solicitud desde formulario solicitud
  @IBAction func AceptarSolicitud(_ sender: AnyObject) {
    
    if !self.destinoText.isHidden && self.destinoText.text!.isEmpty{
      let alertaDos = UIAlertController (title: "Dirección de Destino", message: "Si desea pagar con Voucher necesita escribir su dirección de Destino.", preferredStyle: UIAlertController.Style.alert)
      alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
        self.destinoText.becomeFirstResponder()
      }))
      self.present(alertaDos, animated: true, completion: nil)
    }else{
      if !(self.origenText.text?.isEmpty)! {
        var voucher = "0"
        let origen = self.cleanTextField(textfield: self.origenText)
        
        let referencia = self.cleanTextField(textfield: self.referenciaText)
        
        let destino = self.cleanTextField(textfield: self.destinoText)
        
        let nombreContactar = self.NombreContactoText.text!.isEmpty ? myvariables.cliente.nombreApellidos : self.cleanTextField(textfield: self.NombreContactoText)
        
        let telefonoContactar = self.TelefonoContactoText.text!.isEmpty ? myvariables.cliente.user : self.cleanTextField(textfield: self.TelefonoContactoText)
        
        let clienteSolicitud = self.NombreContactoText.text!.isEmpty ? myvariables.cliente : CCliente(idUsuario: myvariables.cliente.idUsuario, idcliente: myvariables.cliente.idCliente, user: telefonoContactar!, nombre: nombreContactar!, email: myvariables.cliente.email, empresa: myvariables.cliente.empresa)
        
        mapaVista.removeAnnotations(mapaVista.annotations)
        let nuevaSolicitud = CSolicitud()
        
        nuevaSolicitud.DatosCliente(cliente: clienteSolicitud!)
        
        nuevaSolicitud.DatosSolicitud(dirorigen: origen, referenciaorigen: referencia, dirdestino: destino,latorigen: String(Double(origenAnotacion.coordinate.latitude)), lngorigen: String(Double(origenAnotacion.coordinate.longitude)), latdestino: "0", lngdestino: "0",FechaHora: "")
        
        if self.VoucherView.isHidden == false && self.VoucherCheck.isOn{
          voucher = "1"
        }
        
        if self.RecordarView.isHidden == false && self.RecordarSwitch.isOn{
          let newFavorita = [self.origenText.text, referenciaText.text]
          self.GuardarFavorita(newFavorita: newFavorita as! [String])
        }
        
        self.CrearSolicitud(nuevaSolicitud,voucher: voucher)
        DibujarIconos([self.origenAnotacion])
        view.endEditing(true)
      }else{
        
      }
    }
    //        if !(self.NombreContactoText.text?.isEmpty)! && (self.TelefonoContactoText.text?.isEmpty)!{
    //            let alertaDos = UIAlertController (title: "Contactar a otra persona", message: "Debe teclear el número de teléfono de la persona que el conductor debe contactar.", preferredStyle: .alert)
    //            alertaDos.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: {alerAction in
    //
    //            }))
    //            self.present(alertaDos, animated: true, completion: nil)
    //        }else{
    //            if (!(self.origenText.text?.isEmpty)! && self.TelefonoContactoText.text != "Escriba el nombre del contacto" && self.TelefonoContactoText.text != "Número de teléfono incorrecto"){
    //                var voucher = "0"
    //                var recordar = "0"
    //                var origen = self.origenText.text!.uppercased()
    //                origen = origen.replacingOccurrences(of: "Ñ", with: "N",options: .regularExpression, range: nil)
    //                origen = origen.replacingOccurrences(of: "[,.]", with: "-",options: .regularExpression, range: nil)
    //                origen = origen.replacingOccurrences(of: "[\n]", with: " ",options: .regularExpression, range: nil)
    //                origen = origen.replacingOccurrences(of: "[#]", with: "No",options: .regularExpression, range: nil)
    //                origen = origen.folding(options: .diacriticInsensitive, locale: .current)
    //
    //                self.referenciaText.endEditing(true)
    //                var referencia = self.referenciaText.text!.uppercased()
    //                referencia = referencia.replacingOccurrences(of: "Ñ", with: "N",options: .regularExpression, range: nil)
    //                referencia = referencia.replacingOccurrences(of: "[,.]", with: "-",options: .regularExpression, range: nil)
    //                referencia = referencia.replacingOccurrences(of: "[\n]", with: " ",options: .regularExpression, range: nil)
    //                referencia = referencia.replacingOccurrences(of: "[#]", with: "No",options: .regularExpression, range: nil)
    //                referencia = referencia.folding(options: .diacriticInsensitive, locale: .current)
    //
    //                mapaVista.removeAnnotations(self.mapaVista.annotations)
    //                let nuevaSolicitud = CSolicitud()
    //                if !(NombreContactoText.text?.isEmpty)!{
    //                    nuevaSolicitud.DatosOtroCliente(clienteId: myvariables.cliente.idCliente, telefono: self.TelefonoContactoText.text!, nombre: self.NombreContactoText.text!)
    //                }else{
    //                    nuevaSolicitud.DatosCliente(cliente: myvariables.cliente)
    //                }
    //                nuevaSolicitud.DatosSolicitud(dirorigen: origen, referenciaorigen: referencia, dirdestino: "null", latorigen: String(Double(origenAnotacion.coordinate.latitude)), lngorigen: String(Double(origenAnotacion.coordinate.longitude)), latdestino: "0.0", lngdestino: "0.0",FechaHora: "null")
    //                if self.VoucherView.isHidden == false && self.VoucherCheck.isOn{
    //                    voucher = "1"
    //                }
    //                if self.RecordarView.isHidden == false && self.RecordarSwitch.isOn{
    //                    let newFavorita = [self.origenText.text, referenciaText.text]
    //                    self.GuardarFavorita(newFavorita: newFavorita as! [String])
    //                }
    //                self.CrearSolicitud(nuevaSolicitud,voucher: voucher)
    //                self.RecordarView.isHidden = true
    //                //self.CancelarSolicitudProceso.isHidden = false
    //            }else{
    //
    //            }
    //        }
  }
  
  //Boton para Cancelar Carrera
  @IBAction func CancelarSol(_ sender: UIButton) {
    self.formularioSolicitud.isHidden = true
    self.referenciaText.endEditing(true)
    self.Inicio()
    self.origenText.text?.removeAll()
    self.RecordarView.isHidden = true
    self.RecordarSwitch.isOn = false
    self.referenciaText.text?.removeAll()
    self.SolicitarBtn.isHidden = false
  }
  
  // CANCELAR LA SOL MIENTRAS SE ESPERA LA FONFIRMACI'ON DEL TAXI
  @IBAction func CancelarProcesoSolicitud(_ sender: AnyObject) {
    MostrarMotivoCancelacion()
  }
  
  @IBAction func MostrarTelefonosCC(_ sender: AnyObject) {
    self.SolPendientesView.isHidden = true
    DispatchQueue.main.async {
      let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "CallCenter") as! CallCenterController
      vc.telefonosCallCenter = self.TelefonosCallCenter
      self.navigationController?.show(vc, sender: nil)
    }
    
  }
  
  @IBAction func MostrarSolPendientes(_ sender: AnyObject) {
    if myvariables.solpendientes.count > 0{
      DispatchQueue.main.async {
        let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "ListaSolPdtes") as! SolicitudesTableController
        vc.solicitudesMostrar = myvariables.solpendientes
        self.navigationController?.show(vc, sender: nil)
      }
    }else{
      self.SolPendientesView.isHidden = !self.SolPendientesView.isHidden
    }
  }
  
  @IBAction func MapaMenu(_ sender: AnyObject) {
    Inicio()
  }
  
}




