//
//  LightweightPickerController.swift
//  Pods
//
//  Created by Anatoliy Voropay on 5/23/17.
//
//

import UIKit
import MobileCoreServices
import AssetsLibrary
import Photos

/// Protocol to handle `LightweightPickerController` events
@objc public protocol LightweightPickerControllerDelegate {
    
    /// Picker did select image
    @objc optional func lightweightPickerController(_ controller: LightweightPickerController, didSelectImage image: UIImage)
    
    /// Picker did select video from library
    @objc optional func lightweightPickerController(_ controller: LightweightPickerController, didSelectVideoWithInfo info: [String : AnyObject])
    
    /// Picker selection was cancelled
    func lightweightPickerControllerDidCancel(_ controller: LightweightPickerController)
}

/// Controller to pick media
public class LightweightPickerController: UIViewController {
    
    /// Allowed media types
    public enum MediaType {
        case video
        case photo
    }
    
    /// Sources to pick media from
    public enum MediaSource {
        case camera
        case library
    }
    
    /// Different types  for image editing.
    ///
    /// - `none` indicates that no editor will be used
    /// - `profile` means that circle image editor will apper
    /// - `image` means that square / rectangle editor will be used
    public enum ImageEditorType {
        case none
        case profile
        case image
    }
    
    public weak var delegate: LightweightPickerControllerDelegate?
    
    /// Allowed media types to pick
    public var allowedTypes: [MediaType] = [ .video, .photo ]
    
    /// Allowed media sources to pick
    public var allowedSources: [MediaSource] = [ .camera, .library ]
    
    /// Picker configuraton. Basic customization can be done changing it's properties
    public var configuration: LightweightPickerConfiguration = LightweightPickerConfiguration()
    
    /// You can set up your custom actions by filling this array. They will be added in 
    /// bottom of a list of default actions
    public var additionalActions: [UIAlertAction] = []
    
    /// Used image editor type. Set `.none` if you do not need to edit image.
    public var imageEditorType: ImageEditorType = .image
    
    /// Return `true` if image editor will appear
    public var allowsImageEditing: Bool {
        return imageEditorType != .none
    }
    
    /// Image editor controller
    private(set) public var imageEditorController: LightweightImageEditorController = LightweightImageEditorController()
    
    fileprivate var imagePickerController: UIImagePickerController?
    
