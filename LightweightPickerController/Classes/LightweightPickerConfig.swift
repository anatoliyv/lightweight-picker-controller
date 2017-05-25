//
//  LightweightPickerConfig.swift
//  Pods
//
//  Created by Anatoliy Voropay on 5/23/17.
//
//

import UIKit

/// Configuration of `LightweightPickerController`
public struct LightweightPickerConfiguration {
    
    /// Global picker settings
    public struct Global {
        
        /// Picking video quality
        public var videoQuality: UIImagePickerControllerQualityType = .typeMedium
    }
    
    /// Picker messages
    public struct Picker {
        
        /// Title for action sheet view
        public var title: String? = "Select media"
        
        /// Message for action sheet view
        public var message: String? = nil
        
        /// Cancel button title
        public var cancelText = "Cancel"
        
        /// Record a video button title. Will be used if video is allowed only.
        public var shotVideoText = "Record a video"
        
        /// Shot a photo button title. Will be used if photos are allowed only.
        public var shotPhotoText = "Make a shot"
        
        /// Record media button title. Will be used if both photos and videos are allowed.
        public var shotMediaText = "Record media"
        
        /// Select from library button text
        public var selectText = "Select from library"
        
        /// Setting button text. Used on access required alert.
        public var settingsText = "Settings"
        
        /// Permitted arrow directions for iPad popover
        public var permittedArrowDirections: UIPopoverArrowDirection = .any
        
        /// Title for no access alert
        public var accessRequiredAlertTitle: String? = "Error"
        
        /// Message for no access alert
        public var accessRequiredAlertMessage: String? = "This app does not have access to required media. Please enable access in privacy settings clicking on a button below."
    }
    
    public struct ImageEditor {
        
        /// Title for image editor
        public var title: String? = "Zoom and crop an image"
        
        /// Cancel button title
        public var cancelText = "Cancel"
        
        /// Use button title
        public var useText = "Use"
        
        /// Color for unactive area in editor
        public var dimColor: UIColor  = UIColor.black.withAlphaComponent(0.66)
        
        /// Color for cancel and use buttons
        public var buttonColor: UIColor = .white
        
        /// Color for title label
        public var titleColor: UIColor = .white
        
        /// Font for cancel and use buttons
        public var buttonFont = UIFont.systemFont(ofSize: 14)
        
        /// Font for title label
        public var titleFont = UIFont.systemFont(ofSize: 20)
        
        /// Side padding for hole views
        public var holePadding: CGFloat = 20
        
        /// Color of hole border line
        public var borderColor: UIColor = .white
        
        /// Width of hole border line
        public var borderWidth: CGFloat = 1.5
        
        /// Color of greed lines
        public var greedColor: UIColor = UIColor.white.withAlphaComponent(0.5)
        
        /// Width of greed lines
        public var greedWidth: CGFloat = 0.5
    }
    
    public var global: Global = Global()
    public var picker: Picker = Picker()
    public var imageEditor: ImageEditor = ImageEditor()
}
