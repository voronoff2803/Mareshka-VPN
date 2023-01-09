//
//  OnboardPageViewController.swift
//  OnboardKit
//

import UIKit
import WebKit


internal protocol OnboardPageViewControllerDelegate: class {
    func pageViewController(_ pageVC: OnboardPageViewController, actionTappedAt index: Int)
}

internal final class OnboardPageViewController: UIViewController {
    let webView = WKWebView()
    var pageContent: InfoScreenDTO?
    
    private lazy var actionButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title2)
        return button
    }()
    let pageIndex: Int
    
    weak var delegate: OnboardPageViewControllerDelegate?
    
    
    init(pageIndex: Int) {
        self.pageIndex = pageIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func loadView() {
        webView.backgroundColor = UIColor(named: "LoaderColor")
        webView.navigationDelegate = self
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        view = webView
    }
    
    
    
    func configureWithPage(_ page: InfoScreenDTO) {
        pageContent = page
        webView.loadHTMLString(pageContent?.content ?? "", baseURL: nil)
    }
    
    
    // MARK: - User Actions
    @objc fileprivate func actionTapped() {
        delegate?.pageViewController(self, actionTappedAt: pageIndex)
    }
}


extension OnboardPageViewController: WKNavigationDelegate {
    
}
