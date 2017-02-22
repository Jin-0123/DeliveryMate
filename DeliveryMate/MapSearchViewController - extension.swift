//
//  MapSearchViewController - table.swift
//  DeliveryMate
//
//  Created by 장진영 on 2017. 2. 10..
//  Copyright © 2017년 Jinyoung. All rights reserved.
//

extension MapSearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableItem.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mapTableCell", for: indexPath) as! MapTableCell
        cell.pinImageView.isHidden = true
        cell.locationTitleLabel.text = tableItem[indexPath.row]["title"]
        cell.newAddressLabel.text = tableItem[indexPath.row]["address"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // 1. 선택된 행에 핀 이미지를 보여준다.
        let cell = tableView.cellForRow(at: indexPath) as! MapTableCell
        cell.pinImageView.isHidden = false
        
        // 2. 지도 위에 기존에 찍힌 핀을 없앤다.
        mapView.removeAllPOIItems()
        
        // 3. 핀에 넣을 정보를 넣는다.
        let itemTitle = tableItem[indexPath.row]["address"]!
        let itemDongCode = tableItem[indexPath.row]["dongCode"]!
        let itemLatitude = Double(tableItem[indexPath.row]["latitude"]!)
        let itemLongitude = Double(tableItem[indexPath.row]["longitude"]!)
        
        if let itemLatitude = itemLatitude, let itemLongitude = itemLongitude {
            // 3. 선택한 핀을 초기화한다.
            let pin : MTMapPOIItem = pinItem(address: itemTitle, dongCode: itemDongCode, latitude: itemLatitude, longitude: itemLongitude)
            
            // 4. 핀을 추가한 후, 지도 위에 핀을 보여준다.
            mapView.add(pin)
            mapView.fitAreaToShowAllPOIItems()
            
            // 5. 핀을 선택한 상태로 보여준다.
            mapView.select(pin, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? MapTableCell
        cell?.pinImageView.isHidden = true
    }
    
    // MARK: UI Functions
    
    func mapSearchConfigureUI(_ mapSearchInState: mapSearchInState) {
        switch(mapSearchInState) {
            
        case .searching:

            // 1. 지도 뷰을 올리고, 결과버튼과 테이블 뷰를 보여주기 위해 뷰의 프레임을 조정한다.
            self.mapView.frame = CGRect(x: self.mapFrameView.frame.minX, y: self.mapFrameView.frame.minY, width: self.mapFrameView.frame.width, height: self.mapFrameView.frame.height - self.searchResultButton.frame.height - self.tableOriginHeight)
            self.searchResultButton.frame = CGRect(x: self.searchResultButton.frame.minX, y: searchResultbuttonOriginY, width: self.searchResultButton.frame.width, height: self.searchResultButton.frame.height)
            self.mapTableView.frame = CGRect(x: self.mapTableView.frame.minX, y: self.mapTableView.frame.minY, width: self.mapTableView.frame.width, height: tableOriginHeight)
            self.mapTableView.rowHeight = 60
            
            // 2. 검색결과 버튼의 이름을 바꾼다.
            self.searchResultButton.setTitle("검색결과 ▼", for: .normal)
            self.searchResultButton.tintColor = UIColor.white
            
            
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
