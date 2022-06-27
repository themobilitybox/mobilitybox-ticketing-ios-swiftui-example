import SwiftUI

struct AddCouponCodeView: View {
    @Environment(\.dismiss) var dismiss
    @State var newCouponId = ""
    var addCouponIdCallback: ((String) -> Void)
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text("Enter a Coupon ID")
                    .font(.headline)
                    .padding()
                Text("Please enter a Coupon ID received from you order process to add it to the list.")
                TextField("mobilitybox-coupon-abcde", text: $newCouponId)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                HStack {
                    Button("Cancel") {
                       dismiss()
                    }.buttonStyle(.bordered)
                    Button("Add Coupon") {
                        self.addCouponIdCallback(self.newCouponId)
                        dismiss()
                    }.buttonStyle(.bordered)
                }
                Spacer()
                
            }.padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Label("", systemImage: "xmark")
                    }
                }
            }
        }
    }
}
