//
//  MainViewController.swift
//  FinalProject
//
//  Created by Ксения Чепурных on 10.12.2020.
//

import UIKit
import SnapKit
import MapKit
import Firebase

private enum ActionButtonConfiguration {
    case showMenu
    case dismissActionView
}

class MainViewController: UIViewController {
    
    // MARK: Properties
    private let locationManager = CLLocationManager()
    private let mapView = MKMapView()
    private let destinationInputActivationView = DestinationImputActivationView()
    private let destinationInputView = DestinationInputView()
    private let tableView = UITableView()
    private var searchResults = [MKPlacemark]()
    private var actionButtonConfig: ActionButtonConfiguration = .showMenu
    private var route: MKRoute?
    private let actionView = ActionView()
    var companions: [Companion]?
    
    var user: User? {
        didSet {
            Service.shared.observeSession { (session) in
                self.session = session
            }
        }
    }
    
    var session: Session? {
        didSet {
            guard let session = session else { return }
            actionView.session = session
            guard let sessionState = session.state else { return }
            if sessionState.rawValue == SessionState.requested.rawValue && session.role?.rawValue == SessionRole.companion.rawValue {
                let controller = AcceptSessionViewController(session: session)
                controller.delegate = self
                controller.modalPresentationStyle = .fullScreen
                present(controller, animated: true, completion: nil)
            }
            
            if session.state?.rawValue == SessionState.inProgress.rawValue {
                configureUIForSessionInProgress()
                shouldPresentLoadingView(false)
                showActionView(shouldShow: true, config: .sessionInProgress)
                Service.shared.observeSessionCancelled(session: session) { [self] in
                    getUIBackToNormal()
                    presentAlertController(withTitle: "Ooops!", message: "Session ended")
                    self.saveSession(session: session)
                }
            }
            
            if session.state?.rawValue == SessionState.inProgress.rawValue && session.role?.rawValue == SessionRole.companion.rawValue {
                configureUIForSessionInProgress()
                let companionUID = session.companionUID
                let currentAnno = CompanionAnnotation(uid: companionUID, coordinate: session.currentCoordinates)

                var companiomIsVisible: Bool {
                    return self.mapView.annotations.contains(where: { currentAnno -> Bool in
                        guard let companionAnno = currentAnno as? CompanionAnnotation else { return false}
                        if companionAnno.uid == session.companionUID {
                            companionAnno.updateAnnotationPosition(withCoordinate: session.currentCoordinates)
                            return true
                        }
                        return false
                    })
                }
                if !companiomIsVisible {
                    let destinationAnno = MKPointAnnotation()
                    currentAnno.coordinate = session.currentCoordinates
                    destinationAnno.coordinate = session.destinationCoordinates
                    mapView.addAnnotations([currentAnno, destinationAnno])
                    let startPlaceMark = MKPlacemark(coordinate: session.startCoordinates)
                    let destinationPlaceMark = MKPlacemark(coordinate: session.destinationCoordinates)
                    let start = MKMapItem(placemark: startPlaceMark)
                    let destination = MKMapItem(placemark: destinationPlaceMark)
                    generatePolyLine(fromStart: start, toDestination: destination)
                    centerMapOnUserLocation(coordinate: currentAnno.coordinate)
                } else {
                    
                }
            }
        }
    }
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "log-out").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManagerDidChangeAuthorization(locationManager)
        
        configureUI()
        fetchUserData()
    }
    
    
    // MARK: Functions
    
    func configureUIForSessionInProgress() {
        actionButton.isHidden = true
        destinationInputActivationView.isHidden = true
    }
    
    func getUIBackToNormal() {
        self.showActionView(shouldShow: false)
        self.actionButton.setImage(#imageLiteral(resourceName: "log-out").withRenderingMode(.alwaysOriginal), for: .normal)
        self.actionButtonConfig = .showMenu
        self.actionButton.isHidden = false
        self.destinationInputActivationView.isHidden = false
        self.destinationInputActivationView.alpha = 1
        self.centerMapOnUserLocation(coordinate: self.locationManager.location!.coordinate)
        removeAnnotationsAndRouts()
    }
    
    @objc func actionButtonPressed() {
        switch actionButtonConfig {
        case .showMenu:
            do {
                try Auth.auth().signOut()
            } catch {
                return
            }
            
            let controller = LoginViewController()
            controller.modalPresentationStyle = .fullScreen
            present(controller, animated: true, completion: nil)
        case .dismissActionView:
            removeAnnotationsAndRouts()
            mapView.showAnnotations(mapView.annotations, animated: true)
            showActionView(shouldShow: false, config: ActionViewConfiguration.request)

            UIView.animate(withDuration: 0.3) {
                self.destinationInputActivationView.alpha = 1
                self.actionButton.setImage(#imageLiteral(resourceName: "log-out").withRenderingMode(.alwaysOriginal), for: .normal)
                self.actionButtonConfig = .showMenu
            }
        }
    }
    
    func removeAnnotationsAndRouts() {
        mapView.annotations.forEach { (annotation) in
            if let anno = annotation as? MKPointAnnotation {
                mapView.removeAnnotation(anno)
            }
            
            if let anno = annotation as? CompanionAnnotation {
                mapView.removeAnnotation(anno)
            }
        }
        print(mapView.overlays.count)
        if mapView.overlays.count > 0 {
            mapView.removeOverlay(mapView.overlays[0])
        }
    }
    
    func fetchUserData() {
        Service.shared.fetchUserData { (user) in
            self.user = user
        }
        
        Service.shared.fetchCompanions { (companionsArr) in
            self.companions = companionsArr
        }

    }
    
    func configureUI() {
        configureMapView()
        
        configureActionView()
        
        destinationInputActivationView.delegate = self
        
        
        view.addSubview(actionButton)
        actionButton.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.left.equalTo(20)
            make.height.width.equalTo(30)
        }
        
        view.addSubview(destinationInputActivationView)
        destinationInputActivationView.snp.makeConstraints { (make) in
            make.top.equalTo(actionButton.snp.bottom).offset(15)
            make.left.equalTo(30)
            make.right.equalTo(-30)
            make.height.equalTo(50)
        }
        
        configureTableView()
    }
    
    func configureMapView() {
        destinationInputView.delegate = self
        mapView.delegate = self
        view.addSubview(mapView)
        mapView.frame = view.frame
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
    
    func configureDestinationInputView() {
        view.addSubview(destinationInputView)
        
        destinationInputView.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.top)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.height.equalTo(200)
        }
        destinationInputView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.destinationInputView.alpha = 1
        } completion: { (_) in
            UIView.animate(withDuration: 0.3) {
                self.tableView.frame.origin.y = 200 //потому что высота destinationInputView равна 200
            }
        }
    }
    
    func configureActionView() {
        view.addSubview(actionView)
        actionView.delegate = self
        actionView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: 300)
        
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(DestinationInputCell.self, forCellReuseIdentifier: "DestinationInputCell")
        tableView.rowHeight = 60
        let height = CGFloat(view.frame.height - 200) //потому что высота destinationInputView равна 200
        tableView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: height)
        view.addSubview(tableView)
    }
    
    func dissmissDestinationView(completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, animations: {
            self.destinationInputView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height
            self.destinationInputView.removeFromSuperview()
        }, completion: completion)
    }
    
    func showActionView(shouldShow: Bool, config: ActionViewConfiguration? = nil) {
        if shouldShow {
            UIView.animate(withDuration: 0.3) {
                self.actionView.frame.origin.y = self.view.frame.height - 300
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.actionView.frame.origin.y = self.view.frame.height
            }
        }
        guard let config = config else { return }
        actionView.configureUI(withConfig: config)
    }
    
    func centerMapOnUserLocation(coordinate: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: coordinate,
                                        latitudinalMeters: 2000,
                                        longitudinalMeters: 2000)
        mapView.setRegion(region, animated: true)
    }
    
    func generatePolyLine(fromStart start: MKMapItem, toDestination destination: MKMapItem) {
        let request = MKDirections.Request()
        request.source = start
        request.destination = destination
        request.transportType = .automobile
        
        let directionRequest = MKDirections(request: request)
        directionRequest.calculate { (response, error) in
            guard let response = response else { return }
            self.route = response.routes[0]
            guard let polyline = self.route?.polyline else { return }
            self.mapView.addOverlay(polyline)
        }
    }
    
    func searchBy(naturalLanguageQuery: String, completion: @escaping([MKPlacemark]) -> Void) {
        var results = [MKPlacemark]()
        
        let request = MKLocalSearch.Request()
        request.region = mapView.region
        request.naturalLanguageQuery = naturalLanguageQuery
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response else { return }
            
            response.mapItems.forEach({ item in
                results.append(item.placemark)
            })
            
            completion(results)
        }
    }

}

