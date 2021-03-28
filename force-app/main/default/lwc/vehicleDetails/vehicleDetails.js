import { LightningElement, api } from 'lwc';

export default class VehicleDetails extends LightningElement {
    //data about vehicle
    targetVehicle;

    targetVehicleMainbtenance;



    set vehicleData(value) {
        console.log("set in progres" + JSON.stringify(value));
        this.targetVehicle = value;

    }
    @api get vehicleData() {
        console.log("api get call");
        return this.targetVehicle;
    }




}