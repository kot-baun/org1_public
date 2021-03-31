import { LightningElement, api } from 'lwc';

export default class VehicleDetails extends LightningElement {
    // vehicle data obtained from a vehicle container. They are shown to the user and the vehicle ID is sent to the maintenanceDetail
    targetVehicle;

    @api get vehicleData() { return this.targetVehicle; }
    set vehicleData(value) { this.targetVehicle = value; }
}