//
//  Feedback.swift
//  modoohotdeal
//
//  Created by baedy on 2019/12/30.
//  Copyright © 2019 baedy. All rights reserved.
//
import UIKit

@available(iOS 10.0, *)
struct Feedback {
    
    static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) -> FeedbackOccurrence {
        return ImpactFeedback(style: style)
    }
    
    static func notification(type: UINotificationFeedbackGenerator.FeedbackType) -> FeedbackOccurrence {
        return NotificationFeedback(type: type)
    }
    
    static func selection() -> FeedbackOccurrence {
        return SelectionFeedback()
    }
    
}

@available(iOS 10.0, *)
protocol FeedbackOccurrence {
    
    func occurred()
    
}

@available(iOS 10.0, *)
fileprivate struct ImpactFeedback: FeedbackOccurrence {
    
    let style: UIImpactFeedbackGenerator.FeedbackStyle
    
    func occurred() {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
}

@available(iOS 10.0, *)
fileprivate struct NotificationFeedback: FeedbackOccurrence {
    
    let type: UINotificationFeedbackGenerator.FeedbackType
    
    func occurred() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
    
}

@available(iOS 10.0, *)
fileprivate struct SelectionFeedback: FeedbackOccurrence {
    func occurred() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}

