//
//  LightweightEditController.swift
//  Pods
//
//  Created by Anatoliy Voropay on 5/23/17.
//
//

import UIKit

/// Protocol to handle `LightweightImageEditorController` events
@objc public protocol LightweightImageEditorControllerDelegate {
    
    /// User did end editing image
    func lightweightImageEditorController(_ controller: LightweightImageEditorController, didEndEditingImage image: UIImage)
    
    /// User did cancel image editing
    func lightweightImageEditorControllerDidCancel(_ controller: LightweightImageEditorController)
}

/// Controller to edit images
public class LightweightImageEditorController: UIViewController {
    
    /// Contains horizontal and vertical number of greed lines
    public typealias GreedSize = (Int, Int)
    
    weak var delegate: LightweightImageEditorControllerDelegate!
    
    /// Cropped image size
    public var croppedSize: CGSize = CGSize(width: 800, height: 600)
    
    /// Image editor type
    public var editorType: LightweightPickerController.ImageEditorType = .image
    
    /// Number of horizontal and vertical lines in a greed. Will be used for
    /// .image editor type only and ignored in .profile.
    public var greedSize: GreedSize = (0, 0)
    
    /// Image that will be edited
    var image: UIImage?
    
    /// Configuration
    var configuration: LightweightPickerConfiguration?
    
    private(set) var circleView = LightweightCircleView(frame: CGRect.zero)
    private(set) var rectangleView = LightweightRectangleView(frame: CGRect.zero)
    private(set) var titleLabel = UILabel()
    private(set) var cancelButton = UIButton()
    private(set) var useButton = UIButton()
    
    fileprivate var scrollView: UIScrollView?
    fileprivate var imageView: UIImageView?
    
