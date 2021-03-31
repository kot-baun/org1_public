import { LightningElement, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
const fields = [NAME_FIELD];
export default class VehicleContainer extends LightningElement {
    // data about the vehicle, selected in the vehicleView. Used to send data to the Vehicle Details component.
    selectedVehicleData;
    // show current user name
    userId = Id;
    get name() { return getFieldValue(this.user.data, NAME_FIELD); }

    @wire(getRecord, { recordId: '$userId', fields }) user;

    handleVehicleSelect(event) { this.selectedVehicleData = event.detail; }

}