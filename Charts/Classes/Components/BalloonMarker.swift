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
    open var borderColor: UIColor?
    open var arrowSize = CGSize(width: 5, height: 5)
    open var font = UIFont.systemFont(ofSize: 12)
    open var textColor = UIColor.darkText
    open var insets = UIEdgeInsets()
    open var minimumSize = CGSize()
    open var area = CGRect()
    @objc var linkColor = UIColor.systemBlue
    
    private var labelns: NSAttributedString?
    private var heartImage: UIImage?
    private var _labelSize: CGSize = CGSize()
    private var _size: CGSize = CGSize()
    
    @objc public init(color: UIColor, borderColor: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets)
    {
        super.init()
        
        self.color = color
        self.borderColor = borderColor
        self.font = font
        self.textColor = textColor
        self.insets = insets
    }
    
    open override var size: CGSize { return _size; }
    
    open override func draw(context: CGContext, point: CGPoint)
    {
        guard let labelns = labelns else { return }
        
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
        context.setStrokeColor((borderColor?.cgColor)!)
        context.setLineWidth(1.0)
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
            x: rect.origin.x + (rect.size.width + arrowSize.width) / 2.0,
            y: rect.origin.y + rect.size.height - arrowSize.height))
        context.addLine(to: CGPoint(
            x: rect.origin.x + rect.size.width / 2.0,
            y: rect.origin.y + rect.size.height))
        context.addLine(to: CGPoint(
            x: rect.origin.x + (rect.size.width - arrowSize.width) / 2.0,
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
//        context.fillPath()
        context.drawPath(using: .fillStroke)
        
        rect.origin.y += self.insets.top
        rect.size.height -= self.insets.top + self.insets.bottom
        
        UIGraphicsPushContext(context)
        
        labelns.draw(in: rect)
        
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
        self.area = rect
    }
    
    open override func refreshContent(entry: ChartDataEntry, highlight: ChartHighlight)
    {
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
        paragraphStyle?.alignment = .left
        
        let attributes: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font: self.font,
            NSAttributedStringKey.foregroundColor: self.textColor,
            NSAttributedStringKey.paragraphStyle: paragraphStyle!
        ]
        if let labelDataDict = entry.data as? NSDictionary {
            let periodNo = labelDataDict["periodNo"] as! NSString
            let bbtTimeStr = (labelDataDict["bbtTimeStr"] as? String ?? "")
            let lhTimeStr = (labelDataDict["lhTimeStr"] as? String ?? "")
            let attrStrM: NSMutableAttributedString = NSMutableAttributedString(string: "\(periodNo)\(bbtTimeStr)\(lhTimeStr)\n", attributes: attributes)
            
            let excStr = (labelDataDict["exception"] as? String ?? "")
            let linkAttr: [NSAttributedStringKey: Any] = [
                NSAttributedStringKey.font: self.font,
                NSAttributedStringKey.foregroundColor: self.linkColor,
                NSAttributedStringKey.paragraphStyle: paragraphStyle!,
                NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue // 这个地方直接使用 NSUnderlineStyle.styleSingle 会造成闪退
            ]
            attrStrM.append(NSAttributedString(string: "\(excStr)", attributes: linkAttr))
            
            labelns = attrStrM.copy() as? NSAttributedString
        }
        
        _labelSize = labelns?.string.size(withAttributes: attributes) ?? CGSize.zero
        _size.width = max(minimumSize.width, _labelSize.width) + 2
        let hig = _labelSize.height + self.insets.top + self.insets.bottom
        _size.height = max(minimumSize.height, hig) + 4
    }
}
