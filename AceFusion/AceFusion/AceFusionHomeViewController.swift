//
//  ViewController.swift
//  AceFusion
//
//  Created by jin fu on 2024/11/1.
//

import UIKit
import Reachability
import Adjust

class AceFusionHomeViewController: UIViewController {

    @IBOutlet weak var aceCctivityIndicator: UIActivityIndicatorView!
    var aceReachability: Reachability!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.aceCctivityIndicator.hidesWhenStopped = true
        aceLoadAdsBannerData()
    }
    
    @IBAction func startAction(_ sender: Any) {
        Adjust.trackEvent(ADJEvent(eventToken:"hdjhhsidhsisd"))
    }
    
    private func aceLoadAdsBannerData() {
        guard aceNeedShowBannerDescView() else {
            return
        }
                
        do {
            aceReachability = try Reachability()
        } catch {
            print("Unable to create Reachability")
            return
        }
        
        if aceReachability.connection == .unavailable {
            aceReachability.whenReachable = { reachability in
                self.aceReachability.stopNotifier()
                self.aceRequestAdsBannerData()
            }

            aceReachability.whenUnreachable = { _ in
            }

            do {
                try aceReachability.startNotifier()
            } catch {
                print("Unable to start notifier")
            }
        } else {
            self.aceRequestAdsBannerData()
        }
    }
    
    private func aceRequestAdsBannerData() {
        self.aceCctivityIndicator.startAnimating()
        
        guard let bundleId = Bundle.main.bundleIdentifier else {
            return
        }
        
        let url = URL(string: "https://open.\(self.aceFusionMainHostName())/open/aceRequestAdsBannerData")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters: [String: Any] = [
            "appSystemName": UIDevice.current.systemName,
            "appModelName": UIDevice.current.model,
            "appKey": "4a6036095736427cbed211f32f3f695d",
            "appPackageId": bundleId,
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? ""
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Failed to serialize JSON:", error)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    print("Request error:", error ?? "Unknown error")
                    self.aceCctivityIndicator.stopAnimating()
                    return
                }
                
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                    if let resDic = jsonResponse as? [String: Any] {
                        let dictionary: [String: Any]? = resDic["data"] as? Dictionary
                        if let dataDic = dictionary {
                            if let adsData = dataDic["jsonObject"] as? [String: Any], let bannData = adsData["bannerData"] as? String {
                                self.aceShowBannerDescView(bnUrl: bannData)
                                return
                            }
                        }
                    }
                    print("Response JSON:", jsonResponse)
                    self.aceCctivityIndicator.stopAnimating()
                } catch {
                    print("Failed to parse JSON:", error)
                    self.aceCctivityIndicator.stopAnimating()
                }
            }
        }

        task.resume()
    }
    
    private func aceShowBannerDescView(bnUrl: String) {
        let vc: AceFusionPolicyViewController = self.storyboard?.instantiateViewController(withIdentifier: "AceFusionPolicyViewController") as! AceFusionPolicyViewController
        vc.modalPresentationStyle = .fullScreen
        vc.url = bnUrl
        self.navigationController?.present(vc, animated: false)
    }
}

