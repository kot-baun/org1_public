import { LightningElement, api } from 'lwc';

export default class VehicleDetails extends LightningElement {
    // vehicle data obtained from a vehicle container. They are shown to the user and the vehicle ID is sent to the maintenanceDetail
    targetVehicle;

    set vehicleData(value) {
        console.log("set in progres" + JSON.stringify(value));
        this.targetVehicle = value;
    }
    @api get vehicleData() {
        console.log("api get call");
        return this.targetVehicle;
    }




}