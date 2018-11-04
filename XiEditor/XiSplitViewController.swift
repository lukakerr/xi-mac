// Copyright 2018 The xi-editor Authors.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Cocoa

class XiSplitViewController: NSSplitViewController {

    private var xiDocumentController = XiDocumentController.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        self.splitView.dividerStyle = .thin
    }

    public func addEditView(_ editViewController: EditViewController, at index: Int? = nil) {
        let item = NSSplitViewItem()
        editViewController.splitViewItem = item
        item.viewController = editViewController
        item.viewController.view = editViewController.view

        guard index != nil else {
            self.splitViewItems.append(item)
            return
        }

        self.splitViewItems.insert(item, at: index! + 1)
    }

    public func splitVertically(source: NSSplitViewItem) {
        guard
            let foundItemIndex = self.findIndex(source),
            let untitledController = self.createUntitledItem()
        else { return }

        self.addEditView(untitledController, at: foundItemIndex)
    }

    public func splitHorizontally(source: NSSplitViewItem) {
        let toSplitVC = source.viewController as? EditViewController

        guard
            let toSplitView = toSplitVC?.view,
            let foundItemIndex = self.findIndex(source),
            let untitledController = self.createUntitledItem()
        else { return }

        let item = NSSplitViewItem()
        let splitView = NSSplitView()
        splitView.isVertical = false
        splitView.dividerStyle = .thin

        splitView.addSubview(toSplitView)
        splitView.addSubview(untitledController.view)

        let svc = XiSplitViewController()
        svc.view = splitView

        item.viewController = svc

        self.splitViewItems.remove(at: foundItemIndex)
        self.splitViewItems.insert(item, at: foundItemIndex)
    }

    private func createUntitledItem() -> EditViewController? {
        guard let doc = try? xiDocumentController.makeUntitledDocument(ofType: "txt") as? Document else {
            return nil
        }

        let editViewController = storyboard?.instantiateController(
            withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "Edit View Controller")
        ) as! EditViewController

        editViewController.document = doc
        doc?.editViewController = editViewController

        return editViewController
    }

    private func findIndex(_ source: NSSplitViewItem) -> Int? {
        for (index, element) in self.splitViewItems.enumerated() {
            if element == source {
                return index
            }
        }

        return nil
    }

}
