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
    #warning("仅仅作为NSFileProviderItemIdentifier过长时候的解决办法")
    var nameTooLongSaveDic:Dictionary<String,String> = [:];
    
    override init() {
        super.init()
    }
    
    #warning("界面渲染的时候会调用")
    override func item(for identifier: NSFileProviderItemIdentifier) throws -> NSFileProviderItem {
         print("ItemForidentifier")
        // 根据identifier返回一个Item
        guard let reference = ItemReference(itemIdentifier: identifier) else {
          throw NSError.fileProviderErrorForNonExistentItem(withIdentifier: identifier)
        }
        return FileProviderItem(reference: reference)
    }
    
    #warning("以下四个函数用于在本地创建一个对应的目录")
    //MARK:-  根据identifier初始化一个本地对应位置代表文件，并将本地位置返回
    override func urlForItem(withPersistentIdentifier identifier: NSFileProviderItemIdentifier) -> URL? {
        
        guard let item = try? item(for: identifier) else {
            return nil
        }
        
        // 构造本地存储的URL： <base storage directory>/<item identifier>/<item file name>
        let manager = NSFileProviderManager.default
        let perItemDirectory = manager.documentStorageURL.appendingPathComponent(identifier.rawValue, isDirectory: true)
        #warning("处理过长的的identifier")
//        nameTooLongSaveDic[arr.last!] = identifier.rawValue;
        print("UrlFroItem")
        return perItemDirectory.appendingPathComponent(item.filename, isDirectory:false)
    }
    
    // MARK:- 每个URL（本地文件的位置）对应的唯一标识
    override func persistentIdentifierForItem(at url: URL) -> NSFileProviderItemIdentifier? {
        
        print("persistentIdentifierForItem")
        let identifier = url.deletingLastPathComponent().lastPathComponent
        return NSFileProviderItemIdentifier(identifier)
        #warning("读取过长的NSFileProviderItemIdentifier，并返回")
//        return NSFileProviderItemIdentifier(nameTooLongSaveDic[pathComponents[pathComponents.count - 2]]!)
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
      #warning("此处注意，URL中ItemIdentifier可能包含太多文件信息，导致长度太长，createDirectory创建目录时名字太长会导致创建失败;添加属性nameTooLongSaveDic解决该问题")
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
    
    
    #warning("数据处理：缩略图下载，文件下载等")
    //MARK:- 可以处理图片/文件下载显示等问题
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
        
        // 下载图片
//         let name = reference.filename
//       let path = reference.containingDirectory
//       NetworkClient.shared.downloadMediaItem(named: name, at: path, isPreview: false) { fileURL, error in
//         guard let fileURL = fileURL else {
//           completionHandler(error)
//           return
//         }
// // MARK:- 完成后的回调
//         do { //将下载的文件移动到相应位置
//           try self.fileManager.moveItem(at: fileURL, to: url)
//           completionHandler(nil)
//         } catch {
//           completionHandler(error)
//         }
//       }
    }
    
    #warning("文件导入/上传文件时候的回调,返回一个NSFileProviderItem即代表成功导入/上传")
  override func importDocument(at fileURL: URL, toParentItemIdentifier parentItemIdentifier: NSFileProviderItemIdentifier, completionHandler: @escaping (NSFileProviderItem?, Error?) -> Void) {
//    guard let reference = ItemReference(itemIdentifier: parentItemIdentifier) else {
//             print(" importDocument ItemForidentifier Error", parentItemIdentifier)
//            completionHandler(nil, FileProviderError.noContentFromServer)
//            return
//          }
//    let tool = UploadTool.init()
//    // 名称从url中取，path需要判断是不是根目录，否则reference.kodSourcePath不一定有值
//    var path = reference.kodSourcePath;
//    if (reference.path == "/") {
//      let homePath = UserDefaults.init(suiteName: "group.com.kodcloud.kodbox")?.object(forKey: "homePath") ?? "/";
//      path = homePath as! String;
//    }
//    var urlTemp = fileURL.absoluteString;
//    if (urlTemp.hasPrefix("file:///")){
//      let endIndex = urlTemp.index(urlTemp.startIndex, offsetBy: 7);
//      urlTemp.removeSubrange(urlTemp.startIndex...endIndex);
//      print("导入文件的本地路径" + urlTemp);
//    }
////    tool.startUploadFileName(fileURL.lastPathComponent, path: path, fileUrl: urlTemp)
//    tool.startUploadFileName(fileURL.lastPathComponent, path: path, fileUrl: urlTemp) { (pathNew) -> UnsafeMutableRawPointer? in
//      print("上传文件成功" + (pathNew ?? "Fuck FileUpload"));
//      let type = fileURL.lastPathComponent.components(separatedBy: ".").last;
//      var infoString = "file|" + fileURL.lastPathComponent + "|" + (type ?? "") + "||"
//      infoString = infoString  +  "\(Date().timeIntervalSince1970)" + "|" +  (pathNew ?? "")
//      let refer = ItemReference.init(path: pathNew ?? "", filename: fileURL.lastPathComponent, infoString: infoString)
//      let item = FileProviderItem.init(reference: refer)
//      completionHandler(item, nil)
//      return nil
//    }
    
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
    #warning("推出后将目录下的占位符清空")
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
    
    #warning("目录切换时返回唯一的FileProviderEnumerator以处理数据")
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
    
    #warning("缩略图的下载，同时下载当前界面所有的缩略图，每个下载作为一个Progress返回，异步处理所有请求")
     override func fetchThumbnails(
        for itemIdentifiers: [NSFileProviderItemIdentifier],
        requestedSize size: CGSize,
        perThumbnailCompletionHandler: @escaping (NSFileProviderItemIdentifier, Data?, Error?) -> Void,
        completionHandler: @escaping (Error?) -> Void)
          -> Progress {
           
//        print("PrefetchThumbnails")
        let progress = Progress(totalUnitCount: Int64(itemIdentifiers.count))
//
//        for itemIdentifier in itemIdentifiers {
//          let itemCompletion: (Data?, Error?) -> Void = { data, error in
//            perThumbnailCompletionHandler(itemIdentifier, data, error)
//
//            if progress.isFinished {
//              DispatchQueue.main.async {
//                completionHandler(nil)
//              }
//            }
//          }
//
//          guard
//            let reference = ItemReference(itemIdentifier: itemIdentifier),
//            !reference.isDirectory
//            else {
//              progress.completedUnitCount += 1
//              let error = NSError.fileProviderErrorForNonExistentItem(withIdentifier: itemIdentifier)
//              itemCompletion(nil, error)
//              continue
//          }
//         print("fetchThumbnails",reference.fileInfo)
//         let task = NetworkManage.shared.getThumbSquare(atPath: reference.kodSourcePath) { url, error in
//
//            guard
//              let url = url,
//              let data = try? Data(contentsOf: url, options: .alwaysMapped)
//              else {
//                itemCompletion(nil, error)
//                return
//            }
//            itemCompletion(data, nil)
//          }
//
//          progress.addChild(task.progress, withPendingUnitCount: 1)
//        }
//
        return progress
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
