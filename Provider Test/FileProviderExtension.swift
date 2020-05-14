//
//  FileProviderExtension.swift
//  Provider Test
//
//  Created by admin on 2020/5/9.
//  Copyright © 2020 KODCloud. All rights reserved.
//

import FileProvider

class FileProviderExtension: NSFileProviderExtension {
    
    var fileManager = FileManager()
    
    override init() {
        super.init()
    }
    
    override func item(for identifier: NSFileProviderItemIdentifier) throws -> NSFileProviderItem {
         print("ItemForidentifier")
        // 根据identifier返回一个Item
        guard let reference = ItemReference(itemIdentifier: identifier) else {
          throw NSError.fileProviderErrorForNonExistentItem(withIdentifier: identifier)
        }
        // TODO: implement the actual lookup
        return FileProviderItem(reference: reference)
    }
    
    //MARK:-  根据identifier初始化一个本地对应位置代表文件，并将本地位置返回
    override func urlForItem(withPersistentIdentifier identifier: NSFileProviderItemIdentifier) -> URL? {
        
        // resolve the given identifier to a file on disk
        guard let item = try? item(for: identifier) else {
            return nil
        }
        
        // 构造本地存储的URL： <base storage directory>/<item identifier>/<item file name>
        let manager = NSFileProviderManager.default
        let perItemDirectory = manager.documentStorageURL.appendingPathComponent(identifier.rawValue, isDirectory: true)
        print("UrlFroItem")
        return perItemDirectory.appendingPathComponent(item.filename, isDirectory:false)
    }
    
    // MARK:- 每个URL（本地文件的位置）对应的唯一标识
    override func persistentIdentifierForItem(at url: URL) -> NSFileProviderItemIdentifier? {
        // resolve the given URL to a persistent identifier using a database
        print("persistentIdentifierForItem")
        let identifier = url.deletingLastPathComponent().lastPathComponent
        return NSFileProviderItemIdentifier(identifier)
    }
    
    // MARK:- 以下两个方法都是为虚拟文件创建对应的本地存储位置
    private func providePlaceholder(at url: URL) throws {
        print("providePlaceholder")
      guard
        let identifier = persistentIdentifierForItem(at: url),
        let reference = ItemReference(itemIdentifier: identifier)
        else {
          throw FileProviderError.unableToFindMetadataForPlaceholder
      }
      
      try fileManager.createDirectory(
        at: url.deletingLastPathComponent(),
        withIntermediateDirectories: true,
        attributes: nil
      )
      
      let placeholderURL = NSFileProviderManager.placeholderURL(for: url)
      let item = FileProviderItem(reference: reference)
      
      try NSFileProviderManager.writePlaceholder(
        at: placeholderURL,
        withMetadata: item
      )
    }
    
    override func providePlaceholder(at url: URL, completionHandler: @escaping (Error?) -> Void) {
        print("providePlaceholder completionHandler")
         do {
             try providePlaceholder(at: url)
             completionHandler(nil)
           } catch {
             completionHandler(error)
           }
    }
    
    //MARK:- 可以处理缩略图下载显示等问题
    override func startProvidingItem(at url: URL, completionHandler: @escaping ((_ error: Error?) -> Void)) {
        print("startProvidingItem")
        guard !fileManager.fileExists(atPath: url.path) else {
          completionHandler(nil)
          return
        }
        
        guard
          let identifier = persistentIdentifierForItem(at: url),
          let reference = ItemReference(itemIdentifier: identifier)
          else {
            completionHandler(FileProviderError.unableToFindMetadataForItem)
            return
        }
        
        // 处理缩略图
//         let name = reference.filename
//       let path = reference.containingDirectory
//       NetworkClient.shared.downloadMediaItem(named: name, at: path, isPreview: false) { fileURL, error in
//         guard let fileURL = fileURL else {
//           completionHandler(error)
//           return
//         }
//
//         do { //将下载的文件移动到相应位置
//           try self.fileManager.moveItem(at: fileURL, to: url)
//           completionHandler(nil)
//         } catch {
//           completionHandler(error)
//         }
//       }
    }
    
    
    override func itemChanged(at url: URL) {
        print("itemChanged")
        // Called at some point after the file has changed; the provider may then trigger an upload
        
        /* TODO:
         - mark file at <url> as needing an update in the model
         - if there are existing NSURLSessionTasks uploading this file, cancel them
         - create a fresh background NSURLSessionTask and schedule it to upload the current modifications
         - register the NSURLSessionTask with NSFileProviderManager to provide progress updates
         */
    }
    
    override func stopProvidingItem(at url: URL) {
        print("stopProvidingItem")
        try? fileManager.removeItem(at: url)
        try? providePlaceholder(at: url)
        
        // TODO: look up whether the file has local changes
//        let fileHasLocalChanges = false
//        
//        if !fileHasLocalChanges {
//            // remove the existing file to free up space
//            do {
//                _ = try FileManager.default.removeItem(at: url)
//            } catch {
//                // Handle error
//            }
//            
//            // write out a placeholder to facilitate future property lookups
//            self.providePlaceholder(at: url, completionHandler: { error in
//                // TODO: handle any error, do any necessary cleanup
//            })
//        }
    }
    
    // MARK: - 页面目录更改的时候会调用这个方法 返回一个新的FileProviderEnumerator以提供数据
    override func enumerator(for containerItemIdentifier: NSFileProviderItemIdentifier) throws -> NSFileProviderEnumerator {
        if (containerItemIdentifier == NSFileProviderItemIdentifier.rootContainer) {
            // TODO: instantiate an enumerator for the container root
            return FileProviderEnumerator(path: "/")
        }
        if (containerItemIdentifier == NSFileProviderItemIdentifier.workingSet) {
            // TODO: instantiate an enumerator for the container root
            return FileProviderEnumerator(path: "/workingSet")
        }
        guard
          let ref = ItemReference(itemIdentifier: containerItemIdentifier),
          ref.isDirectory
          else {
            throw FileProviderError.noContentFromServer
        }
        return FileProviderEnumerator(path: ref.path)
    }

}


enum FileProviderError: Error {
  case unableToFindMetadataForPlaceholder
  case unableToFindMetadataForItem
  case notAContainer
  case unableToAccessSecurityScopedResource
  case invalidParentItem
  case noContentFromServer
}