// MARK: Location Service Extension

extension MainViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationManager.delegate = self
        switch manager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
        @unknown default:
            break
        }
    }
}

// MARK: DestinationImputActivationViewDelegate

extension MainViewController: DestinationImputActivationViewDelegate {
    func presentDestinationImputView() {
        destinationInputActivationView.alpha = 0
        configureDestinationInputView()
    }
}

extension MainViewController: DestinationInputViewDelegate {
    func executeSearch(query: String) {
        searchBy(naturalLanguageQuery: query) { (results) in
            self.searchResults = results
            self.tableView.reloadData()
        }
    }
    
    func dissmisDestinationInputView() {
        dissmissDestinationView() { _ in
            UIView.animate(withDuration: 0.5, animations: {
                self.destinationInputActivationView.alpha = 1
            })
        }

    }
}

// MARK: UITableViewDelegate, UITableViewDataSource

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DestinationInputCell") as! DestinationInputCell
        cell.placemark = searchResults[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlaceMark = searchResults[indexPath.row]
        let start = MKMapItem.forCurrentLocation()
        let destination = MKMapItem(placemark: selectedPlaceMark)
        generatePolyLine(fromStart: start, toDestination: destination)
        actionButton.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
        actionButtonConfig = .dismissActionView
        dissmissDestinationView { (_) in
            let annotation = MKPointAnnotation()
            annotation.coordinate = selectedPlaceMark.coordinate
            self.mapView.addAnnotation(annotation)
            self.mapView.selectAnnotation(annotation, animated: true)
            self.showActionView(shouldShow: true, config: .request)
            self.actionView.destination = selectedPlaceMark
        }
    }
    
}

