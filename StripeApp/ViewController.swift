//
//  ViewController.swift
//  StripeApp
//
//  Created by HITSS on 12/11/21.
//

import UIKit
import Stripe
import StripeCore
import StripeUICore
import PassKit
import Alamofire

class ViewController: UIViewController {
    
    var pushProvisioningContext: STPPushProvisioningContext? = nil

    

    @IBAction func didTapPushProvisioning(_ sender: Any) {
        beginPushProvisioning()
    }
    
    // ...
      func beginPushProvisioning() {
        let config = STPPushProvisioningContext.requestConfiguration(
          withName: "Jenny Rosen", // the cardholder's name
          description: "RocketRides Card", // optional; a description of your card
          last4: "4242", // optional; the last 4 digits of the card
          brand: .visa // optional; the brand of the card
        )
        let controller = PKAddPaymentPassViewController(requestConfiguration: config, delegate: self)
        self.present(controller!, animated: true, completion: nil)
      }
}

extension ViewController: PKAddPaymentPassViewControllerDelegate {
  func addPaymentPassViewController(_ controller: PKAddPaymentPassViewController, generateRequestWithCertificateChain certificates: [Data], nonce: Data, nonceSignature: Data, completionHandler handler: @escaping (PKAddPaymentPassRequest) -> Void) {
    self.pushProvisioningContext = STPPushProvisioningContext(keyProvider: self)
    // STPPushProvisioningContext implements this delegate method for you, by retrieving encrypted card details from the Stripe API.
    self.pushProvisioningContext?.addPaymentPassViewController(controller, generateRequestWithCertificateChain: certificates, nonce: nonce, nonceSignature: nonceSignature, completionHandler: handler);
  }

  func addPaymentPassViewController(_ controller: PKAddPaymentPassViewController, didFinishAdding pass: PKPaymentPass?, error: Error?) {
    // Depending on if `error` is present, show a success or failure screen.
    self.dismiss(animated: true, completion: nil)
  }
}

extension ViewController: STPIssuingCardEphemeralKeyProvider {
  func createIssuingCardKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
    // This example uses Alamofire for brevity, but you can make the request however you want
    AF.request("http://millerlite.devmds.com/api/push-provisioning",
               method: .post,
               parameters: ["api_version": apiVersion])
      .responseJSON { response in
        switch response.result {
        case .success:
          if let data = response.data {
            do {
              let obj = try JSONSerialization.jsonObject(with: data, options: []) as! [AnyHashable: Any]
              completion(obj, nil)
            } catch {
              completion(nil, error)
            }
          }
          case .failure(let error):
            completion(nil, error)
        }
      }
  }
}

