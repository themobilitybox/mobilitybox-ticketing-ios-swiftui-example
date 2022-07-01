import SwiftUI
import Mobilitybox

struct CouponCardView: View {
    @Binding var coupon: MobilityboxCoupon
    var activateCouponCallback: ((MobilityboxCoupon, MobilityboxTicketCode) -> Void)
    
    @State var showDestinationView = false
    
    var body: some View {
        MobilityboxNavigationLink(linkType: .modal) {
            MobilityboxCardView(coupon: $coupon)
        } navigationDestination: {
            MobilityboxIdentificationView(coupon: $coupon, activateCouponCallback: activateCouponCallback)
        }.disabled(coupon.activated)
    }
}
