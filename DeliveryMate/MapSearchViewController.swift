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
    
    enum mapSearchInState { case prepare, searching, searched }
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // 1. 검색에 따라 뷰 조절을 위해 테이블의 기존 높이와 검색결과 버튼의 기존 y값을 저장한다.
        self.tableOriginHeight = self.mapTableView.frame.height
        self.searchResultbuttonOriginY = self.searchResultButton.frame.minY
        
        // 2. 기본적인 뷰의 UI를 설정한다.
        self.mapSearchConfigureUI(.prepare)
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

            
        } else {
            // 검색어가 입력되지 않았을 때, 처리
        }
    }
    
    // MARK: - Map
    
    func mapView(_ mapView: MTMapView!, singleTapOn mapPoint: MTMapPoint!) {
        self.mapSearchBar.resignFirstResponder()
        self.mapSearchConfigureUI(.searched)
    }
    
    func pinItem(latitude: Double, longitude: Double) -> MTMapPOIItem {
        let item = MTMapPOIItem()
        item.itemName = "이 위치로 선택하기"
        item.markerType = .redPin
        item.markerSelectedType = .redPin
        item.mapPoint = MTMapPoint(geoCoord: .init(latitude: latitude, longitude: longitude))
        item.showAnimationType = .noAnimation
        item.customImageAnchorPointOffset = .init(offsetX: 30, offsetY: 0)
        return item
    }
    
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableItem.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mapTableCell", for: indexPath) as! MapTableCell
        cell.pinImageView.isHidden = true
        cell.locationTitleLabel.text = tableItem[indexPath.row].0
        
        // 1. 신주소가 없을 경우, 구주소로 텍스트를 넣어준다.
        if tableItem[indexPath.row].2 == "" {
            cell.newAddressLabel.text = tableItem[indexPath.row].1
        } else {
            cell.newAddressLabel.text = tableItem[indexPath.row].2
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // 1. 선택된 행에 핀 이미지를 보여준다.
        let cell = tableView.cellForRow(at: indexPath) as! MapTableCell
        cell.pinImageView.isHidden = false
        
        // 2. 지도 위에 기존에 찍힌 핀을 없앤다.
        mapView.removeAllPOIItems()
        
        // 3. 선택한 행의 정보로 핀을 초기화한다.
        let pin : MTMapPOIItem = pinItem(latitude: Double(tableItem[indexPath.row].3)!, longitude: Double(tableItem[indexPath.row].4)!)
        
        // 4. 핀을 추가한 후, 지도 위에 핀을 보여준다.
        mapView.add(pin)
        mapView.fitAreaToShowAllPOIItems()
        
        // 5. 핀을 선택한 상태로 보여준다.
        mapView.select(pin, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? MapTableCell
        cell?.pinImageView.isHidden = true
    }
    
    

    
    
    // MARK: - Action
    
    // cancelButtonPressed : 현재 모달창을 닫는다.
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func currentLocaButtonPressed(_ sender: Any) {
        // 1. 지도 위에 기존에 찍힌 핀을 없앤다.
        mapView.removeAllPOIItems()
        
        // 2. 현재 위치를 찾아 지도 중앙에 표시한다.
        mapView.currentLocationTrackingMode = .onWithoutHeading
        mapView.showCurrentLocationMarker = true
        
        // 3. 현재위치 마커 위에 핀을 만든다.
        let pin : MTMapPOIItem = pinItem(latitude: mapView.mapCenterPoint.mapPointGeo().latitude, longitude: mapView.mapCenterPoint.mapPointGeo().longitude)
        
        // 4. 지도 위에 핀을 보여준다.
        mapView.add(pin)
        mapView.fitAreaToShowAllPOIItems()
        
        // 5. 핀을 선택한 상태로 보여준다.
        mapView.select(pin, animated: true)
    }
    
    // searchResultButtonPressed : 검색결과 버튼을 누를 때마다, 검색결과 테이블을 나타내거나 없앤다.
    @IBAction func searchResultButtonPressed(_ sender: Any) {
        if searchResultbuttonOriginY >= self.searchResultButton.frame.minY {
            self.mapSearchConfigureUI(.searched)
        } else {
            self.mapSearchConfigureUI(.searching)
        }
    }
    
    
    // MARK: UI Functions
    
    func mapSearchConfigureUI(_ mapSearchInState: mapSearchInState) {
        switch(mapSearchInState) {
        case .prepare:
            self.searchResultButton.layer.borderWidth = 1
            self.searchResultButton.layer.borderColor = UIColor.lightGray.cgColor
        
        case .searching:
            // 1. 지도 뷰을 올리고, 결과버튼과 테이블 뷰를 보여주기 위해 뷰의 프레임을 조정한다.
            self.mapView.frame = CGRect(x: self.mapFrameView.frame.minX, y: self.mapFrameView.frame.minY, width: self.mapFrameView.frame.width, height: self.mapFrameView.frame.height - self.searchResultButton.frame.height - self.tableOriginHeight)
            self.searchResultButton.frame = CGRect(x: self.searchResultButton.frame.minX, y: searchResultbuttonOriginY, width: self.searchResultButton.frame.width, height: self.searchResultButton.frame.height)
            self.mapTableView.frame = CGRect(x: self.mapTableView.frame.minX, y: self.mapTableView.frame.minY, width: self.mapTableView.frame.width, height: tableOriginHeight)
            self.mapTableView.rowHeight = 60
            
            // 2. 검색결과 버튼의 이름을 바꾼다.
            self.searchResultButton.setTitle("검색결과 ▼", for: .normal)

            
            

        case .searched:
            // 1. 지도 뷰를 크게 보여주고, 테이블 뷰를 없애기 위해 뷰의 프레임을 조정한다.
            self.mapView.frame = CGRect(x: self.mapFrameView.frame.minX, y: self.mapFrameView.frame.minY, width: self.mapFrameView.frame.width, height: self.mapFrameView.frame.height - self.searchResultButton.frame.height)
            self.mapTableView.frame = CGRect(x: self.mapTableView.frame.minX, y: self.mapTableView.frame.minY, width: self.mapTableView.frame.width, height: 0)
            self.searchResultButton.frame = CGRect(x: self.searchResultButton.frame.minX, y: self.searchResultbuttonOriginY + self.tableOriginHeight, width: self.searchResultButton.frame.width, height: self.searchResultButton.frame.height)
            
            // 2. 검색결과 버튼의 이름을 바꾼다.
            self.searchResultButton.setTitle("검색결과 ▲", for: .normal)
            
        }
    }
    
}
