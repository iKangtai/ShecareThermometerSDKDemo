//
//  BubbleMarker.swift
//  ChartsDemo
//
//  Created by Daniel Cohen Gindi on 20/6/3.
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

open class BubbleMarker: ChartMarker
{
    open var color: UIColor?
    open var borderColor: UIColor?
    open var arrowSize = CGSize(width: 6, height: 4)
    open var font = UIFont.systemFont(ofSize: 12)
    open var textColor = UIColor.white
    open var insets = UIEdgeInsets()
    open var minimumSize = CGSize()
    open var area = CGRect()
    
    private var labelns: NSAttributedString?
    private var _labelSize: CGSize = CGSize()
    private var _size: CGSize = CGSize(width: 60, height: 26)
    
    @objc public init(color: UIColor, borderColor: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets)
    {
        super.init()
        
        self.color = color
        self.borderColor = borderColor
        self.font = font
        self.textColor = textColor;
        self.insets = insets
    }
    
    open override var size: CGSize { return _size; }
    
    open override func draw(context: CGContext, point: CGPoint)
    {
        guard let labelns = labelns else { return }
        
        let offset = self.offsetForDrawingAtPos(point)
        let arcRadius = CGFloat(4.0)
        
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
                
        UIGraphicsPopContext()
        
        context.restoreGState()
        self.area = rect
    }
    
    open override func refreshContent(entry: ChartDataEntry, highlight: ChartHighlight)
    {
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
        paragraphStyle?.alignment = .center
        
        let attributes: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font: self.font,
            NSAttributedStringKey.foregroundColor: self.textColor,
            NSAttributedStringKey.paragraphStyle: paragraphStyle!,
            NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue
        ]
        if let dict = entry.data as? NSDictionary {
            let periodNo = dict["ycbz"] as! NSString
            let attrStrM: NSMutableAttributedString = NSMutableAttributedString(string: "\(periodNo)", attributes: attributes)
            labelns = attrStrM.copy() as? NSAttributedString
        }
        
        _labelSize = labelns?.string.size(withAttributes: attributes) ?? CGSize.zero
        _size.width = max(minimumSize.width, _labelSize.width) + 4
        let hig = _labelSize.height + self.insets.top + self.insets.bottom
        _size.height = max(minimumSize.height, hig) + 4
    }
}
