//
//  ContentView.swift
//  SwiftUI_4Chan_Catalog
//
//  Created by Matt Andrzejczuk on 2/11/21.
//

import SwiftUI
import JavaScriptCore

let akolorFaintBlack2 = Color.init(.sRGB, red: 0.0, green: 0.0, blue: 0.10, opacity: 0.5)
let akolorFaintBlack1 = Color.init(.sRGB, red: 0.0, green: 0.0, blue: 0.20, opacity: 0.3)

let CBkF4 = Color.init(.displayP3, red: 0.10, green: 0.10, blue: 0.10, opacity: 0.9)
let CBkF3 = Color.init(.displayP3, red: 0.08, green: 0.08, blue: 0.08, opacity: 0.8)
let CBkF2 = Color.init(.displayP3, red: 0.05, green: 0.05, blue: 0.05, opacity: 0.5)
let CBkF1 = Color.init(.displayP3, red: 0.01, green: 0.01, blue: 0.01, opacity: 0.25)

let CRdF1 = Color.init(.displayP3, red: 0.60, green: 0.015, blue: 0.0, opacity: 0.2)
let CRdF2 = Color.init(.displayP3, red: 0.50, green: 0.05, blue: 0.0, opacity: 0.5)
let CRdF3 = Color.init(.displayP3, red: 0.40, green: 0.1, blue: 0.0, opacity: 0.8)
let CRdF4 = Color.init(.displayP3, red: 0.30, green: 0.1, blue: 0.0, opacity: 0.9)


let HOST_CONTENT : String = "https://a.4cdn.org/"
let HOST_IMG : String = "https://i.4cdn.org/"
let CATEGORY : String = "p"

struct IMAGE_URI {
    static func build(timestamp:Int, withExt:String) -> String {
        let uri = "\(HOST_IMG)\(CATEGORY)/\(timestamp)\(withExt)"
        print("URI generated: \(uri)")
        return uri
    }
}

struct AKRow: View {
    
    var id = Int()
    var titleForFilter = String()
    @ObservedObject var rowViewModel : AKRowViewModel = AKRowViewModel()
    @State private var imgThumbnail = UIImage(named: "no_img")!
    
    init(_ thread: ChanThread) {
        self.id = thread.no
        self.rowViewModel.intThreadNo = thread.no
        if let com = thread.com {
            self.rowViewModel.strVMBody = com
        }
        if let sub = thread.sub {
            self.rowViewModel.strVMTitle = "\(sub)"
            self.titleForFilter = "\(sub)"
        } else {
            self.rowViewModel.strVMTitle = "\(self.rowViewModel.strVMBody.truncated(limit: 15))"
            self.titleForFilter = "\(self.rowViewModel.strVMBody.truncated(limit: 15))"
        }
        if let tim = thread.tim {
            self.rowViewModel.intTimestamp = tim
            if let ext = thread.ext {
                self.rowViewModel.strImageExt = ext
                self.rowViewModel.strImageUrl = IMAGE_URI.build(timestamp: tim, withExt: ext)
            }
        }
    
        
    }
    var body: some View {

            NavigationLink(destination: Text(rowViewModel.strVMBody)) {
                HStack {
                    ZStack {
                        if let img = rowViewModel.imgLoaded {
                            Image(uiImage: img).resizable().frame(width: 100, height: 100)
                        }
                        Image(uiImage: rowViewModel.imgPreloadBuffer).resizable().frame(width: 100, height: 100)
//                        Image(uiImage: imgThumbnail).resizable().frame(width: 100, height: 100)
                    }.animation(nil)
                    
                    VStack {
                        Text("#\(self.rowViewModel.intThreadNo)")
                            .foregroundColor(.primary)
                            .font(.custom("SF Mono", size: 12))
                        Text(self.rowViewModel.strVMTitle)
                            .foregroundColor(.primary)
                            .font(.headline)
                    }
                    
                }.onAppear(perform: {
                    if let imgCached = rowViewModel.imgLoaded {
                        rowViewModel.imgLoaded = UIImage(named: "no_img")!
                    } else {
                        self.rowViewModel.downloadThen(completion: { img in
                            rowViewModel.imgLoaded = img
                            //                        print(img)
                        })
                    }
                    
                })
                
                
            }

    }
    
    func setStateA(_ string: String) -> () -> () {
        return {
            self.rowViewModel.strVMTitle = string
            print("setTextAction")
        }
    }
    
}



struct ContentView: View {
    
//    @State private var newRowNameField = ""
    @State private var didTapTextField = false
    @State private var keyboardIsOpen = 0.0
    
    @State var textFieldInput: String = ""
    @State var predictableValues: Array<String> = ["First", "Second", "Third", "Fourth Thingy"]
    @State var predictedValue: Array<String> = []
    
    @ObservedObject var mainViewModel : AKMainViewModel = AKMainViewModel()
    
