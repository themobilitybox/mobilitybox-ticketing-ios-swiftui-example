import SwiftUI
import Mobilitybox

struct TicketCardView: View {
    @Binding var ticket: MobilityboxTicket
    
    var body: some View {
        MobilityboxNavigationLink(linkType: .modal) {
            MobilityboxCardView(ticket: $ticket)
        } navigationDestination: {
            MobilityboxTicketInspectionView(ticket: ticket)
                .navigationBarTitleDisplayMode(.inline)
        }.disabled(!ticket.isValid())
    }
}
