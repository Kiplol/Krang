//
//  Now_Watching.swift
//  Now Watching
//
//  Created by Elliott Kipper on 2/4/21.
//  Copyright © 2021 Supernovacaine Inc. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents
import RealmSwift

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), watchable: nil, user: nil)
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration, watchable: nil, user: nil)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        _ = RealmManager.shared
        let profile = KrangUser.getCurrentUser()
        print(profile)
        
        TraktHelper.shared.getCheckedInMovieOrEpisode { _, movie, episode in
            guard movie != nil || episode != nil else {
                return 
            }
        }

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration, watchable: nil, user: profile)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let watchable: KrangWatchable?
    let user: KrangUser?
}

struct Now_WatchingEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
            Text("\(self.entry.user?.username ?? "Not Logged In")")
        })
        
    }
}

@main
struct Now_Watching: Widget {
    let kind: String = "Now_Watching"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            Now_WatchingEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct Now_Watching_Previews: PreviewProvider {
    static var previews: some View {
        Now_WatchingEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), watchable: nil, user: nil))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
