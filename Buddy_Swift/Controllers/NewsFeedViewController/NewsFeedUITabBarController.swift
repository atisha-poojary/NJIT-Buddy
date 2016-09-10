//
//  NewsFeedUITabBarController.swift
//  Buddy_Swift
//
//  Created by Atisha Poojary on 07/06/16.
//  Copyright © 2016 Atisha Poojary. All rights reserved.
//

import UIKit

class NewsFeedUITabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let tabIconImage_news : UIImage = UIImage(named: "ic_tab_news.png")! //Initialize Image
        let tabIcon_news : UITabBarItem = self.tabBar.items![0] as UITabBarItem //Select tab bar item
        tabIcon_news.selectedImage = tabIconImage_news.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal) //It will render image to its original color
        
        let tabIconImage_special : UIImage = UIImage(named: "ic_tab_bell.png")! //Initialize Image
        let tabIcon_special : UITabBarItem = self.tabBar.items![1] as UITabBarItem //Select tab bar item
        tabIcon_special.selectedImage = tabIconImage_special.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal) //It will render image to its original color
        
        let tabIconImage_more : UIImage = UIImage(named: "ic_tab_more.png")! //Initialize Image
        let tabIcon_more : UITabBarItem = self.tabBar.items![2] as UITabBarItem //Select tab bar item
        tabIcon_more.selectedImage = tabIconImage_more.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal) //It will render image to its original color
        
        UITabBar.appearance().translucent = false
        UITabBar.appearance().backgroundImage =
            UIImage(named:"background_tab_unchecked.png")
            //barTintColor = UIColor(red:255.0/225, green:190.0/255, blue:79.0/255, alpha: 1.0)
        //(red: 1, green: 165/255, blue: 0, alpha: 1)
        //
        //UITabBar.appearance().tintColor = UIColor.clearColor()
        
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState:.Normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState:.Selected)
        
        
        let selectedBG = UIImage(named:"background_tab_checked.png")?.resizableImageWithCapInsets(UIEdgeInsetsZero)
        UITabBar.appearance().selectionIndicatorImage = selectedBG
        
        
        //UITabBar.appearance().selectedImageTintColor = UIColor.whiteColor()
        UITabBar.appearance().selectionIndicatorImage = UIImage.imageWithColor(UIColor(red:225.0/225, green:204.0/255, blue:60.0/255, alpha: 1.0), size: CGSizeMake(tabBar.frame.width/5, tabBar.frame.height-5)).resizableImageWithCapInsets(UIEdgeInsetsZero)
        
        //UIImage(named:"background_tab_checked.png")!
            
            //UIImage.imageWithColor(UIColor.blueColor(), size: CGSizeMake(tabBar.frame.width/5, tabBar.frame.height)).resizableImageWithCapInsets(UIEdgeInsetsZero)
        
        //UIImage().makeImageWithColorAndSize(UIColor.blueColor(), size: CGSizeMake(tabBar.frame.width/5, tabBar.frame.height))
        
        
        // Uses the original colors for your images, so they aren't not rendered as grey automatically.
        for item in self.tabBar.items! {
            if let image = item.image {
                item.image = image.imageWithRenderingMode(.AlwaysOriginal)
            }
        }
    }

    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) -> Bool {
        viewController.viewDidAppear(true)
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIImage {
    
    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect: CGRect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}
