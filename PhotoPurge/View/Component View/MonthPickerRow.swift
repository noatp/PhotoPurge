import SwiftUI
import Photos

struct MonthPickerRow: View {
    @Binding var selectedDate: Date?
    let assetsGroupedByMonth: [Date: [PHAsset]]
    let selectMonth: (Date) -> Void
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 20) {
                    ForEach(assetsGroupedByMonth.keys.sorted(), id: \.self) { date in
                        monthPickerButton(for: date)
                            .id(date)
                            .onTapGesture {
                                if selectedDate != date {
                                    selectedDate = date
                                    selectMonth(date)
                                }
                            }
                    }
                }
            }
            .onChange(of: selectedDate) { _, newValue in
                guard let date = newValue else { return }
                withAnimation (.easeInOut(duration: 0.2)) {
                    proxy.scrollTo(date, anchor: .center)
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
    
    private func monthPickerButton(for date: Date) -> some View {
        VStack(spacing: 0) {
            Text(Util.getYear(from: date))
                .font(.headline)
                .foregroundColor(date == selectedDate ? .white : .primary)
            
            Text(Util.getShortMonth(from: date))
                .font(.headline)
                .padding(.bottom, 5)
                .foregroundColor(date == selectedDate ? .white : .primary)
            
            Text("\(assetsGroupedByMonth[date]?.count ?? 0) items")
                .font(.caption)
                .foregroundColor(date == selectedDate ? .white : .secondary)
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(date == selectedDate ? Color.blue : Color.secondary.opacity(0.3))
        )
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    let today = Date()
    let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: today)!
    
    let assetsGroupedByMonth: [Date: [PHAsset]] = [
        oneYearAgo: [],
        today: []
    ]
    
    MonthPickerRow(selectedDate: .constant(today), assetsGroupedByMonth: assetsGroupedByMonth) { selectedDate in
        print(selectedDate)
    }
}
