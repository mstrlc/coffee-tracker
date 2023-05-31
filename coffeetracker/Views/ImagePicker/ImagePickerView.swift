//
//  ImagePickerView.swift
//  coffeetracker
//
//  Created by Matyáš Strelec on 25/05/2023.
//
//  Taken from https://designcode.io/swiftui-advanced-handbook-imagepicker
//

import SwiftUI

struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?

    var onImageSelected: (UIImage?) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = context.coordinator
        return imagePicker
    }

    func updateUIViewController(_: UIImagePickerController, context _: Context) {}

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerView

        init(_ parent: ImagePickerView) {
            self.parent = parent
        }

        // Called when an image is picked from the image picker
        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            // Extract the selected image from the info dictionary
            if let selectedImage = info[.originalImage] as? UIImage {
                // Set the capturedImage binding in the parent view
                parent.capturedImage = selectedImage
                // Call the callback closure with the selected image
                parent.onImageSelected(selectedImage)
            }

            picker.dismiss(animated: true, completion: nil)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
    }
}
