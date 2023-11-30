//
//  GetH264Data.swift
//  app
//
//  Created by Pedro  on 16/5/21.
//  Copyright © 2021 pedroSG94. All rights reserved.
//

import Foundation

public protocol GetH264Data {
    func getH264Data(frame: Frame)
    
    func getSpsAndPps(sps: Array<UInt8>, pps: Array<UInt8>, vps: Array<UInt8>?)
}
