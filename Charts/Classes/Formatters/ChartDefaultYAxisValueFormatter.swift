//
//  ChartDefaultYAxisValueFormatter.swift
//  Charts
//
//  Created by Shinichi on 2017/6/2.
//  Copyright © 2017年 dcg. All rights reserved.
//

import Foundation

/// An interface for providing custom y-axis Strings.
open class ChartDefaultYAxisValueFormatter: NSObject, ChartYAxisValueFormatter
{
    
    open func stringForYValue(_ index: Int, original: String) -> String
    {
        return original // just return original, no adjustments
    }
    
}
