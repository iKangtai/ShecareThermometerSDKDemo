//
//  BalloonMarker.swift
//  ChartsDemo
//
//  Created by Daniel Cohen Gindi on 19/3/15.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

open class BalloonMarker: ChartMarker
{
    open var color: UIColor?
    open var arrowSize = CGSize(width: 5, height: 5)
    open var font: UIFont?
    open var textColor: UIColor?
    open var insets = UIEdgeInsets()
    open var minimumSize = CGSize()
    
    private var labelns: String?
    private var heartImage: UIImage?
    private var _labelSize: CGSize = CGSize()
    private var _size: CGSize = CGSize()
    private var _paragraphStyle: NSMutableParagraphStyle?
    private var _drawAttributes = [String : AnyObject]()
    
    public init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets)
    {
        super.init()
        
        self.color = color
        self.font = font
        self.textColor = textColor;
        self.insets = insets
        
        _paragraphStyle = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
        _paragraphStyle?.alignment = .center
    }
    
    open override var size: CGSize { return _size; }
    
    open override func draw(context: CGContext, point: CGPoint)
    {
        if (labelns == nil)
        {
            return
        }
        
        let offset = self.offsetForDrawingAtPos(point)
        let arcRadius = CGFloat(5.0)
        
        var rect = CGRect(
            origin: CGPoint(
                x: point.x + offset.x,
                y: point.y + offset.y),
            size: _size)
        rect.origin.x -= _size.width / 2.0
        rect.origin.y -= _size.height + 4
        
        context.saveGState()
        
        context.setFillColor((color?.cgColor)!)
        context.beginPath()
        context.move(to: CGPoint(
            x: rect.origin.x + arcRadius,
            y: rect.origin.y))
        context.addArc(tangent1End: CGPoint(
            x: rect.origin.x + rect.size.width,
            y: rect.origin.y),
                       tangent2End: CGPoint(
                        x: rect.origin.x + rect.size.width,
                        y: rect.origin.y + arcRadius),
                       radius: arcRadius)
        context.addArc(tangent1End: CGPoint(
            x: rect.origin.x + rect.size.width,
            y: rect.origin.y + rect.size.height - arrowSize.height),
                       tangent2End: CGPoint(
                        x: rect.origin.x + rect.size.width - arcRadius,
                        y: rect.origin.y + rect.size.height - arrowSize.height),
                       radius: arcRadius)
        context.addLine(to: CGPoint(
            x: rect.origin.x + (rect.size.width + arrowSize.width) / 2.0 + 2,
            y: rect.origin.y + rect.size.height - arrowSize.height))
        context.addLine(to: CGPoint(
            x: rect.origin.x + rect.size.width / 2.0,
            y: rect.origin.y + rect.size.height))
        context.addLine(to: CGPoint(
            x: rect.origin.x + (rect.size.width - arrowSize.width) / 2.0 + 2,
            y: rect.origin.y + rect.size.height - arrowSize.height))
        context.addArc(tangent1End: CGPoint(
            x: rect.origin.x,
            y: rect.origin.y + rect.size.height - arrowSize.height),
                       tangent2End: CGPoint(
                        x: rect.origin.x,
                        y: rect.origin.y + rect.size.height - arrowSize.height - arcRadius),
                       radius: arcRadius)
        context.addArc(tangent1End: CGPoint(
            x: rect.origin.x,
            y: rect.origin.y),
                       tangent2End: CGPoint(
                        x: rect.origin.x + arcRadius,
                        y: rect.origin.y),
                       radius: arcRadius)
        context.fillPath()
        
        rect.origin.y += self.insets.top
        rect.size.height -= self.insets.top + self.insets.bottom
        
        UIGraphicsPushContext(context)
        
        labelns?.draw(in: rect, withAttributes: _drawAttributes)
        
//        let modifyImg = UIImage.init(named: "health_modify_icon")
//        let modifyRect = CGRect(x: rect.origin.x + rect.size.width/2.0 - 26 - (_labelSize.height/2-2),
//                                y: rect.origin.y + rect.size.height/2 + 2,
//                                width: _labelSize.height/2-2,
//                                height: _labelSize.height/2-2)
//        modifyImg?.draw(in: modifyRect)
        
        if (heartImage != nil) {
            heartImage?.draw(in: CGRect(
                x: rect.origin.x + rect.size.width*0.5 + 26,
                y: rect.origin.y + rect.size.height*0.5 - 2,
                width: _labelSize.height/3 - 2,
                height: _labelSize.height/3 - 2))
        }
        
        UIGraphicsPopContext()
        
        context.restoreGState()
    }
    
    open override func refreshContent(entry: ChartDataEntry, highlight: ChartHighlight)
    {
        if let labelDataDict = entry.data as? NSDictionary {
            let sexNum = labelDataDict["hadSex"] as! NSNumber
            heartImage = (sexNum.intValue) > 0 ? UIImage.init(named: "cr_intercourse_icon") : nil
            
            let num = labelDataDict["periodNo"] as! NSString
            let timeStr = labelDataDict["time"] as! NSString
            let tempStr = labelDataDict["temperature"] as! NSString
            let info = labelDataDict["info"] as! NSString
            labelns = "\(num)\n\(timeStr)\n\(tempStr)\(info)"
        }
        
        _drawAttributes.removeAll()
        _drawAttributes[NSFontAttributeName] = self.font
        _drawAttributes[NSForegroundColorAttributeName] = self.textColor
        _drawAttributes[NSParagraphStyleAttributeName] = _paragraphStyle
        
        _labelSize = labelns?.size(attributes: _drawAttributes) ?? CGSize.zero
        _size.width = 63 + self.insets.left + self.insets.right
        _size.height = _labelSize.height + self.insets.top + self.insets.bottom
        _size.width = max(minimumSize.width, _size.width)
        _size.height = max(minimumSize.height, _size.height)
    }
}
