import Foundation
/*
   FileProvider里的请求类文件，列表数据以及下载图片等
*/
final class NetworkManage {
  static let shared = NetworkManage()
  
  private enum APIConfig {
    enum Path: String {
      case media, file, preview
    }
    enum Parameter: String {
      case id, path
    }
  }

  private let session: URLSession = .shared
  
  private func buildURL() -> URLRequest {
    /*
     这是LeanCloud上模拟的数据
     返回示例：
        {
            results:[
                {},
                {},
                {}
            ]
        }
     */
    var request = URLRequest.init(url: URL.init(string: "https://oq58jyev.lc-cn-n1-shared.com/1.1/classes/User")!)
    request.allHTTPHeaderFields = [
        "Content-Type" :"application/json",
        "X-LC-Id" :"oQ58JYEvna2ki4XQdVGg2ACM-gzGzoHsz",
        "X-LC-Key" :"9l5uXn5UgBRHJol9mQSEMfC5",
    ]
    request.httpMethod = "GET"
    return request
  }

  @discardableResult
  func getMediaItems(atPath path: String = "/",
                     handler: @escaping ([Dictionary<String, Any>]?, Error?) -> Void) -> URLSessionTask {
    let request = buildURL()
    
    let task = session.dataTask(with: request) { data, _, error in
        /*
           此处由于长时间没使用Swift，写的比较难受，没有使用model保存传递数据
         */
      guard
        let data = data,
        let jsondata: [String : AnyObject] = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String : AnyObject]
        else {
          return handler(nil, error)
      }
        handler(jsondata["results"] as? [Dictionary<String, Any>] ?? [], nil)
    }

    task.resume()
    return task
  }

}
