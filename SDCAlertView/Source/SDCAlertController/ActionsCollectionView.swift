//
//  ActionsCollectionView.swift
//  SDCAlertController
//
//  Created by Scott Berrevoets on 7/13/15.
//  Copyright © 2015 Scott Berrevoets. All rights reserved.
//

import UIKit

private let kActionCellIdentifier = "actionCell"

class ActionsCollectionView: UICollectionView {

    var actions: [AlertAction] = []

    var visualStyle: VisualStyle! {
        didSet {
            guard let layout = self.collectionViewLayout as? ActionsCollectionViewFlowLayout else { return }
            layout.visualStyle = self.visualStyle
        }
    }

    var displayHeight: CGFloat {
        guard let layout = self.collectionViewLayout as? ActionsCollectionViewFlowLayout,
            let visualStyle = self.visualStyle else {
                return -1
            }

        if layout.scrollDirection == .Horizontal {
            return visualStyle.actionViewSize.height
        } else {
            return visualStyle.actionViewSize.height * CGFloat(self.numberOfItemsInSection(0))
        }
    }

    var actionTapped: ((AlertAction) -> Void)?

    private var highlightedCell: UICollectionViewCell?

    init() {
        super.init(frame: .zero, collectionViewLayout: ActionsCollectionViewFlowLayout())
        self.dataSource = self
        self.delegate = self
        self.backgroundColor = UIColor.clearColor()
        self.delaysContentTouches = false

        self.collectionViewLayout.registerClass(ActionSeparatorView.self,
            forDecorationViewOfKind: kHorizontalActionSeparator)
        self.collectionViewLayout.registerClass(ActionSeparatorView.self,
            forDecorationViewOfKind: kVerticalActionSeparator)

        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "highlightCurrentAction:"))
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "highlightCurrentAction:"))

        let nibName = NSStringFromClass(ActionCell.self).componentsSeparatedByString(".").last!
        let nib = UINib(nibName: nibName, bundle: NSBundle(forClass: self.dynamicType))
        self.registerNib(nib, forCellWithReuseIdentifier: kActionCellIdentifier)
    }

    convenience required init?(coder aDecoder: NSCoder) {
        self.init()
    }

    @objc
    private func highlightCurrentAction(sender: UIGestureRecognizer) {
        if sender.state == .Cancelled || sender.state == .Failed || sender.state == .Ended {
            self.highlightedCell?.highlighted = false
            self.highlightedCell = nil
        }

        let touchPoint = sender.locationInView(self)
        guard let indexPath = indexPathForItemAtPoint(touchPoint), cell = cellForItemAtIndexPath(indexPath)
            where cell != self.highlightedCell else {
                return
            }

        if sender.state == .Began || sender.state == .Changed {
            self.highlightedCell?.highlighted = false
            cell.highlighted = true
            self.highlightedCell = cell
        }

        if sender.state == .Ended {
            self.actionTapped?(self.actions[indexPath.item])
        }
    }
}

extension ActionsCollectionView: UICollectionViewDataSource {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.actions.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath)
        -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(kActionCellIdentifier,
            forIndexPath: indexPath) as? ActionCell
        cell?.action = self.actions[indexPath.item]
        cell?.visualStyle = self.visualStyle
        return cell!
    }
}

extension ActionsCollectionView: UICollectionViewDelegateFlowLayout {

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        let actionWidth = self.visualStyle.actionViewSize.width
        let actionHeight = self.visualStyle.actionViewSize.height

        let layout = self.collectionViewLayout as! UICollectionViewFlowLayout
        if layout.scrollDirection == .Horizontal {
            let width = max(self.bounds.width / CGFloat(self.numberOfItemsInSection(0)), actionWidth)
            return CGSize(width: width, height: actionHeight)
        } else {
            return CGSize(width: self.bounds.width, height: actionHeight)
        }
    }
}