    // MARK: Lifecycle
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        customize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customize()
    }
    
    private func customize() {
        view.backgroundColor = .clear
        modalPresentationStyle = .overCurrentContext
    }
    
    // MARK: Show dialogue
    
    /// Shows picker dialogue. `sourceView` and `sourceRect` used for iPad
    public func showPickerDialogue(_ sourceView: UIView, sourceRect: CGRect) {
        let alertController = UIAlertController(
            title: configuration.picker.title,
            message: configuration.picker.message,
            preferredStyle: .actionSheet)
        
        alertController.popoverPresentationController?.sourceView = sourceView
        alertController.popoverPresentationController?.sourceRect = sourceRect
        alertController.popoverPresentationController?.permittedArrowDirections = configuration.picker.permittedArrowDirections
        
        alertController.addAction(UIAlertAction(title: configuration.picker.cancelText, style: .cancel) { (action) in
            self.delegate?.lightweightPickerControllerDidCancel(self)
        })
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(UIAlertAction(title: cameraButtonText, style: .default) { (action) in
                self.showMediaPickerControllerWithType(.camera)
            })
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alertController.addAction(UIAlertAction(title: configuration.picker.selectText, style: .default) { (action) in
                self.showMediaPickerControllerWithType(.photoLibrary)
            })
        }
        
        additionalActions.forEach({ alertController.addAction($0) })
        present(alertController, animated: true) { }
    }
    
    private var cameraButtonText: String {
        if allowedTypes.contains(.video) && allowedTypes.contains(.photo) {
            return configuration.picker.shotMediaText
        } else if allowedTypes.contains(.video) {
            return configuration.picker.shotVideoText
        } else if allowedTypes.contains(.photo) {
            return configuration.picker.shotPhotoText
        } else {
            assertionFailure("You should pick something")
            return ""
        }
    }
    
    // MARK: Show media controller
    
    private func showMediaPickerControllerWithType(_ type: UIImagePickerControllerSourceType) {
        if  ((type == .photoLibrary || type == .savedPhotosAlbum) && PHPhotoLibrary.authorizationStatus() == .denied) ||
            (type == .camera && (AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .denied || AVCaptureDevice.authorizationStatus(for: AVMediaType.audio) == .denied))
        {
            showNoAccessAlert()
            return
        }
        
        if (type == .photoLibrary || type == .savedPhotosAlbum) && PHPhotoLibrary.authorizationStatus() == .notDetermined {
            PHPhotoLibrary.requestAuthorization() { _ in
                self.showMediaPickerControllerWithType(type)
            }
        } else if type == .camera && AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .notDetermined {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { _ in
                self.showMediaPickerControllerWithType(type)
            })
        } else if type == .camera && AVCaptureDevice.authorizationStatus(for: AVMediaType.audio) == .notDetermined {
            AVCaptureDevice.requestAccess(for: AVMediaType.audio, completionHandler: { _ in
                self.showMediaPickerControllerWithType(type)
            })
        } else {
            imagePickerController = UIImagePickerController()
            imagePickerController?.delegate = self
            imagePickerController?.sourceType = type
            imagePickerController?.mediaTypes = allowedMediaTypes
            imagePickerController?.allowsEditing = false
            imagePickerController?.videoQuality = configuration.global.videoQuality
            
            present(imagePickerController!, animated: true) { }
        }
    }
    
    private var allowedMediaTypes: [String] {
        var types: [String] = []
        
        if allowedTypes.contains(.video) {
            types.append(contentsOf: [kUTTypeMovie as String, kUTTypeVideo as String])
        }
        
        if allowedTypes.contains(.photo) {
            types.append(contentsOf: [kUTTypeImage as String])
        }
        
        return types
    }
    
    // MARK: Alerts 
    
    private func showNoAccessAlert() {
        let alert: UIAlertController = UIAlertController(
            title: configuration.picker.accessRequiredAlertTitle,
            message: configuration.picker.message,
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: configuration.picker.cancelText, style: .cancel) { _ in
            self.delegate?.lightweightPickerControllerDidCancel(self)
        })
        
        if  let settingsURL = URL(string: UIApplicationOpenSettingsURLString),
            UIApplication.shared.canOpenURL(settingsURL)
        {
            let settingsAction = UIAlertAction(title: configuration.picker.settingsText, style: .default) { _ in
                self.delegate?.lightweightPickerControllerDidCancel(self)
                UIApplication.shared.openURL(settingsURL)
            }
            alert.addAction(settingsAction)
        }
        
        present(alert, animated: true, completion: nil)
    }
}

/// `UIImagePickerControllerDelegate` protocol implementation
extension LightweightPickerController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: {
            self.delegate?.lightweightPickerControllerDidCancel(self)
        })
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if  let mediaType = info[UIImagePickerControllerMediaType] as? NSString,
            let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            if mediaType.isEqual(to: kUTTypeImage as String) {
                if allowsImageEditing {
                    showImageEditor(withType: imageEditorType, source: image)
                } else {
                    picker.dismiss(animated: true, completion: {
                        self.delegate?.lightweightPickerController?(
                            self,
                            didSelectImage: image)
                    })
                }
            }
        } else if let mediaType = info[UIImagePickerControllerMediaType] as? NSString {
            if mediaType.isEqual(to: kUTTypeMovie as String) {
                picker.dismiss(animated: true, completion: {
                    self.delegate?.lightweightPickerController?(
                        self,
                        didSelectVideoWithInfo: info as [String : AnyObject])
                })
            }
        } else {
            picker.dismiss(animated: true, completion: {
                self.delegate?.lightweightPickerControllerDidCancel(self)
            })
        }
    }
}

/// `LightweightImageEditorControllerDelegate` protocol implementation
extension LightweightPickerController: LightweightImageEditorControllerDelegate {

    fileprivate func showImageEditor(withType type: ImageEditorType, source: Any) {
        if  let image = source as? UIImage,
            type == .image
        {
            imageEditorController.setup(
                withImage: image,
                configuration: configuration,
                delegate: self)
            
            imagePickerController?.present(imageEditorController, animated: true, completion: nil)
        } else {
            assertionFailure("Editor is not develoiped for this media type.")
        }
    }

    public func lightweightImageEditorControllerDidCancel(_ controller: LightweightImageEditorController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    public func lightweightImageEditorController(_ controller: LightweightImageEditorController, didEndEditingImage image: UIImage) {
        controller.dismiss(animated: true, completion: {
            self.imagePickerController?.dismiss(animated: true, completion: {
                self.delegate?.lightweightPickerController?(self, didSelectImage: image)
            })
        })
    }
}
