PCI Master Controller and Arbitration Implementation using Verilog
****************************************************************************************************************
This is a team project assigned by Prof. Ashraf Salem in Computer Organization 2 Course at the Faculty of Engineering, Ain Shams University.
****************************************************************************************************************
In this project, it is required to model the whole PCI communication protocol in verilog. There are two main modules : 
1- Device
2- Arbiter

The Arbiter operates in a  “Priority” mode.

For every “Device”, there is a special input called “force_request” for testing purposes. This input works as a trigger for the req output signal. This way, it is possible to trigger any request from any device. If the “force_req” signal is asserted for one cycle, then the device will want the bus for one transaction. If it was asserted for two cycles, the device should want the bus for two different transactions and act accourdingly, and so on.
Also, there is another signal (again for testing purposes) called “AddressToContact”. Whenever it is asserted,  the address of the target should be set. Each device must have a unique address.