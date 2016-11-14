//
//  ViewController.swift
//  MemeMe
//
//  Created by Alejandro Ayala-Hurtado on 10/30/16.
//  Copyright © 2016 MobileApps. All rights reserved.
//

import UIKit

class ImageMemeController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    let ImagePicker = UIImagePickerController()
    @IBOutlet weak var topLabel: UITextField!
    @IBOutlet weak var bottomLabel: UITextField!
    @IBOutlet weak var ImageView: UIImageView!
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var toolBar: UIToolbar!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    var topLabelEdited = false
    var bottomLabelEdited = false

    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        
        topLabel.endEditing(true)
        bottomLabel.endEditing(true)
        ImageView.image = nil
        topLabel.text = Constants().TOP
        bottomLabel.text = Constants().BOTTOM
        actionButton.isEnabled = false
        cancelButton.isEnabled = false
        topLabelEdited = false
        bottomLabelEdited = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        setKeyboardNotifications()
        setUpTextfields()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardNotifications()
    }
    
    override func viewDidLoad() {
       super.viewDidLoad()
        
       setInitialStateOfButtons()
        
       setUpDelegates()



       
        


        // Do any additional setup after loading the view, typically from a nib
        
    }
   
    
    private func setInitialStateOfButtons() {
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        actionButton.isEnabled = false
        cancelButton.isEnabled = false
        
    }
    
    let memeTextAttributes: [String: Any] = [
        NSStrokeColorAttributeName: UIColor.black,
        NSForegroundColorAttributeName: UIColor.white,
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 50)!,
        NSStrokeWidthAttributeName: -3.0]
    
    private func setUpTextfields() {
        topLabel.defaultTextAttributes = memeTextAttributes
        bottomLabel.defaultTextAttributes = memeTextAttributes
        topLabel.text = Constants().TOP
        bottomLabel.text = Constants().BOTTOM


        topLabel.textAlignment = .center
        bottomLabel.textAlignment = .center

        topLabel.sizeToFit()
        bottomLabel.sizeToFit()

    }
    
    private func setUpDelegates() {
        ImagePicker.delegate = self
        topLabel.delegate = self
        bottomLabel.delegate = self
    }
    
    private func setKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    
    private func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self,name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self,name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        if self.view.frame.origin.y == 0 && !topLabel.isFirstResponder{
            self.view.frame.origin.y -= calculateKeyboardHeight(notification: notification)
        }

    }
    
    
    @objc private func keyboardWillHide(notification: Notification) {
        if self.view.frame.origin.y != 0{
            self.view.frame.origin.y += calculateKeyboardHeight(notification: notification)
        }

    }
    
    private func calculateKeyboardHeight(notification: Notification) -> CGFloat {
        let userInfo  = notification.userInfo!
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue ).cgRectValue
        return keyboardScreenEndFrame.height
    }

    private func generateMeme() -> UIImage {
        navBar.isHidden = true
        toolBar.isHidden = true
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        navBar.isHidden = false
        toolBar.isHidden = false
        return memedImage
    }
    
    @IBAction func displayActivityView(_ sender: UIBarButtonItem) {
        
        
        

        let meme = generateMeme()
        let controller = UIActivityViewController(activityItems: [meme], applicationActivities: nil)
        controller.completionWithItemsHandler = {activity, success, items, error in
            if success {
                self.saveMeme(image: meme)
            }
            
        }
        present(controller, animated: true, completion: nil)

    }
    
    private func saveMeme(image: UIImage) {
       // let meme = ImageModel(topLabel: topLabel.text!, bottomLabel: bottomLabel.text!, originalImage: ImageView.image!, memedImage: image)
        
    }
    
    @IBAction func displayPhotoLibrary(_ sender: UIBarButtonItem) {
    
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)) {
            if let mediaTypes = UIImagePickerController.availableMediaTypes(for: UIImagePickerControllerSourceType.photoLibrary) {
                ImagePicker.mediaTypes = mediaTypes
            }
            present(ImagePicker, animated: true, completion: nil)
            
        }
   
    }
    
    
    
    @IBAction func displayCamera(_ sender: UIBarButtonItem) {

        if(cameraButton.isEnabled) {
            if let mediaTypes = UIImagePickerController.availableMediaTypes(for: UIImagePickerControllerSourceType.camera) {
                ImagePicker.mediaTypes = mediaTypes
            }
            present(ImagePicker, animated: true, completion: nil)
            
        }
     
    }
    
    func imagePickerController(_ picker: UIImagePickerController,didFinishPickingMediaWithInfo info: [String : Any]) {
        //print(info[UIImagePickerControllerOriginalImage] )
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        ImageView.image = selectedImage
        ImageView.contentMode = .scaleAspectFit
        dismiss(animated: true, completion: nil)
        actionButton.isEnabled = true
        cancelButton.isEnabled = true
    }

    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if (textField.tag == 0 && !topLabelEdited) {
            textField.text = ""
            topLabelEdited = true
        } else if (textField.tag == 1 && !bottomLabelEdited) {
            textField.text = ""
            bottomLabelEdited = true
        }
        cancelButton.isEnabled = true
        return true
        
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = ""
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
  
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //NotificationCenter.default.removeObserver(self)
        // Dispose of any resources that can be recreated.
        
    }

    
    
    
    

}

