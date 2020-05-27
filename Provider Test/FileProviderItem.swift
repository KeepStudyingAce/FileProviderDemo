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
    //MARK: -文件列表单个文件的唯一标识，一般会把需要展示的信息一起拼接成字符串编码后作为唯一标识,长度太长系统会穿件placeholder失败，FileProviderExtension中有解决办法
  var itemIdentifier: NSFileProviderItemIdentifier {
    return reference.itemIdentifier
  }
  //MARK:文件列表单个文件的父目录Identifier，如果该目录下文件显示不全，可能是部分文件的parentItemIdentifier错误。某一目录下的所有文件的parentItemIdentifier一定相同；
  var parentItemIdentifier: NSFileProviderItemIdentifier {
    return reference.parentReference?.itemIdentifier ?? itemIdentifier
  }
  
  //MARK: -列表显示的文件名
  var filename: String {
    return reference.filename
  }
  
  //MARK: -用于展示文件名称前面的图标，系统枚举值，需要一一对应(必须一一对应正确的格式下载成功后才能打开系统支持打开的文件)。
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