    // MARK: Lifecycle
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupImageView()
        setupScrollView()
        customizeButtonFrames()
        titleLabel.isHidden = (view.frame.width > view.frame.height)
    }
    
    private func customize() {
        guard let configuration = configuration else { return }
        
        titleLabel.text = configuration.imageEditor.title
        titleLabel.textColor = configuration.imageEditor.titleColor
        titleLabel.font = configuration.imageEditor.titleFont
        
        cancelButton.setTitle(configuration.imageEditor.cancelText, for: .normal)
        cancelButton.setTitleColor(configuration.imageEditor.buttonColor, for: .normal)
        cancelButton.titleLabel?.font = configuration.imageEditor.buttonFont
        
        useButton.setTitle(configuration.imageEditor.useText, for: .normal)
        useButton.setTitleColor(configuration.imageEditor.buttonColor, for: .normal)
        useButton.titleLabel?.font = configuration.imageEditor.buttonFont
        
        circleView.dimColor = configuration.imageEditor.dimColor
        circleView.borderColor = configuration.imageEditor.borderColor
        circleView.borderWidth = configuration.imageEditor.borderWidth
        circleView.padding = configuration.imageEditor.holePadding
        circleView.setNeedsDisplay()
            
        rectangleView.dimColor = configuration.imageEditor.dimColor
        rectangleView.borderColor = configuration.imageEditor.borderColor
        rectangleView.borderWidth = configuration.imageEditor.borderWidth
        rectangleView.gridColor = configuration.imageEditor.greedColor
        rectangleView.gridWidth = configuration.imageEditor.greedWidth
        rectangleView.padding = configuration.imageEditor.holePadding
        rectangleView.setNeedsDisplay()
        
        useButton.addTarget(self, action: #selector(pressedUse(_:)), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(pressedCancel(_:)), for: .touchUpInside)
        
        rectangleView.gridSize = greedSize
        rectangleView.croppedSize = croppedSize
        rectangleView.isHidden = ( editorType == .profile || editorType == .none )
        
        circleView.croppedSize = croppedSize
        circleView.isHidden = ( editorType == .image || editorType == .none )
    }
    
    private func customizeButtonFrames() {
        cancelButton.sizeToFit()
        useButton.sizeToFit()
        
        useButton.frame = CGRect(
            x: view.frame.width - useButton.frame.size.width - 20,
            y: view.frame.height - useButton.frame.size.height - 20,
            width: useButton.frame.size.width,
            height: useButton.frame.size.height)
        
        cancelButton.frame = CGRect(
            x: 20,
            y: view.frame.height - cancelButton.frame.size.height - 20,
            width: cancelButton.frame.size.width,
            height: cancelButton.frame.size.height)
    }
    
    // MARK: Show editor
    
    func setup(withImage image: UIImage, configuration: LightweightPickerConfiguration, delegate: LightweightImageEditorControllerDelegate) {
        self.image = image
        self.configuration = configuration
        self.delegate = delegate
        
        view.clipsToBounds = true
        view.backgroundColor = .black
        
        circleView.frame = view.bounds
        circleView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        rectangleView.frame = view.bounds
        rectangleView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        titleLabel.frame = CGRect(x: 20, y: 20, width: view.frame.width - 40, height: 40)
        titleLabel.textAlignment = .center
        titleLabel.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        
        view.addSubview(circleView)
        view.addSubview(rectangleView)
        view.addSubview(titleLabel)
        view.addSubview(cancelButton)
        view.addSubview(useButton)
        
        customize()
        setupImageView()
        setupScrollView()
        centerImageView(animated: false)
    }
    
    // MARK: Scrolling
    
    fileprivate func setupImageView() {
        guard let image = image else { return }
        
        imageView?.removeFromSuperview()
        imageView = UIImageView(image: image)
        imageView?.isUserInteractionEnabled = false
    }
    
    fileprivate func setupScrollView() {
        guard let imageView = imageView else { return }
        guard let image = imageView.image else { return }
        
        var minZoom = fmax(cropAreaFrame.size.width / image.size.width, cropAreaFrame.size.height / image.size.height)
        minZoom = fmin(1.0, minZoom)
        
        scrollView?.removeFromSuperview()
        scrollView = UIScrollView(frame: cropAreaFrame)
        scrollView?.clipsToBounds = false
        scrollView?.maximumZoomScale = 4.0
        scrollView?.minimumZoomScale = minZoom
        scrollView?.delegate = self
        scrollView?.setZoomScale(minZoom * 1.1, animated: false)
        scrollView?.showsVerticalScrollIndicator = false
        scrollView?.showsHorizontalScrollIndicator = false
        scrollView?.center = view.center
        
        if let zoomScale = scrollView?.zoomScale {
            scrollView?.contentOffset = CGPoint(
                x: (image.size.width * zoomScale - cropAreaFrame.size.width) / 2,
                y: (image.size.height * zoomScale - cropAreaFrame.size.height) / 2)
        }

        scrollView?.addSubview(imageView)
        view.insertSubview(scrollView!, belowSubview: circleView)
    }
    
    private var cropAreaFrame: CGRect {
        switch editorType {
        case .image:
            return rectangleView.holeRect(forRect: view.bounds)
            
        case .profile:
            return circleView.circleRect(forRect: view.bounds)
            
        default:
            assertionFailure("Incorrect editor type")
            return CGRect.zero
        }
    }
    
    fileprivate func centerImageView(animated: Bool = true) {
        guard let imageView = imageView else { return }
        
        var frameToCenter = imageView.frame
        if frameToCenter.width < cropAreaFrame.size.width {
            frameToCenter.size.width = cropAreaFrame.size.width
            frameToCenter.size.height *= cropAreaFrame.size.width / frameToCenter.width
        } else if frameToCenter.height < cropAreaFrame.size.height {
            frameToCenter.size.height = cropAreaFrame.size.height
            frameToCenter.size.width *= cropAreaFrame.size.height / frameToCenter.height
        }
        
        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                imageView.frame = frameToCenter
            })
        } else {
            imageView.frame = frameToCenter
        }
    }
    
    // MARK: Actions
    
    @objc private func pressedCancel(_ sender: AnyObject?) {
        delegate?.lightweightImageEditorControllerDidCancel(self)
    }
    
    @objc private func pressedUse(_ sender: AnyObject?) {
        guard let imageView = imageView else { return }
        guard let image = imageView.image else { return }
        guard let scrollView = scrollView else { return }
        
        var areaSize = cropAreaFrame.size
        let scale = scrollView.zoomScale
        
        areaSize.width = areaSize.width / scale
        areaSize.height = areaSize.height / scale
        
        var position = scrollView.contentOffset
        position.x = position.x / scale
        position.y = position.y / scale
        
        if  let croppedImage = cropImage(image, position: position, size: areaSize),
            let scaledImage = scaleImage(croppedImage, toSize: croppedSize)
        {
            delegate?.lightweightImageEditorController(self, didEndEditingImage: scaledImage)
        } else {
            assertionFailure("Something goes wrong while cropping")
            delegate?.lightweightImageEditorControllerDidCancel(self)
        }
    }
    
    private func cropImage(_ image: UIImage, position: CGPoint, size: CGSize) -> UIImage? {
        let rect = CGRect(origin: position, size: size)
        
        UIGraphicsBeginImageContext(rect.size)
        
        let context = UIGraphicsGetCurrentContext()
        context?.clip(to: CGRect(x: 0, y: 0, width: rect.size.width, height: rect.size.height))
        
        let drawRect = CGRect(x: -rect.origin.x, y: -rect.origin.y, width: image.size.width, height: image.size.height)
        image.draw(in: drawRect)
        
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return croppedImage
    }
    
    private func scaleImage(_ image: UIImage, toSize size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0);
        image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}

