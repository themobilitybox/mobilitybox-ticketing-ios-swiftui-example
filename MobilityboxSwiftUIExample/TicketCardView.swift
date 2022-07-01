import SwiftUI
import Mobilitybox

struct TicketCardView: View {
    @Binding var ticket: MobilityboxTicket
    @Binding var renderEngine: MobilityboxTicketRenderingEngine
    
    var body: some View {
        MobilityboxNavigationLink(linkType: .modal) {
            MobilityboxCardView(ticket: $ticket)
        } navigationDestination: {
            MobilityboxTicketInspectionView(ticket: ticket, renderEngine: $renderEngine)
        }.disabled(!ticket.isValid())
    }
}
