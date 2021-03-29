import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'



import getRecords from '@salesforce/apex/MaintenanceViewController.getRecords';
// import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import MAINTENANCCE_OBJECT from '@salesforce/schema/Maintenance__c';
import ID_FIELD from '@salesforce/schema/Maintenance__c.Id';
import FROM_DATE_FIELD from '@salesforce/schema/Maintenance__c.Maintenance_from_date__c';
import ACTUAL_DATE_FIELD from '@salesforce/schema/Maintenance__c.Maintenance_date__c';
import STATUS_FIELD from '@salesforce/schema/Maintenance__c.Maintenance_status__c';
import SERVICE_FIELD from '@salesforce/schema/Maintenance__c.Maintenance_Service__c';
import VEHICLE_FIELD from '@salesforce/schema/Maintenance__c.Vehicle__c';

import SERVICE_NAME_FIELD from '@salesforce/schema/Maintenance__c.Maintenance_Service__r.Name';



//---------------------------------
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import WEBSITE_FIELD from '@salesforce/schema/Account.Website';
//--------------------------------
const COLUMNS = [
    { label: 'ID', fieldName: ID_FIELD.fieldApiName, type: 'text' },
    { label: 'From date', fieldName: FROM_DATE_FIELD.fieldApiName, type: 'date' },
    { label: 'Real date', fieldName: ACTUAL_DATE_FIELD.fieldApiName, type: 'date' },
    { label: 'Status', fieldName: STATUS_FIELD.fieldApiName, type: 'text' },
    { label: 'Service', fieldName: SERVICE_NAME_FIELD.fieldApiName, type: 'text' }

];



export default class MaintenanceView extends LightningElement {
    @api vehicleId;
    columns = COLUMNS;

    @track maintenances;
    @track error;
    @track wireMaintenances = [];

    @wire(getRecords, { targetVehicleId: '$vehicleId' })
    wiredRecord({ data, error }) {
        if (data) {
            this.maintenances = data;
        }
        if (error) {
            this.error = error;
        }
    }



    // @wire(getRecords) maintenances;

    showNew = false;
    handleShowNewDialog(event) {
        if (!this.showNew) {
            this.showNew = true;
        } else {
            this.showNew = false;
        }
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
    }



    objectApiName = MAINTENANCCE_OBJECT;
    fields = [FROM_DATE_FIELD, SERVICE_FIELD];

    handleMaintenanceCreation(event) {
        console.log(JSON.stringify(event.detail));
        const toastEvent = new ShowToastEvent({
            title: "Mainteannce created",
            message: "Record ID: " + event.detail.id,
            // message: "Maintenance sheduled from  " + event.detail.values.fields.Maintenance_from_date__c.value +
            //     "  due " + event.detail.values.fields.Maintenance_due_date__c.value,
            variant: "success"
        });
        console.log('contact creation success');
        this.dispatchEvent(toastEvent);
        refreshApex(this.maintenances);


    }
    handleClick(event) {

        console.log('maintenances ' + JSON.stringify(this.maintenances));
        console.log("colums : " + JSON.stringify(this.columns));
        console.log('service ' + SERVICE_NAME_FIELD);

    }
}