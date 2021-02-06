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
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), watchable: KrangMovie.endOfEva, user: nil)
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration, watchable: KrangMovie.endOfEva, user: nil)
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
//        print(profile)
        
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
                    Text("\(self.entry.user != nil ? "Not Watching Anything" : "Not Logged In")")
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
        GeometryReader { geometry in
            ZStack(alignment: Alignment(horizontal: .leading, vertical: .bottom), content: {
                
                //Info at bottom
                VStack(alignment: .leading) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            WatchableTitleView(watchable: self.watchable)
                            .foregroundColor(Color("widgetTextPrimary"))
                            Spacer()
                        }
                        // Dots
                        LinkableIndicatorsView(linkable: self.watchable).padding(.leading, 3.0)
                    }.frame(maxWidth: .infinity)
                    .padding(8)
                    .background(Color("widgetBackground").opacity(0.7))
                }.zIndex(1.0)
                
                
                if let szurl = self.imageURLForBackground(),
                   let url = URL(string: szurl),
                   let imageData = try? Data(contentsOf: url),
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill).zIndex(0.8)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }).frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottomLeading)
        }
        .background(Color.clear)
    }
    
    func imageURLForBackground() -> String? {
        if let episode = self.watchable as? KrangEpisode {
            return episode.posterImageURL ?? episode.season?.posterImageURL ?? episode.show?.imagePosterURL
        }
        return self.watchable.posterImageURL
    }
}

struct LinkableIndicatorsView: View {
    @State var linkable: KrangLinkable
    
    var body: some View {
        HStack {
            if linkable.urlForTrakt != nil {
                IndicatorView(color: Color("TraktPrimary"))
            }
            if linkable.urlForIMDB != nil {
                IndicatorView(color: Color("IMDbPrimary"))
            }
            if linkable.urlForTMDB != nil {
                IndicatorView(color: Color("TMDBPrimary"))
            }
        }
    }
    
    struct IndicatorView: View {
        @State var color: Color
        var body: some View {
            Circle().strokeBorder(Color("widgetTextPrimary").opacity(0.5)).frame(width: 6, height: 6, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .background(
                    Circle().fill(self.color)
                )
        }
    }
}

//struct LinkableIndicatorView_Previews: PreviewProvider {
//    static var previews: some View {
//        LinkableIndicatorView(linkable: Now_Watching_Previews.endOfEva)
//    }
//}

struct WatchableTitleView: View {
    @State var watchable: KrangWatchable
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5, content: {
            if let episode = self.watchable as? KrangEpisode,
               let show = episode.show {
                
                Text(show.title).foregroundColor(.white).font(.headline)
                Text(episode.title).foregroundColor(Color.white.opacity(0.8)).font(.footnote)
            } else {
                Text(self.watchable.titleDisplayString).foregroundColor(.white).font(.headline)
            }
        })
    }
}

struct WatchableTitleView_Previews: PreviewProvider {
    static var previews: some View {
        WatchableTitleView(watchable: KrangMovie.endOfEva).previewContext(WidgetPreviewContext(family: .systemSmall)).background(Color.black)
    }
}

struct WatchableView_Previews: PreviewProvider {
    static var previews: some View {
        WatchableView(watchable: KrangMovie.endOfEva)
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
        .configurationDisplayName("Now Watching")
        .description("Get info and shortcuts for what you're currently checked into on Trakt.")
    }
}

struct Now_Watching_Previews: PreviewProvider {
    
    static var previews: some View {
        Now_WatchingEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), watchable: nil, user: nil))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        
        
        Now_WatchingEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), watchable: KrangMovie.endOfEva, user: nil))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        Now_WatchingEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), watchable: KrangMovie.endOfEva, user: nil))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
        
    }
}