// MARK: MKMapViewDelegate

extension MainViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? CompanionAnnotation {
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: "CompanionAnnotation")
            view.image = #imageLiteral(resourceName: "chevron-sign-to-right")
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = self.route {
            let polyline = route.polyline
            let lineRenderer = MKPolylineRenderer(overlay: polyline)
            lineRenderer.strokeColor = .mainBlueTint
            lineRenderer.lineWidth = 4
            return lineRenderer
        }
        return MKOverlayRenderer()
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard let session = session else { return }
        guard let location = locationManager.location else { return }
        if session.role?.rawValue == SessionRole.user.rawValue {
            Service.shared.updateLocation(location: location, session: session)
        }
    }
}

// MARK: ActionViewDelegate

extension MainViewController: ActionViewDelegate {
    func endSession() {
        guard let session = session else { return }
        Service.shared.endSession(session: session) { (error, ref) in
            self.showActionView(shouldShow: false)
            self.getUIBackToNormal()
            self.saveSession(session: session)
        }
    }
    
    func createSession(_ viev: ActionView) {
        guard let startCoordinates = locationManager.location?.coordinate else { return }
        guard let destinationCoordinates = self.actionView.destination?.coordinate else { return }
        guard let companionUID = self.actionView.selectedCompanion?.uid else {return}
        
        shouldPresentLoadingView(true, message: "Waiting for your companion to accept...")
        guard let userPhone = user?.phone else { return }
        guard let userName = user?.fullname else { return }
        guard let companionPhone = actionView.selectedCompanion?.phone else { return }
        guard let companionName = actionView.selectedCompanion?.fullname else { return }
        Service.shared.createSession(startCoordinates, companionUID: companionUID, companionPhone: companionPhone, userPhone: userPhone, destinationCoordinates, companionName: companionName, userName: userName) { (error, ref) in
        }
        
        self.actionView.frame.origin.y = self.view.frame.height
    }

}

// MARK: AcceptSessionDelegate

extension MainViewController: AcceptSessionDelegate {
    func didAcceptSession(_ session: Session) {
        self.dismiss(animated: true) {
            self.showActionView(shouldShow: true, config: ActionViewConfiguration.sessionInProgress)
        }
    }
}


