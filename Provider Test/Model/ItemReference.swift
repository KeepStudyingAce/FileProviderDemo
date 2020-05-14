import FileProvider
import MobileCoreServices
/*
  用来将数据处理成系统需要的FileProviderItem
 */

struct ItemReference {
// MARK: - 文件所有信息都保存在这个URL中，主要以字符串拼接
  private let urlRepresentation: URL
  private var uid: Int?
  
  private var isRoot: Bool {
    return urlRepresentation.path == "/"
  }
  
  private init(urlRepresentation: URL) {
    self.urlRepresentation = urlRepresentation
    let arr = urlRepresentation.lastPathComponent.components(separatedBy: "?");

    if (arr.count > 1){
        self.uid = Int(arr[1])
    }
  }
  
    // MARK: - 初始化方法 将网络数据解析生成带有固定格式的URL <documentStorageURL>/<itemIdentifier>/<filename>
    // MARK: - 需要保存更多的参数的话暂时以?连接，使用的时候在解析
  init(path: String, filename: String, uid: Int) {

    let isDirectory = filename.components(separatedBy: ".").count == 1
    let pathComponents = path.components(separatedBy: "/").filter {
      !$0.isEmpty
    } + [filename +  String(format: "?%d", uid)]
    
    var absolutePath = "/" + pathComponents.joined(separator: "/")
    if isDirectory {
      absolutePath.append("/")
    }
    absolutePath = absolutePath.addingPercentEncoding(
      withAllowedCharacters: .urlPathAllowed
    ) ?? absolutePath
    self.init(urlRepresentation: URL(string: "itemReference://\(absolutePath)")!)
  }
  
    
  init?(itemIdentifier: NSFileProviderItemIdentifier) {
    guard itemIdentifier != .rootContainer else {
        self.init(urlRepresentation: URL(string: "itemReference:///")!)
      return
    }
    guard let data = Data(base64Encoded: itemIdentifier.rawValue),
      let url = URL(dataRepresentation: data, relativeTo: nil) else {
        return nil
    }
    self.init(urlRepresentation: url)
  }
    

  // MARK: - 一下参数主要供FileProviderItem使用，所以数据处理需要细心
  var itemIdentifier: NSFileProviderItemIdentifier {
    if isRoot {
      return .rootContainer
    } else {
      return NSFileProviderItemIdentifier(
        rawValue: urlRepresentation.dataRepresentation.base64EncodedString()
      )
    }
  }

  var isDirectory: Bool {
    return urlRepresentation.hasDirectoryPath
  }

  var path: String {
    return urlRepresentation.path
  }

  var containingDirectory: String {
    return urlRepresentation.deletingLastPathComponent().path
  }

  var filename: String {
    return urlRepresentation.lastPathComponent.components(separatedBy: "?")[0]
  }
    
  //返回文件类型，前面Icon显示文件类型 用switch case去映射就好
  var typeIdentifier: String {
    guard (self.uid ?? 0) % 2 == 0 else { //!isDirectory
      return kUTTypeFolder as String
    }
    
    // 以下代码功能是根据文件名称生成对应的系统文件符号,可作为switch的default
    let pathExtension = urlRepresentation.pathExtension
    let unmanaged = UTTypeCreatePreferredIdentifierForTag(
      kUTTagClassFilenameExtension,
      pathExtension as CFString,
      nil
    )
    let retained = unmanaged?.takeRetainedValue()
    return (retained as String?) ?? ""
  }

  var parentReference: ItemReference? {
    guard !isRoot else {
      return nil
    }
    return ItemReference(
      urlRepresentation: urlRepresentation.deletingLastPathComponent()
    )
  }
}
