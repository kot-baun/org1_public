
import { LightningElement, wire, track, api } from 'lwc';
// import getRecords from '@salesforce/apex/VehicleViewController.getRecords';
// import ID_FIELD from '@salesforce/schema/Vehicle__c.Id';
// import MODEL_FIELD from '@salesforce/schema/Vehicle__c.Vehicle_model_description__c';
// import PLATE_FIELD from '@salesforce/schema/Vehicle__c.Vehicle_plate_number__c';

// import DRIVER_NAME_FIELD from '@salesforce/schema/Vehicle__c.Vehicle_driver__r.Name';
// import DRIVER_PHONE_FIELD from '@salesforce/schema/Vehicle__c.Vehicle_driver_contact_phone_reader__c';
// import STATUS_FIELD from '@salesforce/schema/Vehicle__c.Vehicle_Status__c';
// import TYPE_FIELD from '@salesforce/schema/Vehicle__c.Vehicle_Type__c';
// import ACTUAL_DATE_FIELD from '@salesforce/schema/Vehicle__c.Vehicle_Last_Maintenance_Date__c';
// import getWrappedRecords from '@salesforce/apex/VehicleViewController.getWrappedRecords';

import getWrappedRecords from '@salesforce/apex/VehicleViewController.getWrappedRecords';

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
    // { label: 'ID', fieldName: 'id', type: 'text' },
    { label: 'Model description', fieldName: 'vehicleDescription', type: 'text' },
    { label: 'Plate number', fieldName: 'plateNumber', type: 'text', editable: true },
    { label: 'Status', fieldName: 'status', type: 'text' },
    { label: 'Maintenance date', fieldName: 'lastMaintenanceDate', type: 'date' },
    { label: 'Driver name', fieldName: 'driverName', type: 'text' },
    {
        type: 'button', label: 'Detail',
        typeAttributes: { label: 'detail >> ', name: RECORD_DETAIL, title: 'Show vehicle details', },
        cellAttributes: { alignment: 'right' }
    },
];

export default class VehicleView extends LightningElement {
    //datatable
    columns = COLUMNS;
    //combobox selected value
    filterValue = ALL;
    get filterOptions() { return filterOptions; }

    @track vehicles;
    @track error;

    refresh;
    @wire(getWrappedRecords, { status: '$filterValue' }) wiredRecord(result) {
        this.refresh = result;
        if (result.data) {
            this.vehicles = result.data;
            this.error = undefined;
        }
        if (result.error) {
            this.vehicles = undefined;
            this.error = result.error;
        }
    }

    /**
     * Select one vehicle from datatble, and get it's ID. Fire an event to send a selected vehicle Id to the vehicleContainer
     * @param event 
     */
    handleRowAction(event) {
        const selectedRow = event.detail.row;
        const actionName = event.detail.action.name;
        switch (actionName) {
            case RECORD_DETAIL:
                // Fire the event from vehicleView to vehicleContainer
                this.dispatchEvent(new CustomEvent('vehicleselected', {
                    detail: this.vehicles.find(v => v.id === selectedRow.id)
                }));
                break;
        }
    }

    /**
     * Handle filter value change, this will trigger a request to the server
     * and update the shown data 
     * @param event 
     */
    handleFilter(event) {
        try {
            this.filterValue = event.detail.value;
        } catch (error) {

        }

    }
}