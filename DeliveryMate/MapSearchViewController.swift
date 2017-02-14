//
//  MapSearchViewController.swift
//  DeliveryMate
//
//  Created by 장진영 on 2017. 2. 7..
//  Copyright © 2017년 Jinyoung. All rights reserved.
//

import UIKit

class MapSearchViewController : UIViewController, MTMapViewDelegate, UISearchBarDelegate {
    
    
    @IBOutlet weak var mapSearchBar: UISearchBar!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var mapFrameView: UIView!
    @IBOutlet weak var mapTableView: UITableView!
    @IBOutlet weak var searchResultButton: UIButton!
    
    var delegate = MainViewController()
    
    lazy var mapView: MTMapView = MTMapView.init(frame: self.mapFrameView.frame)

    
    var tableItem = [(String, String, String, String, String)]()
    enum mapSearchInState { case prepare, searching, searched }
    var tableOriginHeight: CGFloat = 0
    var searchResultbuttonOriginY: CGFloat = 0
    var userSimpleAddress = ""
    var userDongCode : String?
    
    
    // MARK: - App Life Cycled
    
    override func viewDidLoad() {
        
        // 1. searchBar 델리게이트를 지정한다.
        mapSearchBar.delegate = self
        
        // 2. daum 지도를 위한 초기화를 한다.
        mapView.daumMapApiKey = "d740ee324a906cde3544c4dee13eaf3f"
        mapView.delegate = self
        mapView.baseMapType = .standard
        
        // 3. daum 지도를 뷰에 그린다.
        self.mapView.frame = self.mapFrameView.frame
        self.mapFrameView.addSubview(mapView)
        
        // 4. 상태바 뒤에 지도뷰가 투명하게 비치도록한다.
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        statusBar.backgroundColor = UIColor.init(white: 1, alpha: 0.7)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // 1. 검색에 따라 뷰 조절을 위해 테이블의 기존 높이와 검색결과 버튼의 기존 y값을 저장한다.
        self.tableOriginHeight = self.mapTableView.frame.height
        self.searchResultbuttonOriginY = self.searchResultButton.frame.minY
        
        // 2. 기본적인 뷰의 UI를 설정한다.
        self.mapSearchConfigureUI(.prepare)
    }
    

    // daumMapURLFromParameters : 장소검색 요청에 필요한 parameter를 만든다.
    private func daumMapURLFromParameters(_ parameters: [String: AnyObject],_ searchType: String) -> URL {
        var components = URLComponents()
        
        if searchType == "keywordSearch" {
            components.scheme = MapConstants.DaumMap.APIScheme
            components.host = MapConstants.DaumMap.APIHost
            components.path = MapConstants.DaumMap.APIPath
        } else {
            components.scheme = Pnt2AddrConstants.DaumMap.APIScheme
            components.host = Pnt2AddrConstants.DaumMap.APIHost
            components.path = Pnt2AddrConstants.DaumMap.APIPath
        }
        
        components.queryItems = [URLQueryItem]()
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        return components.url!
    }
    
    
    // MARK: - searchBar
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // 1. 현재 위치 트레킹을 중지한다.
        self.mapView.currentLocationTrackingMode = .off
        self.mapView.showCurrentLocationMarker = false

        self.tableItem = []
        
