/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation

// Notification when new photo instances are added
let photoManagerContentAddedNotification = "com.raywenderlich.GooglyPuff.PhotoManagerContentAdded"
// Notification when content updates (i.e. Download finishes)
let photoManagerContentUpdatedNotification = "com.raywenderlich.GooglyPuff.PhotoManagerContentUpdated"

// Photo Credit: Devin Begley, http://www.devinbegley.com/
let overlyAttachedGirlfriendURLString = "http://i.imgur.com/UvqEgCv.png"
let successKidURLString = "http://i.imgur.com/dZ5wRtb.png"
let lotsOfFacesURLString = "http://i.imgur.com/tPzTg7A.jpg"

typealias PhotoProcessingProgressClosure = (_ completionPercentage: CGFloat) -> Void
typealias BatchPhotoDownloadingCompletionClosure = (_ error: NSError?) -> Void

private let _sharedManager = PhotoManager()

class PhotoManager {
  class var sharedManager: PhotoManager {
    return _sharedManager
  }
  
  fileprivate var _photos: [Photo] = []
  var photos: [Photo] {
    var photosCopy: [Photo]!
    // sync will wait till the barrier item finish
    concurrentPhotoQueue.sync {
        photosCopy = self._photos
    }
    return photosCopy
  }

  //set a custom queue
  fileprivate let concurrentPhotoQueue = DispatchQueue(
    label: "com.raywenderlich.GooglyPuff.photoQueue",
    attributes: .concurrent)
  
  func addPhoto(_ photo: Photo) {
    //set a barrier item to queue, make sure its execute alone
    concurrentPhotoQueue.async(flags: .barrier) {
        self._photos.append(photo)
        DispatchQueue.main.async {
            self.postContentAddedNotification()
        }
    }
  }
  
  func downloadPhotosWithCompletion(_ completion: BatchPhotoDownloadingCompletionClosure?) {
    /* Approach 1 -> clumsy
    //use async to place the entire method into a background queue to ensure you don’t block the main thread
    DispatchQueue.global(qos: .userInitiated).async {
        var storedError: NSError?
        let downloadGroup = DispatchGroup()  //creates a new dispatch group.
        for address in [overlyAttachedGirlfriendURLString,successKidURLString,lotsOfFacesURLString] {
            let url = URL(string: address)
            downloadGroup.enter()  //manually notify the group that a task has started
            let photo = DownloadPhoto(url: url!) {
                _, error in
                if error != nil {
                    storedError = error
                }
                downloadGroup.leave()
            }
            PhotoManager.sharedManager.addPhoto(photo)
        }
        downloadGroup.wait()  //waiting for tasks’ completion
        DispatchQueue.main.async {
            completion?(storedError)
        }
    }*/
    /*
     let _ = DispatchQueue.global(qos: .userInitiated)
     DispatchQueue.concurrentPerform(iterations: addresses.count) { i in
     let index = Int(i)
     let address = addresses[index]
     let url = URL(string: address)
     downloadGroup.enter()  //manually notify the group that a task has started
     let photo = DownloadPhoto(url: url!) {
     _, error in
     if error != nil {
     storedError = error
     }
     downloadGroup.leave()
     }
     PhotoManager.sharedManager.addPhoto(photo)
     }
     
     downloadGroup.notify(queue: DispatchQueue.main) {
     completion?(storedError)
     }
     */
    
    
    var storedError: NSError?
    let downloadGroup = DispatchGroup()  //creates a new dispatch group.
    var addresses = [overlyAttachedGirlfriendURLString,successKidURLString,lotsOfFacesURLString]
    addresses += addresses + addresses
    var blocks: [DispatchWorkItem] = []
    
    for i in 0 ..< addresses.count {
        downloadGroup.enter()
        //pass in a flags parameter to specify that the block should inherit its Quality of Service class from the queue it is dispatched to.
        let block = DispatchWorkItem(flags: .inheritQoS) {
            let index = Int(i)
            let address = addresses[index]
            let url = URL(string: address)
            downloadGroup.enter()  //manually notify the group that a task has started
            let photo = DownloadPhoto(url: url!) {
                _, error in
                if error != nil {
                    storedError = error
                }
                downloadGroup.leave()
            }
            PhotoManager.sharedManager.addPhoto(photo)
        }
        blocks.append(block)
        DispatchQueue.main.async(execute: block)
    }
    
    for block in blocks[3 ..< blocks.count] {
        let cancel = arc4random_uniform(2)
        if cancel == 1 {
            block.cancel()
            downloadGroup.leave()
        }
    }
    
    downloadGroup.notify(queue: DispatchQueue.main) {
        completion?(storedError)
    }
    
  }
  
  fileprivate func postContentAddedNotification() {
    NotificationCenter.default.post(name: Notification.Name(rawValue: photoManagerContentAddedNotification), object: nil)
  }
}