// `UIScrollViewDelegate` protocol implementation
extension LightweightImageEditorController: UIScrollViewDelegate {
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        centerImageView()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        centerImageView()
    }
}

// Status bar
extension LightweightImageEditorController {
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
}

/// Parent view for all hole-containing views
public class LightweightHoleView: UIView {
    
    /// Side padding
    var padding: CGFloat = 0
    
    /// Color for not active area
    var dimColor: UIColor = .black
    
    /// Required cropped image size
    var croppedSize: CGSize = .zero
    
    /// Border width
    var borderWidth: CGFloat = 0
    
    /// Color of a border
    var borderColor: UIColor = .white
    
    // MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        backgroundColor = .clear
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }
}

/// View for circle hole
public class LightweightCircleView: LightweightHoleView {
    
    public func circleRect(forRect rect: CGRect) -> CGRect {
        let width = fmin(rect.width, rect.height) - padding * 2
        return CGRect(x: (rect.width - width) / 2, y: (rect.height - width) / 2, width: width, height: width)
    }
    
    override public func draw(_ rect: CGRect) {
        let circleRect = self.circleRect(forRect: rect)
        let context = UIGraphicsGetCurrentContext()

        // Dim
        
        context?.setFillColor(dimColor.cgColor)
        context?.fill(rect)
        
        // Draw circle
        
        context?.addEllipse(in: circleRect)
        context?.clip()
        context?.clear(circleRect)
        context?.setFillColor(UIColor.clear.cgColor)
        context?.fill(rect)
        
        // Draw border
        
        if borderWidth > 0 {
            context?.setLineWidth(borderWidth)
            context?.setStrokeColor(borderColor.cgColor)
            context?.strokeEllipse(in: circleRect)
        }
    }
}

/// View for circle hole
public class LightweightRectangleView: LightweightHoleView {
    
    /// Number of horizontal and vertical grid lines
    var gridSize: (Int, Int) = (0, 0)
    
    /// Color of a greed lines
    var gridColor: UIColor = .gray
    
    /// Greed line width
    var gridWidth: CGFloat = 0
    
    public func holeRect(forRect rect: CGRect) -> CGRect {
        let maxWidth = rect.width - padding * 2
        let maxHeight = rect.height - padding * 2
        let factor = croppedSize.width / croppedSize.height
        var holeRect = CGRect.zero
        
        if maxWidth / maxHeight > factor {
            holeRect.size = CGSize(width: maxHeight * factor, height: maxHeight)
            holeRect.origin.x = (rect.width - holeRect.size.width) / 2
            holeRect.origin.y = padding
        } else {
            holeRect.size = CGSize(width: maxWidth, height: maxWidth / factor)
            holeRect.origin.x = padding
            holeRect.origin.y = (rect.height - holeRect.size.height) / 2
        }
        
        return holeRect
    }
    
    override public func draw(_ rect: CGRect) {
        let holeRect = self.holeRect(forRect: rect)
        let context = UIGraphicsGetCurrentContext()
        
        // Draw hole

        context?.setFillColor(dimColor.cgColor)
        context?.fill(rect)
        context?.clear(holeRect)
        context?.setFillColor(UIColor.clear.cgColor)
        context?.fill(rect)
        
        // Draw grid
        
        context?.setLineWidth(gridWidth)
        context?.setStrokeColor(gridColor.cgColor)
        
        if gridSize.0 > 0 {
            let count = gridSize.0 + 1
            let space = holeRect.size.width / CGFloat(count)
            
            for i in 1..<count {
                let x = holeRect.origin.x + space * CGFloat(i)
                context?.move(to: CGPoint(x: x, y: holeRect.origin.y))
                context?.addLine(to: CGPoint(x: x, y: holeRect.origin.y + holeRect.size.height))
                context?.strokePath()
            }
        }
        
        if gridSize.1 > 0 {
            let count = gridSize.1 + 1
            let space = holeRect.size.height / CGFloat(count)
            
            for i in 1..<count {
                let y = holeRect.origin.y + space * CGFloat(i)
                context?.move(to: CGPoint(x: holeRect.origin.x, y: y))
                context?.addLine(to: CGPoint(x: holeRect.origin.x + holeRect.size.width, y: y))
                context?.strokePath()
            }
        }
        
        // Draw border
        
        if borderWidth > 0 {
            context?.setLineWidth(borderWidth)
            context?.setStrokeColor(borderColor.cgColor)
            
            let path = UIBezierPath(rect: holeRect)
            path.stroke()
        }
    }
}

