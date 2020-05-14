//
//  FileProviderItem.swift
//  Provider Test
//
//  Created by admin on 2020/5/9.
//  Copyright © 2020 KODCloud. All rights reserved.
//

import FileProvider

class FileProviderItem: NSObject {
    private let reference: ItemReference
    
    init(reference: ItemReference) {
      self.reference = reference
      super.init()
    }
}

extension FileProviderItem: NSFileProviderItem {
    //MARK: -文件唯一标识
  var itemIdentifier: NSFileProviderItemIdentifier {
    return reference.itemIdentifier
  }
  
  var parentItemIdentifier: NSFileProviderItemIdentifier {
    return reference.parentReference?.itemIdentifier ?? itemIdentifier
  }
  
  //MARK: -列表显示的文件名
  var filename: String {
    return reference.filename
  }
  
  //MARK: -列表显示的文件类型，系统有一系列的文件类型图标对应
  var typeIdentifier: String {
    return reference.typeIdentifier
  }
    
  //MARK: -允许的系统操作，编辑，赋值，移动等
  var capabilities: NSFileProviderItemCapabilities {
    return .allowsAll
  }

    //MARK: -文件大小
  var documentSize: NSNumber? {
    return 100000
  }
    
    //MARK: -文件是否正在上传
    var isUploading: Bool {
        return false
    }
    
    //MARK: -文件是否已经上传
    var isUploaded: Bool {
        return true
    }
    
    //MARK: -文件是否下载
    var isDownloaded: Bool{
        return false
    }
    
    //MARK: -文件是否正在下载
    var isDownloading: Bool{
        return false
    }
    
    //MARK: -文件创建日期
    var creationDate: Date?{
        return Date()
    }
    
    //MARK: -文件修改日期
    var contentModificationDate: Date?{
        return Date()
    }
    
    //MARK: -子文件数量
    var childItemCount: NSNumber?{
        return 10
    }
}
