//
//  AcceptSessionViewController.swift
//  FinalProject
//
//  Created by Ксения Чепурных on 21.12.2020.
//

import UIKit
import MapKit
import SnapKit

class AcceptSessionViewController: UIViewController {

    // MARK: Properties
    
    private let mapView = MKMapView()
    let session: Session
    var delegate: AcceptSessionDelegate?
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private let cancelSessionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_clear_white_36pt_2x").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(cancelSession), for: .touchUpInside)
        return button
    }()
    
    private let startLabel: UILabel = {
        let label = UILabel()
        label.text = "Would you like to accompany your friend?"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    private let acceptSessionButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(acceptSession), for: .touchUpInside)
        button.backgroundColor = .mainBlueTint
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("ACCEPT", for: .normal)
        return button
    }()
    
    // MARK: Init
    init(session: Session) {
        self.session = session
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        configureMapView()
    }
    
    // MARK: Functions
    
    func configureUI() {
        view.backgroundColor = .black
        
        view.addSubview(cancelSessionButton)
        cancelSessionButton.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.equalTo(20)
            make.height.width.equalTo(40)
        }
        
        view.addSubview(mapView)
        mapView.snp.makeConstraints { (make) in
            make.top.equalTo(cancelSessionButton.snp.bottom).offset(50)
            make.height.width.equalTo(270)
            make.centerX.equalTo(view.snp.centerX)
        }
        mapView.layer.cornerRadius = 270 / 2
        
        view.addSubview(startLabel)
        startLabel.snp.makeConstraints { (make) in
            make.top.equalTo(mapView.snp.bottom).offset(20)
            make.centerX.equalTo(view.snp.centerX)
        }
        
        view.addSubview(acceptSessionButton)
        acceptSessionButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(50)
        }
    }
    
    func configureMapView() {
        let region = MKCoordinateRegion(center: session.startCoordinates, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: false)
        let annoStart = MKPointAnnotation()
        let annoDestination = MKPointAnnotation()
        annoStart.coordinate = session.startCoordinates
        annoDestination.coordinate = session.destinationCoordinates
        mapView.addAnnotations([annoStart, annoDestination])
        mapView.selectAnnotation(annoStart, animated: true)
    }
    
    @objc func cancelSession() {
    }
    
    @objc func acceptSession() {
        Service.shared.acceptSession(session: session) { (error, ref) in
//            self.dismiss(animated: true, completion: nil)
            self.delegate?.didAcceptSession(self.session)
        }
    }

}

protocol AcceptSessionDelegate {
    func didAcceptSession(_ session: Session)
}
