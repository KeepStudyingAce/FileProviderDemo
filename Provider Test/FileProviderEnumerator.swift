//
//  FileProviderEnumerator.swift
//  Provider Test
//
//  Created by admin on 2020/5/9.
//  Copyright © 2020 KODCloud. All rights reserved.


/*
    FileProvider会生成数个FileProviderEnumerator；
    每个FileProviderEnumerator对应一个文件目录；
    每个FileProviderEnumerator管理自己目录下的数据以及界面刷新
 */

import FileProvider

class FileProviderEnumerator: NSObject, NSFileProviderEnumerator {
    
    private let path: String
    private var page: Int = 1
    private var currentTask: URLSessionTask?
    private var currentItems: [FileProviderItem]?
    private var currentAnchor: NSFileProviderSyncAnchor?


     init(path: String) {
       self.path = path
       super.init()
     }

    func invalidate() {
        currentTask?.cancel()
        currentTask = nil
    }

    func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAt page: NSFileProviderPage) {
        // 网络请求页面数据,返回结果处理成[FileProviderItem]并且调用observer.didEnumerate(items)方法
        // 页面目录更改的时候会调用这个方法
        print("当前所在目录", self.path)
        if (self.path == "/"){
            let task = NetworkManage.shared.getMediaItems() { results, error in
              guard let results = results else {
                let error = error ?? FileProviderError.noContentFromServer
                observer.finishEnumeratingWithError(error)
                return
              }

                let items = results.map { mediaItem -> FileProviderItem in
                    let ref = ItemReference.init(path: self.path, filename: (mediaItem["nickname"] as! String), uid: mediaItem["uid"] as! Int)
                return FileProviderItem.init(reference: ref)
              }
              self.currentItems = items;
              observer.didEnumerate(items)
                //存在分页的话判断数据传入页数，没有的话传入nil，传入页数后系统在用户滑动到底部时会自动再调用这个函数,自测好像进入界面就会将所有数据都加载出来，自动调用分业
//                if ((self.currentItems.count <= PAGESIZE){
//                  observer.finishEnumerating(upTo: nil)
//                } else {
//                    self.page += 1
//                    var myInt = self.page
//                    let myIntData = Data(bytes: &myInt, count: MemoryLayout.size(ofValue: myInt))
//                    observer.finishEnumerating(upTo: NSFileProviderPage(rawValue: myIntData))
//                  }
//                }
                
                observer.finishEnumerating(upTo: nil)
            }

            currentTask = task
        } else {
            // 不是当前目录暂时先传空的数据
            observer.didEnumerate([])
            observer.finishEnumerating(upTo: nil)
        }
    }
    
    #warning("目录下有文件导入或者删除时会调用，本demo中没有使用，自己项目中也没使用这个函数")
    func enumerateChanges(for observer: NSFileProviderChangeObserver, from anchor: NSFileProviderSyncAnchor) {
        /* TODO:
         For directories. The system requests an enumerator when a document browser displays the contents of a directory. For performance reasons, the system may retain the enumerator even after the browser has moved to a different directory.
         For files. The system requests an enumerator when a file presenter begins managing an item. The enumerator is invalidated after the file presenter is removed.
         For the working set. The system requests an enumerator when it begins indexing the working set. It invalidates the enumerator after the indexing operation has completed.
         */
        /*
         用户编辑的时候是否需要刷新目录：
         步骤：
         在其他地方获取当前数据（一般存储在本地数据库）->
         在其他地方操作后存储数据->
         此处将存储数据取出并传出来刷新界面
        */

        print("enumerateChanges",anchor, anchor.rawValue, self.currentItems?.count)
        self.currentAnchor = anchor
        observer.didUpdate(self.currentItems ?? [])
        observer.finishEnumeratingChanges(upTo: anchor, moreComing: false)
    }

    /*
     还没搞懂这个方法是干啥的
    */
    func currentSyncAnchor(completionHandler: @escaping (NSFileProviderSyncAnchor?) -> Void) {
        print("currentSyncAnchor", self.currentAnchor)
//        var myInt = 100
//        let myIntData = Data(bytes: &myInt, count: MemoryLayout.size(ofValue: myInt))
       completionHandler(self.currentAnchor)
    }

}
