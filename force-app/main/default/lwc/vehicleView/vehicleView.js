
import { LightningElement, wire, track, api } from 'lwc';
import getRecords from '@salesforce/apex/VehicleViewController.getRecords';
import ID_FIELD from '@salesforce/schema/Vehicle__c.Id';
import MODEL_FIELD from '@salesforce/schema/Vehicle__c.Vehicle_model_description__c';
import PLATE_FIELD from '@salesforce/schema/Vehicle__c.Vehicle_plate_number__c';

import DRIVER_NAME_FIELD from '@salesforce/schema/Vehicle__c.Vehicle_driver__r.Name';
import DRIVER_PHONE_FIELD from '@salesforce/schema/Vehicle__c.Vehicle_driver_contact_phone_reader__c';
import STATUS_FIELD from '@salesforce/schema/Vehicle__c.Vehicle_Status__c';
import TYPE_FIELD from '@salesforce/schema/Vehicle__c.Vehicle_Type__c';
import ACTUAL_DATE_FIELD from '@salesforce/schema/Vehicle__c.Vehicle_Last_Maintenance_Date__c';


//filter
const ALL = 'All';
const NOT_AVAILABLE_STATUS = 'Not Available';
const AT_SERVICE_STATUS = 'At Service';
const AVAILABLE_STATUS = 'Available';
const filterOptions = [
    { value: ALL, label: ALL },
    { value: AVAILABLE_STATUS, label: AVAILABLE_STATUS },
    { value: NOT_AVAILABLE_STATUS, label: NOT_AVAILABLE_STATUS },
    { value: AT_SERVICE_STATUS, label: AT_SERVICE_STATUS },
];
//datatable
const RECORD_DETAIL = 'recordDetail';
const COLUMNS = [
    { label: 'ID', fieldName: ID_FIELD.fieldApiName, type: 'text' },
    { label: 'Model description', fieldName: MODEL_FIELD.fieldApiName, type: 'text' },
    { label: 'Plate number', fieldName: PLATE_FIELD.fieldApiName, type: 'text', editable: true },
    { label: 'Status', fieldName: STATUS_FIELD.fieldApiName, type: 'text' },
    { label: 'Date', fieldName: ACTUAL_DATE_FIELD.fieldApiName, type: 'date' },
    { label: 'Driver name', fieldName: DRIVER_NAME_FIELD.fieldApiName, type: 'text' },
    {
        type: 'button', label: 'Detail', typeAttributes:
        {
            label: 'detail >> ',
            name: RECORD_DETAIL,
            title: 'editTitle',
            disabled: false,
            value: 'test',
        }
    },
];




export default class VehicleView extends LightningElement {
    //datatable
    columns = COLUMNS;
    //combobox selected value
    filterValue = ALL;

    @track vehicles;
    @track error;

    // refresh;
    @wire(getRecords, { status: '$filterValue' })
    wiredRecord(result) {
        // this.refresh = result;
        if (result.data) {
            this.vehicles = result.data;
            this.error = undefined;
        }
        if (result.error) {
            this.vehicles = undefined;
            this.error = result.error;
        }
    }

    get filterOptions() {
        return filterOptions;
    }

    //--------------------------------     handlers     //--------------------------------
    /**
     * Select one vehicle from datatble, and get it's ID. Fire an event to send a selected vehicle Id to the vehicleContainer
     * @param event 
     */
    handleRowAction(event) {
        const selectedRow = event.detail.row;
        const actionName = event.detail.action.name;
        console.log(actionName + ' row ->   ' + JSON.stringify(selectedRow));
        console.log('data ' + JSON.stringify(this.vehicles.find(v => v.Id === selectedRow.Id)));
        switch (actionName) {

            case RECORD_DETAIL:
                console.log(selectedRow.Id);
                // This component wants to emit a vehicleselected event to its parent
                const evt = new CustomEvent('vehicleselected', {
                    // detail: event.detail
                    detail: this.vehicles.find(v => v.Id === selectedRow.Id)
                });
                // Fire the event from vehicleView
                this.dispatchEvent(evt);
                break;
        }
    }

    /**
     * Handle filter value change, this will trigger a request to the server
     * and update the shown data 
     * @param event 
     */
    handleFilter(event) {
        console.log(JSON.stringify(event.detail));
        try {
            this.filterValue = event.detail.value;
        } catch (error) {
            console.log("error catched " + error.name);
            console.log(error.message);
            console.log(error.stack);
        }

    }
}