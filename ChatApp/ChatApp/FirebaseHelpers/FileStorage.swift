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
    
    class func downloadImage(imageUrl: String, completion: @escaping(_ image: UIImage?) -> Void) {
//        print("URL is ", imageUrl)
//        print(fileNameFrom(fileUrl: imageUrl))
        let imageFileName = fileNameFrom(fileUrl: imageUrl)
        if fileExistsAtPath(path: imageFileName) {
            //get it locally
            print("we have local image")
            if let contentsOfFile = UIImage(contentsOfFile: fileInDocumentsDirectory(fileName: imageFileName)) {
                completion(contentsOfFile)
            } else {
                print("couldnt convert local image")
                completion(UIImage(named: "avatar"))
                
                
            }
        } else {
            //download from firebase
            print("let's get from firebase")
            if imageUrl != "" {
                let documentUrl = URL(string: imageUrl)
                let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
                downloadQueue.async {
                    let data  = NSData(contentsOf: documentUrl!)
                    if data != nil {
                        //save locally
                        FileStorage.saveFileLocally(fileData: data!, fileName: imageFileName)
                        DispatchQueue.main.async {
                            completion(UIImage(data: data! as Data))
                        }
                    } else {
                        print("no document in database")
                        completion(nil)
                    }
                }
            }
        }
    }
    
    
    // MARK: - save locally
    class func saveFileLocally(fileData: NSData, fileName: String) {
        getDocumentsURL().appendingPathComponent(fileName, isDirectory: false)
        fileData.write(to: getDocumentsURL(), atomically: true)
    }
    
    //MARK: - Video
    class func uploadVideo(_ video: NSData, directory: String, completion: @escaping (_ videoLink: String?) -> Void) {
            //cant put uiimage in firebase
            
            let storageRef = storage.reference(forURL: kFILEREFERENCE).child(directory)
            
            var task: StorageUploadTask!
            
            task = storageRef.putData(video as Data, metadata: nil, completion: { (metadata, error) in
                task.removeAllObservers()
                ProgressHUD.dismiss()
                if error != nil {
                    print("error uploading video \(error!.localizedDescription)")
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


    class func downloadVideo(videoLink: String, completion: @escaping(_ isReadyToPlay: Bool, _ videoFileName: String) -> Void) {
        
        let videoUrl = URL(string: videoLink)
        let videoFileName = fileNameFrom(fileUrl: videoLink) + ".mov"
        
        if fileExistsAtPath(path: videoFileName) {
            completion(true, videoFileName)
        } else {
            let downloadQueue = DispatchQueue(label: "videoDownloadQueue")
            downloadQueue.async {
                let data  = NSData(contentsOf: videoUrl!)
                if data != nil {
                    //save locally
                    FileStorage.saveFileLocally(fileData: data!, fileName: videoFileName)
                    DispatchQueue.main.async {
                        completion(true, videoFileName)
                    }
                } else {
                    print("no document in database")
                }
            }
        }
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
