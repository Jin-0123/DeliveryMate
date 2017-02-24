//
//  MapSearchViewController.swift
//  DeliveryMate
//
//  Created by 장진영 on 2017. 2. 7..
//  Copyright © 2017년 Jinyoung. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

// LocationInfoObject : 키워드 장소 검색의 응답 맵핑에 필요한 객체를 선언한다.
class LocationInfoObject: Mappable {
    var title = String()
    var oldAddress = String()
    var newAddress = String()
    var latitude = String()
    var longitude = String()
    var dongCode = String()
    
    required init?(map: Map) {}
    func mapping(map: Map) {
        title <- map["title"]
        oldAddress <- map["address"]
        newAddress <- map["newAddress"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        dongCode <- map["addressBCode"]
    }
}

// LocationInfo : 키워드 장소 검색의 응답 맵핑에 필요한 객체를 선언한다.
class LocationInfo : Mappable {
    var channel : [String:AnyObject]?
    var item : [LocationInfoObject]?
    
    required init?(map: Map){
    }
    func mapping(map: Map) {
        channel <- map["channel"]
        item <- map["channel.item"]
    }
}

// DongCodeInfoObject : 상세주소에서 법정동코드 검색의 응답 맵핑에 필요한 객체를 선언한다.
class DongCodeInfoObject: Mappable {
    var dongCode = String()
    var address = String()
    required init?(map: Map) {}
    func mapping(map: Map) {
        dongCode <- map["bcode"]
        address <- map["region"]
    }
}


class MapSearchViewController : UIViewController, MTMapViewDelegate, UISearchBarDelegate {
    // 1. 키워드로 장소 검색에 필요한 변수를 설정한다.
    let LOCATION_KEYWORD_SEARCH_URL = "https://apis.daum.net/local/v1/search/keyword.json"
    let DAUM_API_KEY = Constants.DAUM_API_KEY
    
    // 2. 좌표로 법정동코드 검색에 필요한 변수를 설정한다.
    let DETAIL_ADDRESS_URL = "https://apis.daum.net/local/geo/coord2detailaddr"
    let INPUTCOORDSYSTEM = "WGS84"
    let OUTPUT = "json"
    
    var delegate : MainViewController?
    var tableItem = [[String:String]]()
    var tableOriginHeight: CGFloat = 0
    var searchResultbuttonOriginY: CGFloat = 0
    var userSimpleAddress = ""
    var userDongCode : String?
    lazy var mapView: MTMapView = MTMapView.init(frame: self.mapFrameView.frame)
    
    enum mapSearchInState { case searching, searched }
    
    @IBOutlet weak var mapSearchBar: UISearchBar!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var mapFrameView: UIView!
    @IBOutlet weak var mapTableView: UITableView!
    @IBOutlet weak var searchResultButton: UIButton!
    
    
    // MARK: - App Life Cycle
    
    override func viewDidLoad() {
        
        // 1. searchBar 델리게이트를 지정한다.
        mapSearchBar.delegate = self
        
        // 2. daum 지도를 위한 초기화를 한다.
        mapView.daumMapApiKey = Constants.DAUM_MAP_API_KEY
        mapView.delegate = self
        mapView.baseMapType = .standard
        
        // 3. daum 지도를 뷰에 그린다.
        self.mapView.frame = self.mapFrameView.frame
        self.mapFrameView.addSubview(mapView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // 1. 검색에 따라 뷰 조절을 위해 테이블의 기존 높이와 검색결과 버튼의 기존 y값을 저장한다.
        self.tableOriginHeight = self.mapTableView.frame.height
        self.searchResultbuttonOriginY = self.searchResultButton.frame.minY
        
    }
    
    // MARK: - searchBar
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // 1. 현재 위치 트레킹을 중지한다.
        self.mapView.currentLocationTrackingMode = .off
        self.mapView.showCurrentLocationMarker = false

        self.tableItem = []
        
        if let keyword = self.mapSearchBar.text {
            let parameters : Parameters = [
                "query" : keyword,
                "apikey" : DAUM_API_KEY
            ]
            
            Alamofire.request(LOCATION_KEYWORD_SEARCH_URL, parameters: parameters, encoding: URLEncoding.default).responseObject(completionHandler: {
                (response: DataResponse<LocationInfo>) in
                if let locationInfo = response.result.value?.item {
                    for item in locationInfo {
                        if item.newAddress != "" {
                            self.tableItem.append(["title":item.title,"address":item.newAddress, "latitude":item.latitude,"longitude":item.longitude,"dongCode":item.dongCode])
                        } else {
                            self.tableItem.append(["title":item.title,"address":item.oldAddress, "latitude":item.latitude,"longitude":item.longitude,"dongCode":item.dongCode])
                        }
                        
                    }
                    
                    if self.tableItem.count != 0 {
                        // 1. 테이블데이터를 reload 한다.
                        self.mapTableView.reloadData()
                        
                        // 2. 검색상태로 뷰 UI를 변경한다.
                        self.mapSearchConfigureUI(.searching)
                        
                        // 3. 첫번째 셀을 선택한다.
                        self.mapTableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: UITableViewScrollPosition.top)
                        self.tableView(self.mapTableView, didSelectRowAt: IndexPath(row: 0, section: 0))
                    } else {
                        // 4. 검색결과가 없을 경우, 경고창을 띄워준다.
                        let alert = UIAlertController(title: "", message: "검색결과가 없습니다", preferredStyle: .alert)
                        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
                        alert.addAction(cancel)
                        self.present(alert, animated: false, completion: nil)
                    }
                }
                
                
            })

        }
    }
    
