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
        guard !profile.username.isEmpty else {
            let notLoggedInEntry = SimpleEntry(date: Date(), configuration: configuration, watchable: nil, user: nil)
            entries.append(notLoggedInEntry)
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
            return
        }
        print(profile)
        
        TraktHelper.shared.getCheckedInMovieOrEpisode { _, movie, episode in
            guard movie != nil || episode != nil else {
                let notWatchignAnythingEntry = SimpleEntry(date: Date(), configuration: configuration, watchable: nil, user: profile)
                entries.append(notWatchignAnythingEntry)
                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
                return 
            }
            
            let watchable = (movie ?? episode)! as KrangWatchable
            let endDate = watchable.checkin?.dateExpires ?? Date().addingTimeInterval(60 * 60)
            let watchingEntry = SimpleEntry(date: endDate, configuration: configuration, watchable: watchable, user: profile)
            entries.append(watchingEntry)
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
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
        ZStack {
            if let watchable = self.entry.watchable {
                WatchableView(watchable: watchable)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
                    Text("\(self.entry.user?.username ?? "Not Logged In")")
                        .foregroundColor(Color("widgetTextPrimary"))
                })
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Image("logo").resizable().aspectRatio(contentMode: .fit).padding().opacity(0.05))
        .background(Color("widgetBackground"))
    }
}

struct WatchableView: View {
    var watchable: KrangWatchable
    
    var body: some View {
        ZStack {
    
            //Info at bottom
            VStack {
                Spacer()
                VStack {
                    Text(self.watchable.title).font(.headline).foregroundColor(Color("widgetTextPrimary"))
                }.frame(maxWidth: .infinity)
                .padding(8)
                .background(Color("widgetBackground").opacity(0.6))
            }.zIndex(/*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
            
//            if let url = self.watchable.posterThumbnailURL,
//               let imageData = try? Data(contentsOf: url),
//               let uiImage = UIImage(data: imageData) {
//                Image(uiImage: uiImage)
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//            }
        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
    }
}

struct WatchableView_Previews: PreviewProvider {
    static var previews: some View {
        WatchableView(watchable: Now_Watching_Previews.endOfEva)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
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
    
    static var endOfEva: KrangWatchable {
        let movie = KrangMovie()
        movie.title = "Neon Genesis Evangelion: The End of Evangelion"
        movie.posterThumbnailImageURL = "https://i.ebayimg.com/images/g/zkgAAOSwYIxX~Zju/s-l500.jpg"
        movie.posterImageURL = "https://i.ebayimg.com/images/g/zkgAAOSwYIxX~Zju/s-l500.jpg"
        movie.traktID = 11325
        movie.imdbID = "tt0169858"
        movie.tmdbID = 18491
        return movie
    }
    
    static var previews: some View {
        Now_WatchingEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), watchable: nil, user: nil))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        
        
        Now_WatchingEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), watchable: Self.endOfEva, user: nil))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        
    }
}
