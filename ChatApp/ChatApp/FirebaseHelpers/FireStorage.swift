//
//  FireStorage.swift
//  ChatApp
//
//  Created by Sophia Zhu on 9/9/21.
//

import Foundation
import FirebaseStorage

import ProgressHUD

let storage = Storage.storage()

class FileStorage {
    
    // MARK: - Images
    class func uploadImage(_ image: UIImage, directory: String, completion: @escaping (_ documentLink: String?) -> Void) {
        //cant put uiimage in firebase
        
        let storageRef = storage.reference(forURL: kFILEREFERENCE).child(directory)
        
        let imageData = image.jpegData(compressionQuality: 0.6)
        var task: StorageUploadTask!
        
        task = storageRef.putData(imageData!, metadata: nil, completion: { (metadata, error) in
            task.removeAllObservers()
            ProgressHUD.dismiss()
            if error != nil {
                print("error uploading image \(error!.localizedDescription)")
                return
            }
            storageRef.downloadURL { (url, error) in
                guard let downloadUrl = url else {
                    completion(nil)
                    return
                }
                completion(downloadUrl.absoluteString)
            }
        })
        
        task.observe(StorageTaskStatus.progress) { (snapshot) in
            let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
            ProgressHUD.showProgress(CGFloat(progress))
            
        }
        
    }
    
    // MARK: - save locally
    class func saveFileLocally(fileData: NSData, fileName: String) {
        getDocumentsURL().appendingPathComponent(fileName, isDirectory: false)
        fileData.write(to: getDocumentsURL(), atomically: true)
    }
    
}


//Helpers
func fileInDocumentsDirectory(fileName: String) -> String {
    return getDocumentsURL().appendingPathComponent(fileName).path
    
}

func getDocumentsURL() -> URL {
    
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    
}


func fileExistsAtPath(path: String) -> Bool {
    let filePath = fileInDocumentsDirectory(fileName: path)
    let fileManager = FileManager.default
    return fileManager.fileExists(atPath: filePath)
    
}
