//
//  MapSearchViewController.swift
//  DeliveryMate
//
//  Created by 장진영 on 2017. 2. 7..
//  Copyright © 2017년 Jinyoung. All rights reserved.
//

import UIKit

class MapSearchViewController : UIViewController, MTMapViewDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var mapSearchBar: UISearchBar!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var mapFrameView: UIView!
    @IBOutlet weak var mapTableView: UITableView!
    @IBOutlet weak var searchResultButton: UIButton!
    
    lazy var mapView: MTMapView = MTMapView.init(frame: CGRect(x: self.mapFrameView.frame.minX, y: self.mapFrameView.frame.minY, width: self.mapFrameView.frame.width, height: self.mapFrameView.frame.height))
    
    var tableItem = [(String, String, String, String, String)]()
    
    enum mapSearchInState { case willSearch, searching, searched }
    var tableOriginHeight: CGFloat = 0
    var searchResultbuttonOriginY: CGFloat = 0
    
    
    // MARK: - App Life Cycle
    
    override func viewDidLoad() {
        
        // 1. searchBar 델리게이트를 지정한다.
        mapSearchBar.delegate = self
        
        // 2. daum 지도를 위한 초기화를 한다.
        mapView.daumMapApiKey = MapConstants.MapParameterValues.APIKey
        mapView.delegate = self
        mapView.baseMapType = .standard
        
        // 3. daum 지도를 뷰에 그린다.
        self.view.addSubview(mapView)
        
        // 4. 현재 위치를 나타내지 않는다.
        mapView.showCurrentLocationMarker = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableOriginHeight = self.mapTableView.frame.height
        self.searchResultbuttonOriginY = self.searchResultButton.frame.minY
        self.searchResultButton.layer.borderWidth = 1
        self.searchResultButton.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    
    
    // daumMapURLFromParameters : 장소검색 요청에 필요한 parameter를 만든다.
    private func daumMapURLFromParameters(_ parameters: [String: AnyObject]) -> URL {
        var components = URLComponents()
        components.scheme = MapConstants.DaumMap.APIScheme
        components.host = MapConstants.DaumMap.APIHost
        components.path = MapConstants.DaumMap.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        return components.url!
    }
    
    
    // MARK: - searchBar
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.tableItem = []
        
        if let keyword = self.mapSearchBar.text {
            let methodParameters = [
                MapConstants.MapParameterKeys.APIKey : MapConstants.MapParameterValues.APIKey,
                MapConstants.MapParameterKeys.Query : keyword
                ] as [String : Any]
            
            // create session and request
            let session = URLSession.shared
            
            
            let request = URLRequest(url: daumMapURLFromParameters(methodParameters as [String : AnyObject]))
            
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
                
                
                guard let info = channel[MapConstants.MapResponseKeys.Info] as? [String:AnyObject] else {
                    displayError("Cannot find keys '\(MapConstants.MapResponseKeys.Info)' in \(channel)")
                    return
                }
                
                
                guard let totalCount = info[MapConstants.MapResponseKeys.TotalCount] as? String else {
                    displayError("Cannot find keys 'totalCount' in \(info)")
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
                    self.tableItem.append(title, address, newAddress, latitude, longitude)
                   
                }
                
                performUIUpdatesOnMain {
                    self.searchResultButton.setTitle("검색결과 \(totalCount)건", for: .normal)
                    self.mapTableView.reloadData()
                    self.mapSearchConfigureUI(.searching)
                }
            }
            
            searchBar.resignFirstResponder()
            
            task.resume()

            
        } else {
            // 검색어가 입력되지 않았을 때, 처리
        }
    }
    
    // MARK: - Map
    
    func mapView(_ mapView: MTMapView!, singleTapOn mapPoint: MTMapPoint!) {
        self.mapSearchBar.resignFirstResponder()
        self.mapSearchConfigureUI(.searched)
    }
    
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableItem.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mapTableCell", for: indexPath) as! MapTableCell
        cell.locationTitleLabel.text = tableItem[indexPath.row].0
        
        // 1. 신주소가 없을 경우, 구주소로 텍스트를 넣어준다.
        if tableItem[indexPath.row].2 == "" {
            cell.newAddressLabel.text = tableItem[indexPath.row].1
        } else {
            cell.newAddressLabel.text = tableItem[indexPath.row].2
        }
        
        return cell
    }
    
    
    // MARK: - Action
    
    // cancelButtonPressed : 현재 모달창을 닫는다.
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func currentLocaButtonPressed(_ sender: Any) {
        mapView.currentLocationTrackingMode = .onWithoutHeading
        print(mapView.mapCenterPoint)
    }
    
    // searchResultButtonPressed : 검색결과 버튼을 누를 때마다, 검색결과 테이블을 나타내거나 없앤다.
    @IBAction func searchResultButtonPressed(_ sender: Any) {
        print("originY: \(self.searchResultbuttonOriginY)")
        print("minY: \(self.searchResultButton.frame.minY)")
        
        if searchResultbuttonOriginY >= self.searchResultButton.frame.minY {
            self.mapSearchConfigureUI(.searched)
        } else {
            self.mapSearchConfigureUI(.searching)
        }
    }
    
    
    // MARK: UI Functions
    
    func mapSearchConfigureUI(_ mapSearchInState: mapSearchInState) {
        switch(mapSearchInState) {
        case .willSearch:
            self.mapView.frame = CGRect(x: self.mapFrameView.frame.minX, y: self.mapFrameView.frame.minY, width: self.mapFrameView.frame.width, height: self.mapFrameView.frame.height)
        
        case .searching:
            self.mapView.frame = CGRect(x: self.mapFrameView.frame.minX, y: self.mapFrameView.frame.minY, width: self.mapFrameView.frame.width, height: self.mapFrameView.frame.height - self.searchResultButton.frame.height - self.tableOriginHeight)
            self.searchResultButton.frame = CGRect(x: self.searchResultButton.frame.minX, y: searchResultbuttonOriginY, width: self.searchResultButton.frame.width, height: self.searchResultButton.frame.height)
            self.mapTableView.frame = CGRect(x: self.mapTableView.frame.minX, y: self.mapTableView.frame.minY, width: self.mapTableView.frame.width, height: tableOriginHeight)
            self.mapTableView.rowHeight = 60
            
        case .searched:
            self.mapView.frame = CGRect(x: self.mapFrameView.frame.minX, y: self.mapFrameView.frame.minY, width: self.mapFrameView.frame.width, height: self.mapFrameView.frame.height - self.searchResultButton.frame.height)
            
            self.mapTableView.frame = CGRect(x: self.mapTableView.frame.minX, y: self.mapTableView.frame.minY, width: self.mapTableView.frame.width, height: 0)
            
            self.searchResultButton.frame = CGRect(x: self.searchResultButton.frame.minX, y: self.searchResultbuttonOriginY + self.tableOriginHeight, width: self.searchResultButton.frame.width, height: self.searchResultButton.frame.height)
            
        }
    }
    
}
