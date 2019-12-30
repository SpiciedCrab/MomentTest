//
//  ContentDetailViewController.swift
//  ThoughtworkMoment
//
//  Created by Harly on 2019/12/30.
//  Copyright © 2019 Harly. All rights reserved.
//

import UIKit

class ContentDetailViewController: UIViewController {
    @IBOutlet private weak var textView: UITextView!
    
    var text: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "All"
        textView.text = text
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

}
