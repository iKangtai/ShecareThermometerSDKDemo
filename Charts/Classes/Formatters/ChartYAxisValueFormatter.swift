//
//  ChartYAxisValueFormatter.swift
//  Charts
//
//  Created by Shinichi on 2017/6/2.
//  Copyright © 2017年 dcg. All rights reserved.
//

import Foundation

/// An interface for providing custom y-axis Strings.
@objc
public protocol ChartYAxisValueFormatter
{
    
    /// For performance reasons, avoid excessive calculations and memory allocations inside this method.
    ///
    /// - returns: the customized label that is drawn on the y-axis.
    /// - parameter index:           the y-index that is currently being drawn
    /// - parameter original:        the original y-axis label to be drawn
    ///
    @objc func stringForYValue(_ index: Int, original: String) -> String
    
}