    init() {
        predictableValues = mainViewModel.autocompletablePredictions
        for subject in predictableValues {
            print("subject: \(subject)")
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
//                Form {
//                    PredictingTextField(predictableValues: self.$predictableValues, predictedValues: self.$predictedValue, textFieldInput: self.$textFieldInput).onTapGesture {
//                        keyboardIsOpen = 1.0
//                        predictableValues = mainViewModel.autocompletablePredictions
//                    }
//                }.frame(height: 80, alignment: .center)
              
              
              // - - - - - - - - - - - - - - - - - - - - - - -
              
              
//                    List {
//                        Group {
//                            ForEach(self.predictedValue, id: \.self){ value in
//                                Button("\(value)", action: {
//                                    textFieldInput = value
//                                })
//                            }
//                        }
//                    }
                    List {
                        Group {
                            ForEach(mainViewModel.rowsList, id: \.id) { row in
                                if self.textFieldInput == row.titleForFilter {
                                    row
                                }
                                if self.textFieldInput == "" {
                                    row
                                }
                            }
                        }
                    }.listStyle(InsetGroupedListStyle())
                
                
                
                
                
            }
            .padding(.vertical)
        }
    }
    
    func addRow() {
        print("added!")
        //        guard newRowNameField != "" else {
        //            return
        //        }
        //        mainViewModel.rowsList.append(AKRow(newRowNameField))
        //        newRowNameField = ""
    }
    
    func removeTop() {
        print("navigateToSettings!")
        mainViewModel.rowsList.remove(at: 0)
    }
    
    func cancelKeyboard() {
        print("cancelKeyboard!")
        keyboardIsOpen = 0.0
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


class AKMainViewModel: ObservableObject {
    
    var catalog: [ChanCatalog]!
    @Published var rowsList : [AKRow] = []
    @Published var autocompletablePredictions: Array<String> = []
    
    init() {
        print("GET request")
        loadAllObjectsFromAPI()
    }
    
    func addToRowsViewModel() {
        for item in self.catalog {
            for result in item.threads {
                let thread = AKRow(result)
                self.rowsList.append(thread)
                self.autocompletablePredictions.append(thread.titleForFilter)
//                for thread in item.threads {
//                    if let subject = thread.sub {
//                        self.autocompletablePredictions.append(subject)
//                    }
//                }
            }
        }
    }
    
    func loadAllObjectsFromAPI() {
        let semaphore = DispatchSemaphore (value: 0)
        
      let rURL = "\(HOST_CONTENT)\(CATEGORY)/catalog.json";
      
      
      print(" MAKING API REQUEST: - \(rURL)")
      
      
      
        var request = URLRequest(url: URL(string: "\(HOST_CONTENT)\(CATEGORY)/catalog.json")!,timeoutInterval: Double.infinity)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { jsonData, response, error in
            guard let data = jsonData else {
                print(String(describing: error))
                semaphore.signal()
                return
            }
            print("HERE IT IS: ")
            let jsonStr = String(data: data, encoding: .utf8)!.replacingOccurrences(of: "\\\"", with: "'").replacingOccurrences(of: "\\", with: "")
            let dataReprocessed = jsonStr.data(using: .utf8)!
            self.catalog = try! JSONDecoder().decode([ChanCatalog].self, from: dataReprocessed)
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
        print("DONE!")
        self.addToRowsViewModel()
    }
}


class AKRowViewModel: ObservableObject {
    
    @Published var strVMTitle : String = "Untitled" 
    @Published var strVMBody : String = ""
    @Published var imgLoaded: UIImage?
    
    @Published var intThreadNo: Int!
    @Published var intTimestamp: Int!
    @Published var strImageExt: String?
    
    @Published var strImageUrl: String?
    

    
    var imgPreloadBuffer: UIImage = UIImage()
    

    
    func downloadThen(completion: (UIImage) -> ()) {
        
        guard self.strImageExt != ".webm" else {
            return
        }
        guard self.strImageExt != ".webm" else {
            return
        }
        if let urlGenerated = self.strImageUrl {
            print("Starting Download... \(urlGenerated)")
            let semaphore = DispatchSemaphore (value: 1)
            let urlImg: URL = URL(string: urlGenerated)!  //h: )
            var request = URLRequest(url: urlImg, timeoutInterval: Double.infinity)
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request) { responseData, response, error in
                guard let confirmedData = responseData else {
                    print(String(describing: error))
                    semaphore.signal()
                    return
                }
                if let confirmedImage = UIImage(data: confirmedData) {
                    self.imgLoaded = confirmedImage
                    self.imgPreloadBuffer = confirmedImage
                }
                
                semaphore.signal()
            }
            
            task.resume()
            
            semaphore.wait()
            if let img = self.imgLoaded {
                completion(img)
            }
            
            print("downloaded.")
            
        } else {
            completion(UIImage(named: "no_img")!)
        }
        
    }
    

}


struct ChanThreadReply: Decodable {
    let no: Int?
    let now: String?
    let name: String?
    let com: String?
    let time: Int?
    let resto: Int?
    let id: String?
    let country: String?
    let country_name: String?
}

struct ChanThread: Decodable {
    let no: Int
    let now: String?
    let name: String
    let sub: String?
    let com: String?
    let filename: String?
    let ext: String?
    let w: Int?
    let h: Int?
    let tn_w: Int?
    let tn_h: Int?
    let tim: Int?
    let time: Int?
    let md5: String?
    let fsize: Int?
    let resto: Int?
    let id: String?
    let troll_country: String?
    let bumplimit: Int?
    let imagelimit: Int?
    let semantic_url: String?
    let country: String?
    let country_name: String?
    let replies: Int?
    let images: Int?
    let omitted_posts: Int?
    let omitted_images: Int?
    let last_replies: [ChanThreadReply]?
    let last_modified: Int?
}

struct ChanCatalog: Decodable {
    let page: Int
    let threads: [ChanThread]
}

extension String {
    enum TruncationPosition {
        case head
        case middle
        case tail
    }
    
    func truncated(limit: Int, position: TruncationPosition = .tail, leader: String = "...") -> String {
        guard self.count > limit else { return self }
        
        switch position {
            case .head:
                return leader + self.suffix(limit)
            case .middle:
                let headCharactersCount = Int(ceil(Float(limit - leader.count) / 2.0))
                
                let tailCharactersCount = Int(floor(Float(limit - leader.count) / 2.0))
                
                return "\(self.prefix(headCharactersCount))\(leader)\(self.suffix(tailCharactersCount))"
            case .tail:
                return self.prefix(limit) + leader
        }
    }
}