    // MARK: - Map
    
    func mapView(_ mapView: MTMapView!, singleTapOn mapPoint: MTMapPoint!) {
        self.mapSearchBar.resignFirstResponder()
        // 1. 검색결과가 있을 경우에만 뷰의 UI를 변경해준다.
        if self.tableItem.count != 0 {
            self.mapSearchConfigureUI(.searched)
        }
    }
    
    // doubleTapOn : 두번 탭했을 경우, 사용자의 터치 지점에 핀을 보여준다.
    func mapView(_ mapView: MTMapView!, doubleTapOn mapPoint: MTMapPoint!) {
        // 1. 현재 위치 트레킹을 중지한다.
        self.mapView.currentLocationTrackingMode = .off
        self.mapView.showCurrentLocationMarker = false
        
        // 2. 지도 위에 기존에 찍힌 핀을 없앤다.
        mapView.removeAllPOIItems()
        
        // 3. 법정동코드를 가져오고, 핀을 찍는다.
        pnt2ADongCode(location: mapPoint)
    }
    
    func mapView(_ mapView: MTMapView!, touchedCalloutBalloonOf poiItem: MTMapPOIItem!) {
        // 1. 현재 위치 트레킹을 중지한다.
        self.mapView.currentLocationTrackingMode = .off
        self.mapView.showCurrentLocationMarker = false
        
        // 2. Main 화면에 사용자의 주소와 법정동코드를 넘겨준다.
        if let delegate = delegate {
            delegate.userSimpleAddress = (poiItem.userObject as? Dictionary)?["address"]
            delegate.userDongCode = (poiItem.userObject as? Dictionary)?["dongCode"]
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func mapView(_ mapView: MTMapView!, updateCurrentLocation location: MTMapPoint!, withAccuracy accuracy: MTMapLocationAccuracy) {
        // 1. 지도 위에 기존에 찍힌 핀을 없앤다.
        mapView.removeAllPOIItems()
        
        // 2. 법정동코드를 가져오고, 핀을 찍는다.
        pnt2ADongCode(location: location)
    }
    
    func pinItem(address: String, dongCode: String, latitude: Double, longitude: Double) -> MTMapPOIItem {
        let item = MTMapPOIItem()
        item.itemName = address
        item.markerType = .redPin
        item.markerSelectedType = .redPin
        item.mapPoint = MTMapPoint(geoCoord: .init(latitude: latitude, longitude: longitude))
        item.showAnimationType = .noAnimation
        item.customImageAnchorPointOffset = .init(offsetX: 30, offsetY: 0)
        item.userObject = ["address":address, "dongCode":dongCode] as NSObject!
        return item
    }
    
    // pnt2ADongCode : 위도, 경도값으로 법정동코드를 검색한 후, 지도 위에 핀을 보여준다.
    func pnt2ADongCode(location: MTMapPoint!) {
        let parameters : Parameters = [
            "apikey" : DAUM_API_KEY,
            "output" : OUTPUT,
            "x" : location.mapPointGeo().longitude,
            "y" : location.mapPointGeo().latitude,
            "inputCoordSystem" : INPUTCOORDSYSTEM
        ]
        
        Alamofire.request(DETAIL_ADDRESS_URL, parameters: parameters, encoding: URLEncoding.default).responseObject(completionHandler: {
            (response: DataResponse<DongCodeInfoObject>) in
            if let dongCodeInfo = response.result.value {
                self.userSimpleAddress = dongCodeInfo.address
                self.userDongCode = dongCodeInfo.dongCode
                
                // 1. 핀을 초기화한다.
                let pin : MTMapPOIItem = self.pinItem(address: dongCodeInfo.address, dongCode:dongCodeInfo.dongCode , latitude: self.mapView.mapCenterPoint.mapPointGeo().latitude, longitude: self.mapView.mapCenterPoint.mapPointGeo().longitude)
                
                // 2. 지도 위에 핀을 보여준다.
                self.mapView.add(pin)
                self.mapView.fitAreaToShowAllPOIItems()
                
                // 3. 핀을 선택한 상태로 보여준다.
                self.mapView.select(pin, animated: true)
            }
        })
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
        
        pnt2ADongCode(location: mapView.mapCenterPoint)
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
