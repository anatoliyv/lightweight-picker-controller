//
//  ViewController.swift
//  LightweightPickerController
//
//  Created by Anatoliy Voropay on 03/22/2017.
//  Copyright (c) 2017 Anatoliy Voropay. All rights reserved.
//

import UIKit
import LightweightPickerController

class ViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var pickButton: UIButton!
    
    fileprivate var pickerController: LightweightPickerController?

    @IBAction func pressedButton(sender: AnyObject?) {
        pickerController = LightweightPickerController()
        pickerController?.delegate = self
        pickerController?.configuration.picker.title = nil
        pickerController?.imageEditorController.editorType = .image
        pickerController?.imageEditorController.croppedSize = CGSize(width: 600, height: 600)
        pickerController?.imageEditorController.greedSize = (3, 2)
        
        present(pickerController!, animated: false, completion: nil)
        pickerController?.showPickerDialogue(view, sourceRect: view.bounds)
    }
}

extension ViewController: LightweightPickerControllerDelegate {
    
    func lightweightPickerControllerDidCancel(_ controller: LightweightPickerController) {
        controller.dismiss(animated: false, completion: nil)
    }
    
    func lightweightPickerController(_ controller: LightweightPickerController, didSelectImage image: UIImage) {
        controller.dismiss(animated: false, completion: nil)
        print(image)
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
    }
    
    func lightweightPickerController(_ controller: LightweightPickerController, didSelectVideoWithInfo info: [String : AnyObject]) {
        print(info)
        controller.dismiss(animated: false, completion: nil)
    }
}
