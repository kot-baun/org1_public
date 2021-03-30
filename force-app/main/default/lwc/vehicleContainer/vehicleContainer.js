import { LightningElement, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
const fields = [NAME_FIELD];
export default class Selector extends LightningElement {
    // data about the vehicle, selected in the vehicleView. Used to send data to the Vehicle Details component.
    selectedVehicleData;
    handleVehicleSelect(event) {
        console.log('handle succes ' + JSON.stringify(event.detail));
        this.selectedVehicleData = event.detail;
    }

    userId = Id;
    @wire(getRecord, { recordId: '$userId', fields })
    user;
    get name() {
        return getFieldValue(this.user.data, NAME_FIELD);
    }
}