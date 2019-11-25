//
//  AppDelegate.swift
//  Background-Accel-Swift
//
//  Created by 新納真次郎 on 2019/11/25.
//  Copyright © 2019 新納真次郎. All rights reserved.
//

import UIKit
import CoreData
import BackgroundTasks

class PrintOperation: Operation {
    let id: Int

    init(id: Int) {
        self.id = id
    }

    override func main() {
        print("this operation id is \(self.id)")
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
          // Override point for customization after application launch.

          // 第一引数: Info.plistで定義したIdentifierを指定
          // 第二引数: タスクを実行するキューを指定。nilの場合は、デフォルトのバックグラウンドキューが利用されます。
          // 第三引数: 実行する処理
          BGTaskScheduler.shared.register(forTaskWithIdentifier: "Nakamura-labProject.Background-Accel-Swift.refresh", using: nil) { task in
              // バックグラウンド処理したい内容 ※後述します
              self.handleAppProcessing(task: task as! BGProcessingTask)
          }
          return true
    }

    private func scheduleAppRefresh() {
        // Info.plistで定義したIdentifierを指定
        let request = BGAppRefreshTaskRequest(identifier: "com.MeasurementSample.refresh")
        // 最低で、どの程度の期間を置いてから実行するか指定
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)

        do {
            // スケジューラーに実行リクエストを登録
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }

    private func handleAppRefresh(task: BGAppRefreshTask) {
        // 1日の間、何度も実行したい場合は、1回実行するごとに新たにスケジューリングに登録します
        scheduleAppRefresh()

        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1

        // 時間内に実行完了しなかった場合は、処理を解放します
        // バックグラウンドで実行する処理は、次回に回しても問題ない処理のはずなので、これでOK
        task.expirationHandler = {
            queue.cancelAllOperations()
        }

        // サンプルの処理をキューに詰めます
        let array = [1, 2, 3, 4, 5]
        array.enumerated().forEach { arg in
            let (offset, value) = arg
            let operation = PrintOperation(id: value)
            if offset == array.count - 1 {
                operation.completionBlock = {
                    // 最後の処理が完了したら、必ず完了したことを伝える必要があります
                    task.setTaskCompleted(success: operation.isFinished)
                }
            }
            queue.addOperation(operation)
        }
    }

    private func handleAppProcessing(task: BGProcessingTask) {
         // 1日の間、何度も実行したい場合は、1回実行するごとに新たにスケジューリングに登録します
         scheduleAppRefresh()

         let queue = OperationQueue()
         queue.maxConcurrentOperationCount = 1

         // 時間内に実行完了しなかった場合は、処理を解放します
         // バックグラウンドで実行する処理は、次回に回しても問題ない処理のはずなので、これでOK
         task.expirationHandler = {
             queue.cancelAllOperations()
         }

         // サンプルの処理をキューに詰めます
         let array = [1, 2, 3, 4, 5]
         array.enumerated().forEach { arg in
             let (offset, value) = arg
             let operation = PrintOperation(id: value)
             if offset == array.count - 1 {
                 operation.completionBlock = {
                     // 最後の処理が完了したら、必ず完了したことを伝える必要があります
                     task.setTaskCompleted(success: operation.isFinished)
                 }
             }
             queue.addOperation(operation)
         }
     }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // バックグラウンド起動に移ったときにルケジューリング登録
        scheduleAppRefresh()
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Background_Accel_Swift")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

