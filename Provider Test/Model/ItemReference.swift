import FileProvider
import MobileCoreServices
/*
  用来将数据处理成系统需要的FileProviderItem
 */
#warning("用于处理数据以及FileProviderItem的转换，主要难点在于创建两个初始化方法返回同一个ItemReference (itemIdentifier以及Item的数据信息)，准确的返回FileProviderItem需要的几个参数。清楚URL拼接后通过基本操作取出想要的参数,本人使用Extension时花费时间最多的地方(只是因为本人对URL的一些API不熟而已)")
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
  //处理显示物理路径
  var path: String {
    return urlRepresentation.path
  }

  var containingDirectory: String {
    return urlRepresentation.deletingLastPathComponent().path
  }

  //处理显示文件名字
  var filename: String {
    return urlRepresentation.lastPathComponent.components(separatedBy: "?")[0]
  }
    
  #warning("返回的文件类型，如果类型返回系统无法识别，列表显示文件不能点击，")
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
    
    /*
     代码示例：
     if (isDirectory) {
          return kUTTypeFolder as String
        }
        var typeString = ""
        let fileType = self.file[2]
        switch fileType {
        case "pdf":
            typeString = kUTTypePDF as String
            break
        case "pl", "pm", "cgi", "as", "asm", "c", "cpp", "h", "clj", "cbl", "cfm", "d", "diff", "dot", "ejs",
          "erl", "ftl", "go", "hs",
          "vbs", "haml", "erb", "jade", "jq", "ji", "tex", "lisp", "ls", "lsl", "lua", "lp", "matlab", "mel", "r",
          "yaml", "yml":
            typeString = kUTTypeSourceCode as String
            break
        case "json":
          typeString = kUTTypeJSON as String
          break
        case "php":
          typeString = kUTTypePHPScript as String
          break
        case "bin", "hex", "uue", "bz2", "ace", "so", "dll", "chm", "rtf", "odp", "odt", "pages",
          "class", "ttf", "fla",
          "dat", "lib", "a", "o":
            typeString = kUTTypeBinaryPropertyList as String
            break
        case "html", "htm", "url", "tpl", "lnk", "shtml", "webloc", "hta", "xhtml":
            typeString = kUTTypeHTML as String
            break
        case "css", "less", "sass":
            typeString = kUTTypeJavaClass as String
            break
        case "js", "coffee", "jsx":
            typeString = kUTTypeJavaScript as String
            break
        case "cmd", "bat":
            typeString = kUTTypeData as String
            break
        case "xml", "config", "manifest", "xaml", "csproj", "xib", "vbproj","xps":
            typeString = kUTTypeXML as String
            break
        //MARK:-图片
        case "gif","heic", "ico", "cur", "webp","wps":
          typeString = kUTTypeImage as String
          break
        case "png":
          typeString = kUTTypePNG as String
          break
        case "jpg", "jpeg":
          typeString = kUTTypeJPEG as String
          break
        case "bmp":
          typeString = kUTTypeBMP as String
          break
        case "tiff", "tif":
          typeString = kUTTypeTIFF as String
          break
        case "svg":
          typeString = kUTTypeScalableVectorGraphics as String
          break
        case "picture":
          typeString = kUTTypePICT as String
          break
          
        //MARK:-视频
        case "midi":
          typeString = kUTTypeMIDIAudio as String
          break
        case "m4a":
          typeString = kUTTypeMPEG4Audio as String
          break
        case "wav":
          typeString = kUTTypeWaveformAudio as String
          break
        case "mp3":
          typeString = kUTTypeMP3 as String
          break
        case "m3u":
          typeString = kUTTypeM3UPlaylist as String
          break
        case "wma", "mp2", "mid", "aac", "ogg", "oga", "webma","mp4", "m4v", "mov", "f4v", "flv", "ogv", "webm", "webmv", "mkv", "flac", "alac", "ape", "ac3",
             "rm", "rmvb", "mpg", "wmv", "vob", "3gp", "3g2", "asf", "vcd":
          typeString = kUTTypeQuickTimeMovie as String
          break
        case "avi":
          typeString = kUTTypeAVIMovie as String
          break
        case "mpeg":
          typeString = kUTTypeMPEG as String
          break
        //MARK:-压缩包
        case "7z", "arj", "bza", "cab", "cxr", "dgc", "gca", "gz",
          "gza", "iso", "jar", "lzh", "rar", "rk", "tar", "tbz", "tgz", "tlz", "txz", "yz1", "zip":
          typeString = kUTTypeZipArchive as String
          break
        case "gzip":
          typeString = kUTTypeGNUZipArchive as String
               break
        case  "otf", "eot", "woff", "ttc":
          typeString = kUTTypeTIFF as String
          break
        case "sh", "bash", "bashrc":
          typeString = kUTTypeShellScript as String
          break
        case "ini", "inf", "conf", "meta", "gitignore", "plist", "htaccess", "localized", "xcscheme", "storyboard","jks","keystore",
               "strings", "pbxproj":
          typeString = kUTTypePropertyList as String
          break
        case "md", "markdown":
          typeString = kUTTypeUTF8PlainText as String
          break
        case "log", "changelog", "prolog":
             typeString = kUTTypeLog as String
             break
        case "epub":
          typeString = kUTTypeElectronicPublication as String
          break
        case "dmg","apk","oexe","exe","ipa":
          typeString = kUTTypeItem as String
          break
        //MARK:-不知名文件
        case "skp","3ds","dwfx","dxf","dwg":
             typeString = kUTTypeAliasFile as String
             break
        default:
          let unmanaged = UTTypeCreatePreferredIdentifierForTag(
            kUTTagClassFilenameExtension,
            fileType as CFString,
            nil
          )
           
          let retained = unmanaged?.takeRetainedValue()
          typeString = (retained as String?) ?? ""
        }
     */
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