        if let keyword = self.mapSearchBar.text {
            let methodParameters = [
                MapConstants.MapParameterKeys.APIKey : MapConstants.MapParameterValues.APIKey,
                MapConstants.MapParameterKeys.Query : keyword
                ] as [String : Any]
            
            // create session and request
            let session = URLSession.shared
            
            
            let request = URLRequest(url: daumMapURLFromParameters(methodParameters as [String : AnyObject], "keywordSearch"))
            
            print("request: \(request)")
            // create network request
            let task = session.dataTask(with: request) { (data, response, error) in
                
                
                
                // if an error occurs, print it and re-enable the UI
                func displayError(_ error: String) {
                    print(error)
                }
                
                /* GUARD: Was there an error? */
                guard (error == nil) else {
                    displayError("There was an error with your request: \(error)")
                    return
                }
                
                /* GUARD: Did we get a successful 2XX response? */
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                    displayError("Your request returned a status code other than 2xx!")
                    return
                }
                
                /* GUARD: Was there any data returned? */
                guard let data = data else {
                    displayError("No data was returned by the request!")
                    return
                }
                
                // parse the data
                let parsedResult: [String:AnyObject]!
                do {
                    parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                    
                } catch {
                    displayError("Could not parse the data as JSON: '\(data)'")
                    return
                }
                
                guard let channel = parsedResult[MapConstants.MapResponseKeys.Channel] as? [String:AnyObject] else {
                    displayError("Cannot find keys 'channel' in \(parsedResult)")
                    return
                }
                
                
                guard let items = channel[MapConstants.MapResponseKeys.Item] as? [[String:AnyObject]] else {
                    displayError("Cannot find keys '\(MapConstants.MapResponseKeys.Item)' in \(channel)")
                    return
                }
                
                for item in items {
                    guard let title = item[MapConstants.MapResponseKeys.Title] as? String else {
                        displayError("Cannot find keys '\(MapConstants.MapResponseKeys.Title)' in \(item)")
                        return
                    }
                    
                    guard let newAddress = item[MapConstants.MapResponseKeys.NewAddress] as? String else {
                        displayError("Cannot find keys '\(MapConstants.MapResponseKeys.NewAddress)' in \(item)")
                        return
                    }
                    
                    guard let address = item[MapConstants.MapResponseKeys.Address] as? String else {
                        displayError("Cannot find keys '\(MapConstants.MapResponseKeys.Address)' in \(item)")
                        return
                    }
                    
                    guard let latitude = item[MapConstants.MapResponseKeys.Latitude] as? String else {
                        displayError("Cannot find keys '\(MapConstants.MapResponseKeys.Latitude)' in \(item)")
                        return
                    }
                    
                    guard let longitude = item[MapConstants.MapResponseKeys.Longitude] as? String else {
                        displayError("Cannot find keys '\(MapConstants.MapResponseKeys.Longitude)' in \(item)")
                        return
                    }
                    
                    guard let dongCode = item[MapConstants.MapResponseKeys.DongCode] as? String else {
                        displayError("Cannot find keys '\(MapConstants.MapResponseKeys.DongCode)' in \(item)")
                        return
                    }
                    
                    self.userDongCode = dongCode
                    self.tableItem.append(title, address, newAddress, latitude, longitude)
                   
                }
                
                performUIUpdatesOnMain {
                    // 1. 테이블데이터를 reload 한다.
                    self.mapTableView.reloadData()
                    
                    // 2. 검색상태로 뷰 UI를 변경한다.
                    self.mapSearchConfigureUI(.searching)
                    
                    // 3. 첫번째 셀을 선택한다.
                    self.mapTableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: UITableViewScrollPosition.top)
                    self.tableView(self.mapTableView, didSelectRowAt: IndexPath(row: 0, section: 0))
                    
                }
            }
            
            searchBar.resignFirstResponder()
            task.resume()

        }
    }
    
    // MARK: - Map
    
    func mapView(_ mapView: MTMapView!, singleTapOn mapPoint: MTMapPoint!) {
        self.mapSearchBar.resignFirstResponder()
        self.mapSearchConfigureUI(.searched)
    }
    
    func mapView(_ mapView: MTMapView!, touchedCalloutBalloonOf poiItem: MTMapPOIItem!) {
        // 1. 현재 위치 트레킹을 중지한다.
        self.mapView.currentLocationTrackingMode = .off
        self.mapView.showCurrentLocationMarker = false
        
        self.delegate.userSimpleAddress = poiItem.userObject as? String
        
        if let userDongCode = self.userDongCode {
            self.delegate.userDongCode = userDongCode
        }
    
        self.dismiss(animated: true, completion: nil)
    }
    
    func pinItem(address: String, latitude: Double, longitude: Double) -> MTMapPOIItem {
        let item = MTMapPOIItem()
        item.itemName = address
        item.markerType = .redPin
        item.markerSelectedType = .redPin
        item.mapPoint = MTMapPoint(geoCoord: .init(latitude: latitude, longitude: longitude))
        item.showAnimationType = .noAnimation
        item.customImageAnchorPointOffset = .init(offsetX: 30, offsetY: 0)
        item.userObject = address as NSObject!
        return item
    }
    
    
    
    // MARK: - Action
    
    // cancelButtonPressed : 현재 창을 닫는다.
    @IBAction func cancelButtonPressed(_ sender: Any) {
        // 1. 현재 위치 트레킹을 중지한다.
        self.mapView.currentLocationTrackingMode = .off
        self.mapView.showCurrentLocationMarker = false
        
        // 2. 현재 창을 닫는다.
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func currentLocaButtonPressed(_ sender: Any) {
        // 1. 지도 위에 기존에 찍힌 핀을 없앤다.
        mapView.removeAllPOIItems()
        
        // 2. 현재 위치를 찾아 지도 중앙에 표시한다.
        mapView.currentLocationTrackingMode = .onWithoutHeading
        mapView.showCurrentLocationMarker = true
        
        
        
        let methodParameters = [
            Pnt2AddrConstants.MapParameterKeys.APIKey : Pnt2AddrConstants.MapParameterValues.APIKey,
            Pnt2AddrConstants.MapParameterKeys.Output : Pnt2AddrConstants.MapParameterValues.Output,
            Pnt2AddrConstants.MapParameterKeys.Latitude : mapView.mapCenterPoint.mapPointGeo().latitude,
            Pnt2AddrConstants.MapParameterKeys.Longitude: mapView.mapCenterPoint.mapPointGeo().longitude
            ] as [String : Any]
            
        // create session and request
        let session = URLSession.shared
            
            
        let request = URLRequest(url: daumMapURLFromParameters(methodParameters as [String : AnyObject], "addressSearch"))
            
        print("request: \(request)")
        // create network request
        let task = session.dataTask(with: request) { (data, response, error) in
            print("response: \(response)")

            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)
            }
                
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError("There was an error with your request: \(error)")
                return
            }
                
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                return
            }
                
            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)as! [String:AnyObject]
                    
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                return
            }
                
            guard let Do = parsedResult[Pnt2AddrConstants.MapResponseKeys.Do] as? String else {
                displayError("Cannot find keys 'Do' in \(parsedResult)")
                return
            }
            
            guard let Gu = parsedResult[Pnt2AddrConstants.MapResponseKeys.Gu] as? String else {
                displayError("Cannot find keys 'Gu' in \(parsedResult)")
                return
            }
            
            guard let Dong = parsedResult[Pnt2AddrConstants.MapResponseKeys.Dong] as? String else {
                displayError("Cannot find keys 'Dong' in \(parsedResult)")
                return
            }
            
            guard let dongCode = parsedResult[Pnt2AddrConstants.MapResponseKeys.DongCode] as? String else {
                displayError("Cannot find keys 'DongCode' in \(parsedResult)")
                return
            }
            
            self.userSimpleAddress = Do+" "+Gu+" "+Dong
            self.userDongCode = dongCode
                        
            performUIUpdatesOnMain {
                let pin : MTMapPOIItem = self.pinItem(address: self.userSimpleAddress,latitude: self.mapView.mapCenterPoint.mapPointGeo().latitude, longitude: self.mapView.mapCenterPoint.mapPointGeo().longitude)
                    
                // 4. 지도 위에 핀을 보여준다.
                self.mapView.add(pin)
                self.mapView.fitAreaToShowAllPOIItems()
                    
                // 5. 핀을 선택한 상태로 보여준다.
                self.mapView.select(pin, animated: true)
            }
        }
        task.resume()
        
    }
    
    
    // searchResultButtonPressed : 검색결과 버튼을 누를 때마다, 검색결과 테이블을 나타내거나 없앤다.
    @IBAction func searchResultButtonPressed(_ sender: Any) {
        if searchResultbuttonOriginY >= self.searchResultButton.frame.minY {
            self.mapSearchConfigureUI(.searched)
        } else {
            self.mapSearchConfigureUI(.searching)
        }
    }
}
